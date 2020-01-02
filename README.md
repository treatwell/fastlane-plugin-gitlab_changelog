# gitlab_changelog plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-gitlab_changelog)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-gitlab_changelog`, add it to your project by running:

```bash
fastlane add_plugin gitlab_changelog
```

## About gitlab_changelog

Get commit changelog using GitLab API

Plugin is particularly useful if you use [Shallow Cloning](https://docs.gitlab.com/ee/ci/large_repositories/#shallow-cloning) and have small number, like `GIT_DEPTH: "1"`, setting in your GitLab CI config.

In such case, `Fastlane's` native [`changelog_from_git_commits`](https://docs.fastlane.tools/actions/changelog_from_git_commits/#changelog_from_git_commits) action is not helpful, because CI machine does not have a full git history to construct a changelog.

This plugin resolves latest release branch using [`git ls-remote`](https://git-scm.com/docs/git-ls-remote.html) (always available).

```bash
git ls-remote --sort='v:refname' --heads origin refs/heads/release/*```
```
refs/heads/release/4.267.0
refs/heads/release/4.269.0
refs/heads/release/4.269.1
refs/heads/release/4.270.0
refs/heads/release/4.270.1

And then, fetches a changelog (JSON) between the current branch and the latest release branch using [`GitLab API`](https://docs.gitlab.com/ee/api/repositories.html#compare-branches-tags-or-commits).

In a case then CI _is_ on release branch currently - a changelog between current and previous release branches is constructed.

## Usage:
```
change_log = gitlab_changelog(
    current_branch: "develop",
    compare_branch_prefix: "release",
    gitlab_API_baseURL: "http://git.yourcompany.net/api/v4",
    gitlab_project_id: "123",
    gitlab_API_token: "secret_gitlab_token" 
  )
 ```
 
 **Params:**
 * _current_branch_ : `Actions.git_branch` or `ENV['CI_COMMIT_REF_NAME']` (default)
 * _compare_branch_prefix_ : default is `release` to compare against `release/*.*.*` branches
 * _gitlab_API_baseURL_ : a root URL for your GitLab API
 * _gitlab_project_id_ : `ENV['CI_PROJECT_ID']` (default)
 * _gitlab_API_token_ : Create a GitLab API Token and define it as a variable on your CI environment like `ENV['MY_GITLAB_API_TOKEN']`

 **Output:**
 _Fetching changeLog from: release/4.270.1 to: develop (GET http://git.yourcompany.net/api/v4/projects/123/repository/compare)_
 
 DEV0001 Feature 2 (Thom Yorke) 2019-12-31
 DEV0002 Feature 1 (Jonny Greenwood) 2019-12-30

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

