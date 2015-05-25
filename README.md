# docker-logstash
Logstash 1.5.0-RC3 with added gemfiles. Observe that a local Gemfile. It is https://github.com/RallySoftware/logstash-output-sqs added manually, have a look in the Gemfile. 

## Build and run 
```
docker build . -name logstash
docker run logstash 
```
## Add plugin
Add your plugin to Gemfile and run `bundle install`. Then checkin Gemfile and Gemfile.lock.
## Deploy
Automated build on https://registry.hub.docker.com/u/regius/docker-logstash
