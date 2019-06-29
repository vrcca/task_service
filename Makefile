.PHONY: test

test:
	@mix format --check-formatted && \
	mix test
