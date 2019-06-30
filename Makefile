.PHONY: test

test:
	@mix format --check-formatted && \
	mix test

dependencies:
	@mix local.rebar --force && mix deps.get
