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
