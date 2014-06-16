# Changely [![Build Status](https://travis-ci.org/rdumont/changey.svg?branch=master)](https://travis-ci.org/rdumont/changey)

Creates GitHub releases with an automatic change log.


## Installation

```bash
$ npm install -g changey
```


## Usage

```bash
$ changey <repo> <version> [options] -t <accessToken>
```

### Arguments
* `<repo>` is the GitHub repository, such as `rdumont/changey`.
* `<version>` is the version for which you want to create a release, such as `0.1.0`.
* `<accessToken>` is the GitHub access token used to authorize the API requests.
  This token should have push rights to the target repository.

### Options
* `--config`, or `-c`: path to the configuration file. The default is `_changey.yaml`,
  although it will still work if the file doesn't exist.
* `--dry-run`: Instead of creating the release, will simply log the results to the console.

### Example

```bash
$ changey jekyll/jekyll 2.0.2 -t $GH_TOKEN --dry-run
Build changelog for v2.0.2 of jekyll/jekyll
. getting latest stable release
. found release v2.0.0
. getting issues closed since 2014-05-07T01:22:48Z
. found 45 issues
. creating GitHub release for v2.0.2
. the following release would have been created
tag_name: v2.0.2
name: 2.0.2
prerelease: false
body: |
  ### Bugs
  #2204 - Cleaner removes directory if it only contain subdirectories
  #1297 - Directories in keep_files are cleaned if their parent is empty
  #1870 - All files are regenerated if the destination is inside the source
```


## Configuration

The configuration file is `./_changey.yaml` by default. If the file doesn't exist, it will be ignored. Here are all the options available for configuration:

```yaml
groups:
  - heading: Features
    labels: [ feature, enhancement ]
  - heading: Bugs
    labels: [ bug ]
  - heading: Chores
    labels: [ chore, task ]

exclude:
  users: [ somebot, anotheruser ]

include:
  users: [ acooluser ]
```

### Groups

Groups are used as issue sections in the change log. The default groups are `Features`, `Bugs` and `Chores`, as shown above. These values can be overridden in the configuration files.

For each group there are two values: **heading** and **labels**. Headings will define the section title to be shown in the change log. For each group the issues will be grouped by the labels that they have.

### Include and exclude

The `include` and the `exclude` configurations are mutually exclusive. If none is specified, all issues in the release will be considered. If `include` is specified, **only the matching** issues will be considered. If `exclude` is used, then all issues **except for the matching** ones will be considered.

For now, only one matching rule is available, which is `users`. The value should be an array of user names to match against the user that created the issue. This is useful, for instance, when you have a bot user that opens issues that you would like to ignore in the change log. 


## FAQ

**What issues are initially considered?**
All issues that were closed since the last release of the same type as the current one (prerelease or not), excluding pull requests.