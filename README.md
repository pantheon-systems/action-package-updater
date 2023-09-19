# Package Updater GitHub 

[![Test](https://github.com/pantheon-systems/action-package-updater/actions/workflows/test.yml/badge.svg)](https://github.com/pantheon-systems/action-package-updater/actions/workflows/test.yml)
[![Actively Maintained](https://img.shields.io/badge/Pantheon-Actively%20Maintained-yellow?logo=pantheon&color=FFDC28)](https://docs.pantheon.io/oss-support-levels#actively-maintained-support)
[![MIT License](https://img.shields.io/github/license/pantheon-systems/action-package-updater)](https://github.com/pantheon-systems/action-package-updater/blob/main/LICENSE)


A GitHub action that monitors a list of PHP extensions and opens PRs if newer versions exist. Monitors a `dependencies.yml` file that defines the current (known) tags and the (GitHub) repository and will check to see if updates are available. 

Optionally, this can be used to _also_ update version variables declared in a bash script based on those versions that are updated in `dependencies.yml`. Currently, an example of the expected syntax can be found in [`./fixtures/PHP_EXTENSION_VERSIONS`](https://github.com/pantheon-systems/action-package-updater/blob/main/fixtures/PHP_EXTENSION_VERSIONS).

## Inputs
### `dependencies-yml`
**Required** The path to your `dependencies.yml` file. A valid `dependencies.yml` file is required and the action expects that you define the path to the file.

### `output-file`
An optional _additional_ file to update version numbers on based on updated versions in `dependencies.yml`. See [`./fixtures/PHP_EXTENSION_VERSIONS`](https://github.com/pantheon-systems/action-package-updater/blob/main/fixtures/PHP_EXTENSION_VERSIONS) for a current example of a valid `output-file`. In the future, additional use cases may be added.

### `default-branch`
The name of default branch of the repository running the GitHub Action. Defaults to `main` -- if your repository is using `master` or some other pattern for the repository's default branch, you _must_ define this value.

### `dry-run`
Whether to run the action without actually pushing any changes to the repository. If left at the default (`false`), a PR will be created. If you would like to evaluate the output of the changes first, you can run the script with `dry-run` set to `true` and you will see output similar [this test run](https://github.com/pantheon-systems/action-package-updater/actions/runs/5534246116/jobs/10098927317#step:3:119)

## Example Usage
A full example `yml` file is illustrated below:

```yaml
name: Package Updater
on:
  schedule:
    - cron: '0 * * * *'
jobs:
  updater:
    runs-on: ubuntu-latest
    name: Run Package Updater
    steps:
      - uses: actions/checkout@v3
      - uses: pantheon-systems/action-package-updater@v1
        with:
          dependencies-yml: ./dependencies.yml
```

### Running on a Schedule
This action is designed to be run on a cron schedule. In the example above, we're running the action once daily at midnight. For more information about the `schedule` trigger, refer to the [Events that trigger workflows](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#schedule) documentation.

### `dependencies.yml`
The `dependencies.yml` file expects a specific schema and validates that schema as part of the action run. An example `dependencies.yml` file can be referenced below:

```yaml
dependencies:
  yq:
    current_tag: v4.34.2
    repo: mikefarah/yq
    pr_note: "This note will be appended to any new pull request."

```

The `current_tag` value will be updated as part of the action and must match how those tags or releases exist in the repository. Similarly, a repository with the `<author>/<project>` defined in the `repo` field must already exist.

#### Sourcing from PECL

The action updater checks GitHub by default, which works if the GH release exists and is mirrored wherever you're sourcing your PHP extensions from. However, if you're sourcing from PECL, you can use the optional `source` key in `dependencies.yml` to explicitly check the PECL API. When sourcing from PECL, the vendor name in the `repo` is not used (since the vendor is PECL).

```yaml
dependencies:
  imagick:
    current_tag: 3.5.1
    repo: imagick
    source: pecl
```

Currently, the action supports GitHub and PECL projects exclusively. In the future, we may add support for additional `source`s. 