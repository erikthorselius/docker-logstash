# docker-logstash
Logstash 1.5.0-RC3 with added gemfiles. Observe that a local Gemfile. It is https://github.com/RallySoftware/logstash-output-sqs added manually, have a look in the Gemfile. 

## Build and run 
```
docker build -t logstash .
docker run -v /path/to/logstash.conf:/tmp/logstash.conf logstash -f /tmp/logstash.conf
```
## Add plugin
Add your plugin to Gemfile and run `bundle install`. Then checkin Gemfile and Gemfile.lock.
## Deploy
Automated build on https://registry.hub.docker.com/u/regius/docker-logstash
