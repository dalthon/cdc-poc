setup-app:
	@docker-compose up --build cdc-poc
.PHONY: setup-app

database:
	@docker-compose up -d postgres
	@sleep 3
.PHONY: database

migrate:
	@docker-compose run --rm cdc-poc npm run migrate
.PHONY: migrate

setup-db: database migrate
.PHONY: setup-db

setup-kafka-ecosystem:
	@docker-compose up -d zookeeper broker schema-registry connect akhq ksqldb-server ksqldb-cli
.PHONY: setup-kafka-ecosystem

setup-connectors:
	@sleep 15
	./scripts/connectors/debezium.sh
	./scripts/connectors/sink.sh
.PHONY: setup-connectors

setup-all: setup-db setup-kafka-ecosystem setup-connectors setup-app setup-controlcenter
.PHONY: setup-all

populate-tables:
	@docker-compose run --rm cdc-poc npm run script
.PHONY: populate-tables

psql:
	@docker-compose exec postgres psql user=postgres
.PHONY: psql

sqlserver:
	@docker exec -it sqlserver bash -c '/opt/mssql-tools/bin/sqlcmd -U sa -P P@ssw0rd'
.PHONY: sqlserver

ksql:
	@docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
.PHONY: ksql

stop:
	@docker-compose stop
.PHONY: stop

down:
	@docker-compose down
.PHONY: down

setup-controlcenter:
	@docker-compose up -d control-center
	@sleep 3
.PHONY: setup-controlcenter

purge-all:
	@docker ps -aq | xargs docker stop
	@docker ps -aq | xargs docker rm
	@docker images -q | xargs docker rmi
.PHONY: purge-all

wipe:
	docker compose down -v --rmi local --remove-orphans
.PHONY: wipe

logs:
	docker compose logs -f
.PHONY: logs
