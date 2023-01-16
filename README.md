# Ruby Versions docker action

This actions simply provides all available stable versions of the Ruby interpreter as a JSON-structure output variable.

## Inputs

There are no inputs.

## Outputs

## `versions`

The available stable Ruby interpreter versions in a JSON array:

```json
["3.0.5","3.1.3","3.2.0"]
```

## `checksums`

The checksums for the `tar.gz` tarball release files [on the official Ruby download server](https://cache.ruby-lang.org/pub/ruby/), associated with their respective Ruby versions:

```json
[{"ruby":"3.0.5","ruby_checksum":"9afc6380a027a4fe1ae1a3e2eccb6b497b9c5ac0631c12ca56f9b7beb4848776"},{"ruby":"3.1.3","ruby_checksum":"5ea498a35f4cd15875200a52dde42b6eb179e1264e17d78732c3a57cd1c6ab9e"},{"ruby":"3.2.0","ruby_checksum":"daaa78e1360b2783f98deeceb677ad900f3a36c0ffa6e2b6b19090be77abc272"}]
```

## Example usage

```yaml
- name: Fetch Ruby versions
  id: ruby-versions
  uses: moritzheiber/ruby-versions@main
- name: Display latest versions
- run: echo ${{ step.ruby-versions.versions }}
```
