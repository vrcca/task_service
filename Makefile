PORT?=4001

.PHONY: test

build: dependencies
	mix compile

test:
	@mix format --check-formatted && \
	mix test

dependencies:
	printf 'Y' | mix local.hex --if-missing && \
	mix local.rebar --force  && \
	mix deps.get

start:
	mix run --no-halt

release:
	mix release

docker-image:
	docker build -t task-service .

start-with-docker:
	docker run --publish $(PORT):$(PORT) --env PORT=$(PORT) task-service:latest
