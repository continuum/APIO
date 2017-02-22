SHELL := /bin/bash

all: build db run

run: build
	voltos use API-O && voltos run 'docker-compose up -d'

build: .built .bundled

.built: Dockerfile.development
	docker-compose build
	touch .built

.bundled: Gemfile Gemfile.lock
	docker-compose run web bundle
	touch .bundled

stop:
	docker-compose stop && rm ./tmp/pids/server.pid

restart: build
	docker-compose restart web

mac-open:
	$(shell \
				IP=`docker-machine ip default` ;\
				PORT=`docker-compose port web 3000 | cut -d: -f2` ;\
				if [ "$$PORT" == "" ] ;\
				then echo "@echo 'App NOT running. Check the logs'" ;\
				else echo "open http://$${IP}:$${PORT}" ;\
				fi)



clean: stop
	rm -f tmp/pids/*
	docker-compose rm -f -v bundle_cache
	rm -f .bundled
	docker-compose rm -f
	rm -f .built

test: build db
	docker-compose run web rails test

ptest: build db
	docker-compose run -e RAILS_ENV=test web parallel_test -e "rake db:create && bin/rails db:environment:set RAILS_ENV=test"
	docker-compose run web rake parallel:prepare
	docker-compose run -e RECORD_RUNTIME=true web rake parallel:test

logs:
	docker-compose logs

db: build
	docker-compose run web rake db:create db:migrate

production-build: Dockerfile.production
	docker build  -f Dockerfile.production  -t egob/interoperabilidad  .

.PHONY: all run build stop restart mac-open clean test ptest logs db production-build
