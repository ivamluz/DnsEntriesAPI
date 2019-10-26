mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
envfile := ./.env

.PHONY: help start debug sql logs stop clear-db

# help target adapted from https://gist.github.com/prwhite/8168133#gistcomment-2278355
TARGET_MAX_CHAR_NUM=20

## Show help
help:
	@echo ''
	@echo 'Usage:'
	@echo '  make <target>'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z_0-9-]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  %-$(TARGET_MAX_CHAR_NUM)s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

## Start the services
start: $(envfile)
	@echo "Pulling images from Docker Hub (this may take a few minutes)"
	docker-compose pull
	@echo "Starting Docker services"
	docker-compose up --detach

## Start the services in debug mode
debug: $(envfile)
	@echo "Starting services (this may take a few minutes if there are any changes)"
	docker-compose -f docker-compose.yml -f docker-compose.debug.yml up --build --detach

## Start an interactive psql session (services must be running)
sql:
	docker-compose exec db psql -U postgres

## Show the service logs (services must be running)
logs:
	docker-compose logs --follow

## Stop the services
stop:
	docker-compose down

## Clear the sandbox and development databases
clear-db: stop
	docker volume rm $(current_dir)_pg_{development,test,production}_data 2>/dev/null || true

create-app:
	docker-compose -f docker-compose.yml -f docker-compose.debug.yml run -w /opt/app dns-api-server  /bin/bash -c "bundle install; bundle exec rails new . --api --force --no-deps --database=postgresql; bundle update;"

$(envfile):
	@echo "Error: .env file does not exist! See the README for instructions."
	@exit 1

# Remove local DBs if the DB schema has changed
# $(clear_db_after_schema_change): $(db_schema)
# 	@$(MAKE) clear-db
# 	@touch $(clear_db_after_schema_change)
