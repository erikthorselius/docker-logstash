# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "socket" # for Socket.gethostname
require "puma/server"
require "puma/minissl"

class Puma::Server
  # ensure this method doesn't mess up our vanilla request
  def normalize_env(env, client); end
end

# Using this input you can receive single or multiline events over http(s).
# Applications can send a HTTP POST request with a body to the endpoint started by this
# input and Logstash will convert it into an event for subsequent processing. Users 
# can pass plain text, JSON, or any formatted data and use a corresponding codec with this
# input. For Content-Type `application/json` the `json` codec is used, but for all other
# data formats, `plain` codec is used.
#
# This input can also be used to receive webhook requests to integrate with other services
# and applications. By taking advantage of the vast plugin ecosystem available in Logstash
# you can trigger actionable events right from your application.
# 
# ==== Security
# This plugin supports standard HTTP basic authentication headers to identify the requester.
# You can pass in an username, password combination while sending data to this input
#
# You can also setup SSL and send data securely over https, with an option of validating 
# the client's certificate. Currently, the certificate setup is through 
# https://docs.oracle.com/cd/E19509-01/820-3503/ggfen/index.html[Java Keystore 
# format]
#
class LogStash::Inputs::Http < LogStash::Inputs::Base
  #TODO: config :cacert, :validate => :path

  config_name "http"

  # Codec used to decode the incoming data.
  default :codec, "plain"

  # The host or ip to bind
  config :host, :validate => :string, :default => "0.0.0.0"

  # The TCP port to bind to
  config :port, :validate => :number, :default => 8080

  # Maximum number of threads to use
  config :threads, :validate => :number, :default => 4

  # Username for basic authorization
  config :user, :validate => :string, :required => false

  # Password for basic authorization
  config :password, :validate => :password, :required => false

  # SSL Configurations
  #
  # Enable SSL
  config :ssl, :validate => :boolean, :default => false

  # The JKS keystore to validate the client's certificates
  config :keystore, :validate => :path

  # Set the truststore password
  config :keystore_password, :validate => :password

  # Here you can set how to decode specific content-types in the body of the request.
  # By default, the plain codec will be used
  config :additional_codecs, :validate => :hash, :default => { "application/json" => "json" }

  # useless headers puma adds to the requests
  # mostly due to rack compliance
  REJECTED_HEADERS = ["puma.socket", "rack.hijack?", "rack.hijack", "rack.url_scheme", "rack.after_reply", "rack.version", "rack.errors", "rack.multithread", "rack.multiprocess", "rack.run_once", "SCRIPT_NAME", "QUERY_STRING", "SERVER_PROTOCOL", "SERVER_SOFTWARE", "GATEWAY_INTERFACE"]

  RESPONSE_HEADERS = {'Content-Type' => 'text/plain'}

  public
  def register
    @server = ::Puma::Server.new(nil) # we'll set the rack handler later
    if @user && @password then
      token = Base64.strict_encode64("#{@user}:#{@password.value}")
      @auth_token = "Basic #{token}"
    end
    if @ssl
      if @keystore.nil? || @keystore_password.nil?
        raise(LogStash::ConfigurationError, "Settings :keystore and :keystore_password are required because :ssl is enabled.")
      end
      ctx = Puma::MiniSSL::Context.new
      ctx.keystore = @keystore
      ctx.keystore_pass = @keystore_password.value
      @server.add_ssl_listener(@host, @port, ctx)
    else
      @server.add_tcp_listener(@host, @port)
    end
    @server.min_threads = 0
    @server.max_threads = @threads
    @codecs = Hash.new
    @additional_codecs.each do |content_type, codec|
      @codecs[content_type] = LogStash::Plugin.lookup("codec", codec).new
    end
  end # def register

  def run(queue)

    # proc needs to be defined at this context
    # to capture @codecs, @logger and lowercase_keys
    p = Proc.new do |req|
      begin
        REJECTED_HEADERS.each {|k| req.delete(k) }
        req = lowercase_keys(req)
        body = req.delete("rack.input")
        @codecs.fetch(req["content_type"], @codec).decode(body.read) do |event|
          event["headers"] = req
          decorate(event)
          queue << event
        end
        ['200', RESPONSE_HEADERS, ['ok']]
      rescue => e
        @logger.error("unable to process event #{req.inspect}. exception => #{e.inspect}")
        ['500', RESPONSE_HEADERS, ['internal error']]
      end
    end

    auth = Proc.new do |username, password|
      username == @user && password == @password.value
    end if (@user && @password)

    @server.app = Rack::Builder.new do
      use(Rack::Auth::Basic, &auth) if auth
      run(p)
    end
    @server.run.join
  end

  private
  def lowercase_keys(hash)
    new_hash = {}
    hash.each_pair do |k,v|
      new_hash[k.downcase] = v
    end
    new_hash
  end

  public
  def teardown
    if @server
      @server.stop(true)
      begin
        @server.binder.close if @server.binder
      rescue IOError
      end
    end
  end

end # class LogStash::Inputs::Http
