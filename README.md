# Ruby Versions docker action

This actions simply provides all available stable versions of the Ruby interpreter as a JSON-structure output variable.

## Example usage

```yaml
- name: Fetch Ruby versions
  id: ruby-versions
  uses: moritzheiber/ruby-versions-action@v1
- name: Display latest versions
- run: echo ${{ step.ruby-versions.outputs.versions }}
```

A more elaborate version would be to build [a matrix](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstrategymatrix) for other jobs out of the outputs:

```yaml
# [...]
jobs:
  gather-versions:
    runs-on: ubuntu-latest
    outputs:
      versions: ${{ steps.ruby-versions.outputs.versions }}
      metadata: ${{ steps.ruby-versions.outputs.metadata }}
    steps:
      - uses: moritzheiber/ruby-versions-action@v1
        with:
          version_name: ruby
          checksum_name: ruby_checksum
        name: Fetch latest Ruby versions
        id: ruby-versions
  use-versions:
    runs-on: ubuntu-latest
    needs: ["gather-versions"]
    strategy:
      matrix:
        ruby: ${{ fromJSON(needs.gather-versions.outputs.versions) }}
        include: ${{ fromJSON(needs.gather-versions.outputs.metadata) }}
    steps:
      - run: echo "My version is ${{ matrix.ruby }} and my checksum is ${{ matrix.ruby_checksum }}"
```

The [`include`](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstrategymatrixinclude) statement in the `matrix` call adds the `ruby_checksum` parameter to every available version in the `ruby` array when the matrix is expanded. For this to work one of the `matrix` parameters are passed as `version_name` and `checksum_name` to the initial step where the versions are gathered, so that the `matrix` expansion on the `ruby` keyword array (containing the available versions, i.e. number of `matrix` jobs that are run) matches the index in the `include` part. The expanded `matrix` looks like this:

```yaml
# [...]
  ruby: ["3.0.5","3.1.3","3.2.0"]
  include:
    - ruby: "3.0.5"
      ruby_checksum: "[...]"
      url: "[...]"
    - ruby: "3.1.3"
      ruby_checksum: "[...]"
      url: "[...]"
    - ruby: "3.2.0"
      ruby_checksum: "[...]"
      url: "[...]"
```

*Note: the `url` field isn't used in our example, but you could use it if you wanted to.*

## Inputs

### `version_name`

The name for the `version` key in the `metadata` output. The default is `version`:

```yaml
- id: ruby-versions
  uses: moritzheiber/ruby-versions-action@v1
  with:
    version_name: release
- name: Display latest versions
- run: echo ${{ step.ruby-versions.outputs.versions }}
# [{"url":"https://cache.ruby-lang.org/pub/ruby/3.0/ruby-3.0.5.tar.gz","release":"3.0.5","checksum":"9afc6380a027a4fe1ae1a3e2eccb6b497b9c5ac0631c12ca56f9b7beb4848776"}[...]
```

### `url_name`

The name for the `url` key in the `metadata` output. The default is `url`:

```yaml
- id: ruby-versions
  uses: moritzheiber/ruby-versions-action@v1
  with:
    url_name: download_url
- name: Display latest versions
- run: echo ${{ step.ruby-versions.outputs.versions }}
# [{"version":"3.0.5","download_url":"https://cache.ruby-lang.org/pub/ruby/3.0/ruby-3.0.5.tar.gz","checksum":"9afc6380a027a4fe1ae1a3e2eccb6b497b9c5ac0631c12ca56f9b7beb4848776"}[...]
```

### `checksum_name`

The name for the `checksum` key in the `metadata` output. The default is `checksum`:

```yaml
- id: ruby-versions
  uses: moritzheiber/ruby-versions-action@v1
  with:
    checksum_name: sha256sum
- name: Display latest versions
- run: echo ${{ step.ruby-versions.outputs.versions }}
# [{"url":"https://cache.ruby-lang.org/pub/ruby/3.0/ruby-3.0.5.tar.gz","version":"3.0.5","sha256sum":"9afc6380a027a4fe1ae1a3e2eccb6b497b9c5ac0631c12ca56f9b7beb4848776"}[...]
```

## Outputs

### `versions`

The available stable Ruby interpreter versions in a JSON array:

```json
["3.0.5","3.1.3","3.2.0"]
```

### `metadata`

An object containing not just the versions themselves but also other useful metadata, like URL for the `tar.gz` tarball file [on the official Ruby download server](https://cache.ruby-lang.org/pub/ruby/) and `sha256` checksum for each release:

```json
[
  {
    "url": "https://cache.ruby-lang.org/pub/ruby/3.0/ruby-3.0.5.tar.gz",
    "version": "3.0.5",
    "checksum": "9afc6380a027a4fe1ae1a3e2eccb6b497b9c5ac0631c12ca56f9b7beb4848776"
  },
  {
    "url": "https://cache.ruby-lang.org/pub/ruby/3.1/ruby-3.1.3.tar.gz",
    "version": "3.1.3",
    "checksum": "5ea498a35f4cd15875200a52dde42b6eb179e1264e17d78732c3a57cd1c6ab9e"
  },
  {
    "url": "https://cache.ruby-lang.org/pub/ruby/3.2/ruby-3.2.0.tar.gz",
    "version": "3.2.0",
    "checksum": "daaa78e1360b2783f98deeceb677ad900f3a36c0ffa6e2b6b19090be77abc272"
  }
]
```
