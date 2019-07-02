## APPLICATION BUILD ENVIRONMENT
FROM elixir:1.9 AS build

ENV MIX_ENV=prod \
    TEST=1 \
    LANG=C.UTF-8

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY mix.exs .
COPY mix.lock .

RUN mix do deps.get, release

## APPLICATION RUN ENVIRONMENT
FROM debian:stretch AS app

ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y openssl

RUN useradd --create-home app
WORKDIR /home/app
COPY --from=build /app/_build .
RUN chown -R app: ./prod
USER app

CMD ["./prod/rel/task_service/bin/task_service", "start"]
