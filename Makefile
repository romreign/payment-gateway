include .env
export 

export PROJECT_ROOT=$(shell pwd)

env-up:
	@docker compose up -d payment-postgres

env-down:
	@docker compose down payment-postgres

env-cleanup:
	@read -p "Clear all volume files in the environment? Risk of data loss. [y/N]: " ans; \
	if [ "$$ans" = "y" ]; then \
		docker compose down payment-postgres && \
		sudo rm -rf out/pgdata && \
		echo "Environment files have been cleared. "; \
	else \
		echo "Environment cleanup cancelled. "; \
	fi

env-port-open:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder

migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "Missing seq parameter selection. Example: make migrate-create seq=init" \
		exit 1; \
	fi; \
	docker compose run --rm payment-postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"

migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down 

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "Missing action parameter selection. Example: make migrate-action  action=up" \
		exit 1; \
	fi; \
	docker compose run  --rm payment-postgres-migrate \
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@payment-postgres:5432/${POSTGRES_DB}?sslmode=disable \
		"$(action)"