DOCKER_COMPOSE_CHECK := docker compose run --rm

.PHONY: all
all: format
all: lint
all: test
all: ## Run all operations

.PHONY: help
help: ## Print this help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make <target>\n"} \
		 /^[a-zA-Z0-9_-]+:.*?##/ { printf "  %-46s %s\n", $$1, $$2 } \
		 /^##@/ { printf "\n%s\n", substr($$0, 5) } ' \
		 $(MAKEFILE_LIST)
	@printf '\n'

##@ Linting
########################################################################

.PHONY: lint
lint: lint-plugin
lint: lint-shell
lint: ## Perform lint checks on all files

.PHONY: lint-plugin
lint-plugin: ## Lint the Buildkite plugin metadata
	$(DOCKER_COMPOSE_CHECK) plugin-linter

.PHONY: lint-shell
lint-shell: ## Lint the shell scripts
	./pants lint ::

##@ Formatting
########################################################################

.PHONY: format
format: format-shell
format: ## Automatically format all code

.PHONY: format-shell
format-shell: ## Format shell scripts
	./pants fmt ::

##@ Testing
########################################################################

.PHONY: test
test: test-plugin
test: ## Run all tests

.PHONY: test-plugin
test-plugin: ## Test the Buildkite plugin locally (does *not* run a Buildkite pipeline)
	$(DOCKER_COMPOSE_CHECK) plugin-tester
