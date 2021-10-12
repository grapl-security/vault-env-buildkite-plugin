# Vault Env Buildkite Plugin

Retrieves multiple secrets from Vault and injects them into the environment.

This plugin is essentially a wrapper for
[envconsul](https://github.com/hashicorp/envconsul), and makes a few
assumptions:

- all key/value pairs of a Vault secret are exported into the environment
- the path of the key is not incorporated into the final environment variable name
- the name of an environment variable is the uppercased version of the `field` within the secret
- secrets are applied in the order they are specified to the plugin

So, if you have a secret at `secret/data/buildkite/foo` with the contents:
```
foo_token = 123456
bar_key = abcdef
```
this plugin would add the following variables to the environment:
```
FOO_TOKEN=123456
BAR_KEY=abcdef
```

We do not currently provide any other means of mapping values to other
names, or for selecting subsets of key/value pairs.

A `VAULT_TOKEN` is assumed to be present in the environment already;
`VAULT_ADDR` and `VAULT_NAMESPACE` are also assumed to be present,
though may be specified with arguments to the plugin. This plugin is
designed to work alongside the [vault-login][vault-login] plugin; if
you are also using it, you don't need to specify a namespace or
address for this plugin.

At the moment, this plugin is chiefly concerned with Grapl's needs,
and may not be sufficiently generalized or flexible enough for all
uses.

## Example

```yml
steps:
  - command: make test
    plugins:
      - grapl-security/vault-login#v0.1.0
      - grapl-security/vault-env#v0.1.0:
        secrets:
          - secret/data/buildkite/env/FOO_TOKEN
```

```yml
steps:
  - command: make test
    plugins:
      - grapl-security/vault-login#v0.1.0:
      - grapl-security/vault-env#v0.1.0:
        secret_prefix: secret/data/buildkite/env
        secrets:
          - FOO_TOKEN
          - BAR_TOKEN
          - BAZ_TOKEN
```
## Configuration

### image (optional, string)

The container image with the `envconsul` binary that the plugin
uses. Any container used should have the `envconsul` binary as its
entrypoint, as well as the `env` binary.

Defaults to `hashicorp/envconsul`.

### tag (optional, string)

The container image tag the plugin uses.

Defaults to `latest`.

### address (optional, string)

The address of the Vault server to access. If not set, falls back to
`VAULT_ADDR` in the environment. If `VAULT_ADDR` is not set either,
the plugin fails with an error.

You do not need to set this if you are also using the
[vault-login][vault-login] plugin (that plugin should be declared
before this one, however.)

### namespace (optional, string)

The Vault namespace to access. If not set, falls back to
`VAULT_NAMESPACE` in the environment. If `VAULT_NAMESPACE` is not set
either, the plugin fails with an error.

You do not need to set this if you are also using the
[vault-login][vault-login] plugin (that plugin should be declared
before this one, however.)

### secrets (required, array of strings)

The names of the secrets in Vault to be injected into the environment.

### secret_prefix (optional, string)

Path fragment to prepend to each secret key to generate the final,
complete key path to retrieve.

That is, if you specify a secret of `foo`, with a secret prefix of
`secret/data/buildkite`, the plugin will retrieve the secret stored at
`secret/data/buildkite/foo`.

Setting this can help make specifying multiple secrets less
verbose. However, remember that all secrets are prefixed with this
value; if you need secrets that do not share a common prefix, you'll
have to specify them all completely, and leave the prefix unset.

Defaults to no prefix.

## Building

Requires `make`, `docker`, and `docker-compose`.

`make all` will run all formatting, linting, and testing.


[vault-login]: https://github.com/grapl-security/vault-login-buildkite-plugin
