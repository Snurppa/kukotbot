#FROM hexpm/elixir:1.9.4-erlang-22.3.4.26-debian-bullseye-20210902
ARG ALPINE_VERSION=3.16
FROM elixir:1.11.4-alpine AS builder

# The following are build arguments used to change variable parts of the image.
# The name of your application/release (required)
ARG APP_NAME
ARG MIX_ENV=prod

ENV APP_NAME=${APP_NAME} \
    MIX_ENV=${MIX_ENV}
# By convention, /opt is typically used for applications
WORKDIR /opt/app

# This step installs all the build tools we'll need
RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
    git \
    build-base && \
  mix local.rebar --force && \
  mix local.hex --force

COPY mix.exs mix.lock /opt/app/
RUN mix do deps.get --only :prod, deps.compile

# This copies our app source code into the build container
COPY . .
RUN mix do compile, release

# cp _build/${MIX_ENV}/rel/${APP_NAME}

# From this line onwards, we're in a new image, which will be the image used in production
FROM alpine:${ALPINE_VERSION}
ARG APP_NAME
ARG MIX_ENV=prod

RUN apk update && \
    apk add --no-cache \
      bash \
      openssl-dev

ENV APP_NAME=${APP_NAME}\
    MIX_ENV=${MIX_ENV}

WORKDIR /opt/app

COPY --from=builder /opt/app/_build/${MIX_ENV}/rel/${APP_NAME}/ .

CMD trap 'exit' INT; /opt/app/bin/${APP_NAME} start
