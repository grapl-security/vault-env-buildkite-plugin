#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

# Uncomment to enable stub debugging
# export DOCKER_STUB_DEBUG=/dev/tty

setup() {
    export DEFAULT_IMAGE=hashicorp/envconsul
    export DEFAULT_TAG=latest

    export VAULT_TOKEN=testingtoken
    export VAULT_ADDR=default.vault.mycompany.com:8200
    export VAULT_NAMESPACE=default_namespace

    export BUILDKITE_JOB_ID=2112
}

teardown() {
    unset VAULT_TOKEN
    unset VAULT_ADDR
    unset VAULT_NAMESPACE

    unset BUILDKITE_PLUGIN_VAULT_ENV_SECRETS_0
}

@test "The happy path works" {
    export BUILDKITE_PLUGIN_VAULT_ENV_SECRETS_0="foo"

    docker_vault_cmd="run --env VAULT_TOKEN --name=vault-env-plugin-${BUILDKITE_JOB_ID} -- ${DEFAULT_IMAGE}:${DEFAULT_TAG}"

    stub docker \
         "${docker_vault_cmd} -secret=foo -once -upcase -pristine -no-prefix=true -vault-addr=${VAULT_ADDR} -vault-namespace=${VAULT_NAMESPACE} -vault-renew-token=false -vault-retry-attempts=1 env : echo 'foo=something_very_secret'" \
         "container rm --force vault-env-plugin-2112 : echo 'removing'"

    run "${PWD}/hooks/environment"
    assert_success

    unstub docker
}

@test "Fails if no secrets are specified" {

    unset BUILDKITE_PLUGIN_VAULT_ENV_SECRETS_0

    run "${PWD}/hooks/environment"
    assert_failure

    assert_output --partial "At least one secret must be specified"
}
