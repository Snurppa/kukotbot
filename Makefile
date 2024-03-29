# Courtesy of https://hexdocs.pm/distillery/guides/working_with_docker.html
.PHONY: help

APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`
ELIXIR_IMAGE := elixir:1.11.4

help:
	@echo "$(APP_NAME):$(APP_VSN)-$(BUILD)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
	docker build --build-arg APP_NAME=$(APP_NAME) \
        --build-arg APP_VSN=$(APP_VSN) \
        -t $(APP_NAME):$(APP_VSN)-$(BUILD) \
        -t $(APP_NAME):latest .

run: ## Run the app in Docker
	docker run \
        --expose 4000 -p 4000:4000 \
        -e LOG_LEVEL=debug\
        -e KUKOTBOT_HTTP_PORT=4000\
        -e KUKOTBOT_API_KEY="$$KUKOTBOT_API_KEY"\
        -e KUKOTBOT_TEST_VAR="FOOFF"\
        --rm -it $(APP_NAME):latest

elixir-cli: ## Start /bin/bash in Elixir container
	docker run -it --rm -v "$$PWD":/usr/src/myapp -w /usr/src/myapp $(ELIXIR_IMAGE) /bin/bash

dev: ## Start (dev) in Elixir container with --no-start flag
	docker run -it --rm --name kukotbot-dev -v "$$PWD":/usr/src/myapp -w /usr/src/myapp $(ELIXIR_IMAGE) iex -S mix run --no-start
