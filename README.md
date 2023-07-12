# Package Updater GitHub 

[![Test](https://github.com/pantheon-systems/action-package-updater/actions/workflows/test.yml/badge.svg)](https://github.com/pantheon-systems/action-package-updater/actions/workflows/test.yml)
[![Actively Maintained](https://img.shields.io/badge/Pantheon-Actively%20Maintained-yellow?logo=pantheon&color=FFDC28)](https://docs.pantheon.io/oss-support-levels#actively-maintained-support)
[![MIT License](https://img.shields.io/github/license/pantheon-systems/action-package-updater)](https://github.com/pantheon-systems/action-package-updater/blob/main/LICENSE)


A GitHub action that monitors a list of PHP extensions and opens PRs if newer versions exist. Monitors a `dependencies.yml` file that defines the current (known) tags and the (GitHub) repository and will check to see if updates are available. 

Optionally, this can be used to _also_ update version variables declared in a bash script based on those versions that are updated in `dependencies.yml`. Currently, an example of the expected syntax can be found in [`./fixtures/PHP_EXTENSION_VERSIONS`](https://github.com/pantheon-systems/action-package-updater/blob/main/fixtures/PHP_EXTENSION_VERSIONS).

