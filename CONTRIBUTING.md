# Contributing

## Releases
New releases are tagged and released automatically on merge to main with [autotag](https://github.com/pantheon-systems/autotag) and the `gh` CLI tool. See [Autotag's README](https://github.com/pantheon-systems/autotag#scheme-autotag-default) for details of how to annotate commit messages to denote major, minor, or patch version bumps.

### Releasing to GitHub Action Marketplace
The release automation creates the tag and release, but `gh` cannot actually publish to the marketplace. To update the version available in the GitHub Marketplace, click the edit buttion on the latest release on the ["Release" page](https://github.com/pantheon-systems/validate-readme-spacing/releases) then on the edit page, check "Publish this Action to the GitHub Marketplace" and then click _Update Release_.