---
layout: wmt/docs
title:  Git and GitHub Task
side-navigation: wmt/docs-navigation.html
deprecated: true
description: Plugin for performing Git operations and GitHub API interaction
---


# {{ page.title }}

The Git plugin supports direct operations on git repositories with the `git`
task and interactions with git repositories hosted on GitHub with the `github`
task.

- [Usage](#usage)
- [Git Task](#git-task)
  - [Basic Authentication](#basic-authentication)
  - [Git Task Response](#git-task-response)
  - [Clone a Repository](#clone-a-repository)
  - [Pull](#pull)
  - [Commit and Push Changes](#commit-push)
  - [Create and Push a New Branch](#branch)
  - [Merge Local Branches](#merge-local-branches)
- [GitHub Task](#github-task)
  - [Common Task Parameters](#common-task-parameters)
  - [Create and Delete a Repository](#githubRepo)
  - [Create and Merge a Pull Request](#pr)
  - [Comment on a Pull Request](#commentPR)
  - [Close a Pull Request](#closePR)
  - [Create a Tag](#tag)
  - [Delete a Tag](#deleteTag)
  - [Delete a Branch](#deleteBranch)
  - [Merge Branches](#github-merge)
  - [Fork a Repo](#fork)
  - [Get Branch List](#getBranchList)
  - [Get Tag List](#getTagList)
  - [Get Pull Request](#getpr)
  - [Get Pull Request List](#getprlist)
  - [Get Latest Commit SHA](#getLatestSHA)
  - [Add a Status](#addStatus)

<a name="usage"/>

## Usage

To be able to use the plugin in a Concord flow, it must be added as a
[dependency](../processes-v1/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:git:{{ site.concord_plugins_version }}
```

This adds the Git plugin to the classpath and allows you to invoke the
[Git task](#git-task) or the [GitHub task](#github-task).

<a name="git"/>

## Git Task

The `git` task allows users to trigger git operations as a step of a flow. The
operations are run via git command usage in the process working directory on the
Concord server.

The `git` task uses a number of input parameters that are common for all
operations:

- `url`: required, the SSH or HTTPS URL of git repository
  - `auth`: Required for HTTPS `url` values, details in [Basic authentication](#basic-authentication)
  - `privateKey`: Required for SSH `url` values.
- `workingDir`: required, the name of the directory inside the process space on
  the Concord server into which the git repository is cloned before any
  operation is performed.
- `action`: required, the name of the operation to perform.
- `org` of the `privateKey` parameter: Optional - the name of the organization
  in Concord org where the secret can be located, if not specified defaults to
  `Default`.
- `secretName` of the `privateKey` parameter: required, the name of the Concord
  [secret](../api/secret.html) used for the SSH connection to the git
  repository on the remote server.
- `password` of the `privateKey` parameter: Optional, the password to decrypt the
  Concord [secret](../api/secret.html), if the secret is password protected.
  Otherwise not required.
- `ignoreErrors`: instead of throwing exceptions on operation failure, returns
  the result object with the error, if set to `true`.
- `out`: variable to store the [Git task response](#response).

Following is an example showing the common parameters with private key based authentication:

```yaml
flows:
  default:
  - task: git
    in:
      action: "actionName"
      url: "git@git.example.com:example-org/git-project.git"
      workingDir: "git-project"
      privateKey:
        org: "myGitHubOrg"
        secretName: "mySecret"
        password: "mySecretPassword" # optional
```

<a name="basic-authentication"/>

### Basic Authentication

The `auth` parameter is required when a private git repository is accessed with
HTTPS `url`. It must contain a `basic` nested element which contains either the
`token` element or the `username` and `password` elements.

Following example shows the common parameters with basic authentication using
`username` & `password`:

```yaml
flows:
  default:
  - task: git
    in:
      action: "actionName"
      url: "https://git.example.com/example-org/git-project.git"
      workingDir: "git-project"
      auth:
        basic:
          username: "any_username"
          password: "any_password"
```

Here is an example of using basic authentication with `token`:

```yaml
auth:
  basic:
    token: base64_encoded_auth_token
```

<a name="response"/>

### Git Task Response

The `git` task returns a result object with following fields:

- `ok`: `true` if the operation succeeded.
- `status`: `NO_CHANGES` if repository is clean, otherwise returns `SUCCESS` or
`FAILURE` if operation successful or failed respectively.
- `error`: error message if operation failed.
- `headSHA`: `HEAD` commit ID for the specified branch after performing the action.
- `changeList`: saves the list of uncommitted changes.

<a name="clone"/>

### Clone a Repository

The `clone` action of the `git` task can be used to clone a git repository into
the Concord server process space.

It simply uses the minimal common parameters with the addition of the
`baseBranch` parameter:

```yaml
flows:
  default:
  - task: git
    in:
      action: "clone"
      url: "git@git.example.com:example-org/git-project.git"
      workingDir: "git-project"
      privateKey:
        org: "myGitHubOrg"
        secretName: "mySecret"
        password: "mySecretPassword" # optional
      baseBranch: "feature-a"
      out: "response"
      ignoreErrors: true

  - if: "${!response.ok}"
    then:
    - log: "Clone action failed: ${response.error}"
```

The `baseBranch` parameter is optional and specifies the name of the branch, the
commit SHA identifier or the name of a tag, used to check out after the clone
operation. If not provided, the default branch of the repository is used -
typically called `master`.

<a name="pull"/>

### Pull

The `pull` action of the `git` task can be used to pull changes from another
branch from the remote `origin` into the current checked out branch.

It simply uses the minimal common parameters with the addition of the
`remoteBranch` parameter:

- `remoteBranch`: required, name of remote `origin/branch` from where the
  changes are pulled.

Below example is equivalent to `git pull origin myRemoteBranch`. In order to use
a `pull` action in your concord flow, you have to run a `clone` action first so
that a repository clone is available in the `workingDir`. The value for the
`workingDir` parameter should be same as what was used in `clone` action,
otherwise you end up with an `repository not found` exception.

```yaml
flows:
  default:
  - task: git
    in:
      action: "pull"
      workingDir: "git-project"
      remoteBranch: "myRemoteBranch"
      privateKey:
        org: "myGitHubOrg"
        secretName: "mySecret"
        password: "mySecretPassword" # optional
```

<a name="commit-push"/>

### Commit and Push Changes

The `commit` action of the `git` task can be used to commit your changes made on
the cloned repository. You can push the changes to origin by setting
`pushChanges` to `true`. The `commit` action is dependent on a prior `clone`
action, so make sure `clone` action is performed first.

```yaml
- task: git
  in:
    action: "commit"
    workingDir: "git-project"
    privateKey:
       org: "myGitHubOrg"
       secretName: "mySecret"
       password: "mySecretPassword" # optional
    baseBranch: "feature-a"
    commitMessage: "my commit message"
    commitUsername: "myUserId"
    commitEmail: "myEmail"
    pushChanges: true
    out: "response"

- if: "${response.ok}"
  then:
  - log: "Commit action completed successfully."
  - log: "New HEAD commit ID: ${response.headSHA}."
  - log: "My changeList: ${response.changeList}."
```

The `baseBranch` parameter is mandatory and specifies the name of the branch to
use to commit the changes. The `commitMessage` is a message to add to your
commit operation. The `pushChanges` parameter is optional and defaults to
`false`, when omitted. The `commitUsername` and `commitEmail` are mandatory
parameters to capture committer details.

The new commit ID is available in `${response.headSHA}`. A list of uncommitted
changes is available in `${response.changeList}`.

<a name="branch"/>

### Create and Push a New Branch

The `createBranch` action of the `git` task allows the creation of a new
branch in the process space. The new branch can be pushed back to the remote
origin. The following parameters are needed in addition to the general
parameters:

- `baseBranch`: Optional - the name of the branch to use as starting point for
the new branch. If not provided, the default branch of the repository is used -
typically called `master`.
- `newBranch`: required, the name of new branch.
- `pushBranch`: Required configuration to determine if the new branch
is pushed to the origin repository - `true` or `false`.

The following example creates a new feature branch called `feature-b` off the
`master` branch and pushes the new branch back to the remote origin.

```yaml
flows:
  default:
  - task: git
    in:
      action: "createBranch"
      url: "git@git.example.com:example-org/git-project.git"
      workingDir: "git-project"
      privateKey:
        org: "myGitHubOrg"
        secretName: "mySecret"
        password: "mySecretPassword" # optional
      baseBranch: "master"
      newBranch: "feature-b"
      pushBranch: true
      out: "response"

  - if: "${response.ok}"
    then:
    - log: "Create-branch action completed successfully."
```

<a name="merge"/>

### Merge Local Branches

The `merge` action of the `git` task can be used to merge branches using the
following parameters:

- `sourceBranch`: required, the name of the branch where your changes are
  implemented.
- `destinationBranch`: required, the name of the branch into which the branches
  have to be merged.

The following example merges the changes in the branch `feature-a` into the
`master` branch.

```yaml
flows:
  default:
  - task: git
    in:
      action: "merge"
      url: "git@git.example.com:example-org/git-project.git"
      workingDir: "git-project"
      privateKey:
        org: "myGitHubOrg"
        secretName: "mySecret"
        password: "mySecretPassword" # optional
      sourceBranch: "feature-a"
      destinationBranch: "master"
      out: "response"

  - if: "${response.ok}"
    then:
    - log: "Merge action completed successfully."
```

We recommend using the [merge action of the GitHub task](#github-merge) to merge
branches in large repositories, since no local cloning is required and the
action is therefore completed faster.

<a name="github"/>

## GitHub Task

The `github` task of the git plugin allows you to trigger git operations on a
git repository hosted on [GitHub.com](https://github.com/) or a GitHub
Enterprise server as a step of a flow.

While the `git` mentioned above works on a repository by cloning it to the
Concord server and performing operations locally, the `github` task uses the
REST API of GitHub to perform the operations. This avoids the network overhead
of the cloning and other operations and is therefore advantageous for large
repositories.

The `apiUrl` configures the GitHub API endpoint. It is best configured globally as
[default process configuration](../getting-started/configuration.html#default-process-variables):
with a `githubParams` argument:

```yaml
configuration:
  arguments:
    githubParams:
      apiUrl: "https://github.example.com/api/v3"
```

The authors of specific projects on the Concord server can then specify the
remaining parameters:

- `accessToken`: required, the GitHub
  [access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/).
- `org`: required, the name of the GitHub organization or user in which the git
  repository is located.
- `repo`: required, the name of the git repository.

The following example includes a locally defined `apiUrl`:

```yaml
flows:
  default:
  - task: github
    in:
      action: "createPr"
      apiUrl: "https://github.example.com/api/v3"
      accessToken: "myGitHubToken"
      org: "myGitHubOrg"
      repo: "myGitHubRepo"
```

Examples below take advantage of a globally configured `apiUrl`.

<a name="githubRepo"/>

## Create and Delete a Repository

The `createRepo` and `deleteRepo` actions of the `github` task allow the creation
and deletion of GitHub repositories.

`createRepo` action creates an empty repository with the name provided by `repo`
parameter in the GitHub organization specified by `org` parameter.

**`createRepo` and `deleteRepo` Parameters:**

- `org` - GitHub organization in which to create or delete the repository
- `repo` - Repository name to create or delete

**`createRepo` Returned Variables:**

- `cloneUrl` - URL from which the repository can be cloned

The example below creates a repository `myRepository` in the GitHub
organization `myOrg`.

```yaml
flows:
  default:
  - task: github
    in:
      action: "createRepo"
      apiUrl: "https://github.example.com/api/v3"
      accessToken: "myGitHubToken"
      org: "myRepository"
      repo: "myOrg"

  - log: "New repository: ${cloneUrl}"
```

`deleteRepo` action deletes the repository with the name provided by `repo`
parameter in the GitHub organization specified by `org` parameter.

> GitHub access token specified should have `delete_repo` scope
enabled to delete a repository on GitHub. This can be done in
**Personal Access Token** under **Developer Settings** for the intended user
on GitHub.

The example below deletes the repository `myRepository` from the GitHub
organization `myOrg`.

```yaml
flows:
  default:
  - task: github
    in:
      action: "deleteRepo"
      apiUrl: "https://github.example.com/api/v3"
      accessToken: "myGitHubToken"
      org: "myRepository"
      repo: "myOrg"
```

A few points to consider:

* both `createRepo` and `deleteRepo` actions are idempotent.
  * `createRepo` action does not fail if the repository already exists in
  an organization, but returns the clone URL of the repository.
  * similarly, `deleteRepo` action does not fail if the repository does
  not exist in the organization.
* `createRepo` action can be supplemented by other `git` and `github` task
actions to commit code/documentation, and configure the repository.
* `deleteRepo` action is irreversible. The repository, its contents and the
commit history will be deleted, and cannot be recovered.

<a name="pr"/>

## Create and Merge a Pull Request

The `createPr` and `mergePr` actions of the `github` task allow the creation and
merging a pull request in GitHub. Executed one after another, the tasks can be
used to create and merge a pull request within one Concord process.

**`createPr` Parameters:**

- `org`: name of GitHub organization where your repository is located.
- `repo`: repository in which to create the pull request.
- `prTitle`: the title used for the pull request.
- `prBody`: the description body for the pull request.
- `prSourceBranch`: the name of the branch from where changes are implemented.
- `prDestinationBranch`: the name of the branch into which the changes are merged.

**`createRepo` Returned Variables:**

- `prId` - int, pull request number.

The example below creates a pull request to merge the changes from branch
`feature-a` into the `master` branch:

```yaml
flows:
  default:
  - task: github
    in:
      action: "createPr"
      accessToken: "myGitHubToken"
      org: "myGitHubOrg"
      repo: "myGitHubRepo"
      prTitle: "Feature A"
      prBody: "Feature A implements the requirements from request 12."
      prSourceBranch: "feature-a"
      prDestinationBranch: "master"
    out:
      myPrId: "${prId}"
```

The `mergePr` action can be used to merge a pull request. The pull request
identifier has to be known to perform the action. It can be available from a
form value, an external invocation of the process or as output parameter from
the `createPr` action. The example below uses the pull request identifier `myPrId`,
that was populated with a value in the `createPr` action above.
`commitMessage` is a string that can be used to post custom merge commit messages.
If omitted, a default message is used. `mergeMethod` is optional string that can be used to
specify merge method to use (possible values are `merge`, `squash` or `rebase`).

**`mergePr` Parameters:**

- `org`: name of GitHub organization where your repository is located.
- `repo`: repository in which the pull request is located.
- `prId`: pull request number.
- `commitMessage`: optional, Custom merge commit message.
- `mergeMethod`: optional, one of are `merge`, `squash` or `rebase`

```yaml
flows:
  default:
  - task: github
    in:
      action: "mergePr"
      accessToken: "myGitHubToken"
      org: "myGitHubOrg"
      repo: "myGitHubRepo"
      prId: "${myPrId}"
      commitMessage: "my custom merge commit message"
      mergeMethod: "squash"
```

<a name="commentPR">

## Comment on a Pull Request

The `commentPR` action can be used to add a comment to a pull request.

The pull request identifier has to be known to perform the action. It can be
available from a form value, an external invocation of the process or as output
parameter from the `createPr` action.

The example below uses the pull request identifier `myPrId`, that was populated
with a value in the `createPr` action above. `prComment` is the string that is
posted to the pull request as a comment. The `accessToken` used determines the
user adding the comment.

**`commentPR` Parameters:**

- `org`: GitHub organization in which to create the repository.
- `repo`: repository in which the pull request is located.
- `prId`: pull request number.
- `prComment`: comment text.

```yaml
flows:
  default:
  - task: github
    in:
      action: "commentPR"
      accessToken: "myGitHubToken"
      org: "myGitHubOrg"
      repo: "myGitHubRepo"
      prId: "${myPrId}"
      prComment: "Some pr comment"
```

<a name="closePR"/>

### Close a Pull Request

The `closePR` action can be used to close a pull request. The pull request
identifier has to be known to perform the action. It can be available from a
form value, an external invocation of the process or as output parameter from
the `createPr` action. The example below uses the pull request identifier `myPrId`,
that was populated with a value in the `createPr` action above.

**`closePR` Parameters:**

- `org`: name of GitHub organization where your repository is located.
- `repo`: repository in which the pull request is created.
- `prId`: pull request number.

```yaml
flows:
  default:
  - task: github
    in:
      action: "closePR"
      accessToken: "myGitHubToken"
      org: "myGitHubOrg"
      repo: "myGitHubRepo"
      prId: "${myPrId}"
```

<a name="tag"/>

### Create a Tag

The `createTag` action of the `github` task can create a tag based on a specific
commit SHA. This commit identifier has to be supplied to the Concord flow -
typically via a parameter from a form or an invocation of the flow from another
application. One example is the usage of the Concord task in the Looper
continuous integration server.

**`createTag` Parameters:**

- `org`: name of GitHub organization where your repository is located.
- `repo`: repository in which to create the tag.
- `commitSHA`: the SHA of the git commit to use for the tag creation.
- `tagVersion`: the name of the tag e.g. a version string `1.0.1`.
- `tagMessage`: the name of the author of the tag.
- `tagAuthorName`: the email of the author of the tag.

```yaml
flows:
  default:
  - task: github
    in:
      action: "createTag"
      accessToken: "myGitHubToken"
      org: "myGitHubOrg"
      repo: "myGitHubRepo"
      tagVersion: "1.0.0"
      tagMessage: "Release 1.0.0"
      tagAuthorName: "Jane Doe"
      tagAuthorEmail: "jane@example.com"
      commitSHA: "${gitHubBranchSHA}"
```

<a name="deleteTag"/>

### DeleteTag

The `deleteTag` action of the `github` task can be used to delete an existing
`tag` from GitHub repository

**`deleteTag` Parameters:**

- `org`: name of GitHub organization where your repository is located.
- `repo`: name of GitHub repository where your tag is located.
- `tagName`: name of `tag` that you want to delete from your `org/repo`.

```yaml
flows:
  default:
  - task: github
     in:
       action: "deleteTag"
       accessToken: "myGitHubToken"
       org: "myGitHubOrg"
       repo: "myGitHubRepo"
       tagName: "myTagName"
```

<a name="deleteBranch"/>

### DeleteBranch

The `deleteBranch` action of the `github` task can be used to delete an existing
`branch` from GitHub repository

**`deleteBranch` Parameters:**

- `org`: name of GitHub organization where your repository is located.
- `repo`: name of GitHub repository where your tag is located.
- `branch`: name of the branch that you want to delete.

```yaml
flows:
  default:
  - task: github
     in:
       action: "deleteBranch"
       accessToken: "myGitHubToken"
       org: "myGitHubOrg"
       repo: "myGitHubRepo"
       branch: myBranchName
```

<a name="github-merge"/>

### Merge Branches

The `merge` action of the `github` task can merge two branches of a repository
on GitHub. Compared to [merging branches with the git](#merge) task, it does not
require a local clone of the repository and is therefore faster in the execution
and requires no local storage on the Concord server.

The parameters identifying the branches to merge have to be supplied to the
Concord flow - typically by a parameter from a form or an invocation of the flow
from another application.

**`merge` Parameters:**

- `org`: name of GitHub organization where your repository is located
- `repo`: repository in which the pull request is located.
- `base`: the name of the base branch into which the head is merged.
- `head`: the identifier for the head to merge. Head can be specified
  by using a branch name or a commit SHA1.
- `commitMessage`: the message to use for the merge commit. If
  omitted, a default message is used. Expressions can be used to add process
  information.

```yaml
flows:
  default:
  - task: github
    in:
      action: "merge"
      accessToken: "myGitHubToken"
      org: "myGitHubOrg"
      repo: "myGitHubRepo"
      base: "master"
      head: "${gitHubBranchName}"
      commitMessage: "Automated merge performed by Concord flow."
```

<a name="fork"/>

### Fork

The `forkRepo` action can be used to fork a git repository on GitHub. By
default, the `repo` is forked into your personal account associated with the
`accessToken`.

**`forkRepo` Parameters:**

- `org`: name of GitHub organization where your repository is located.
- `repo`: name of GitHub repository that you want to fork.
- `targetOrg`: optional, if a value is specified the repository is forked into
  specified organization, otherwise the target is the personal space of the user
  specified with the `accessToken`.

```yaml
flows:
  default:
  - task: github
    in:
      action: "forkRepo"
      accessToken: "myGitHubToken"
      org: "myGitHubOrg"
      repo: "myGitHubRepo"
      targetOrg: "myForkToOrg"
```

<a name="getBranchList"/>

### GetBranchList

The `getBranchList` action can be used to get the list of  branches of a GitHub
repository. The output of the action is stored in a variable `branchList`. It
can be used at a later point in the flow

**`getBranchList` Parameters:**

- `org`: name of GitHub organization where your repository is located.
- `repo`: name of GitHub repository for which you want to get the
  branch list.

**`getBranchList` Returned Variables:**

- `branchList` - list, branches from the specified repository

```yaml
flows:
  default:
  - task: github
    in:
      action: getBranchList
      accessToken: "myGitHubToken"
      org: "myGitHubOrg"
      repo: "myGitHubRepo"

  - log: "Got ${branchList.size()} branches: ${branchList}"
```

<a name="getTagList"/>

### GetTagList

The `getTagList` action can be used to get the  list of tags of a GitHub
repository. The output of the action is stored in a variable `tagList`. It can be
used at a later point in the flow.

**`getTagList` Parameters:**

- `org`: name of GitHub organization where your repository is located.
- `repo`: name of GitHub repository for which you want to get the tag list.

**`getTagList` Returned Variables:**

- `tagList` - list, tagList from the specified repository

```yaml
flows:
  default:
  - task: github
    in:
      action: "getTagList"
      accessToken: "myGitHubToken"
      org: "myGitHubOrg"
      repo: "myGitHubRepo"

  - log: "Got ${tagList.size()} tags: ${tagList}"
```

<a name="getPR"/>

### GetPR

The `getPR` action can be used to get a specific PR from a GitHub repository.
The output of the action is stored in a variable `pr`,
containing the  `PullRequest` details. It can be used at a later point in the flow.

**`getPR` Parameters:**

- `org`: name of GitHub organization.
- `repo`: name of GitHub repository.
- `prNumber`: pull request number to get.

**`getPR` Returned Variables:**

- `pr` - object, pull request details. See [Pulls docs](https://docs.github.com/en/rest/reference/pulls#get-a-pull-request--code-samples)
  for more details.

```yaml
flows:
  default:
  - task: github
    in:
      action: "getPR"
      accessToken: "myGitHubToken"
      org: "myGitHubOrg"
      repo: "myGitHubRepo"
      prNumber: 123

  - log: "PR HEAD SHA: ${pr.head.sha}"
```

<a name="getPRList"/>

### GetPRList

The `getPRList` action can be used to get the list of PRs from a GitHub
repository. The output of the action is stored in a variable `prList`,
which is a list of `PullRequest` values. It can be used at a later point in the flow.

**`getPRList` Parameters:**

- `org`: name of GitHub organization.
- `repo`: name of GitHub repository.
- `state`: optional, state of a PR. Defaults to `open`. Allowed values are `all`,
  `open`, `closed`.

**`getPRList` Returned Variables:**

- `prList`: list of pull request objects. See
  [Pulls docs](https://docs.github.com/en/rest/reference/pulls#list-pull-requests--code-samples)
  for more details.

```yaml
flows:
  default:
  - task: github
    in:
      action: getPRList
      accessToken: "myGitHubToken"
      org: "myGitHubOrg"
      repo: "myGitHubRepo"
      state: "closed"
  - if: ${prList.isEmpty()}
    then:
    - log: "Got zero PRs"
    else:
    - log: "PR Numbers : ${prList.stream().map(c -> c.get('number')).toList()}"
    - log: "PR Titles: ${prList.stream().map(c -> c.get('title')).toList()}"
```

<a name="getLatestSHA"/>

### GetLatestSHA

The `getLatestSHA` action can be used to get the SHA identifier of the latest commit
for a given branch. By default, it gets the SHA from the `master` branch. The
output of the action is stored in the variable `latestCommitSHA`. It can be used
at a later point in the flow.

**`getLatestSHA` Parameters:**

- `org`: name of GitHub organization.
- `repo`: name of GitHub repository.
- `branch`: name of GitHub branch from which you want to get the latest commit
  SHA. Defaults to `master`.

**`getLatestSHA` Returned Variables:**

- `latestCommitSHA`: SHA of the latest commit in the specified branch

```yaml
flows:
  default:
  - task: github
    in:
      action: "getLatestSHA"
      accessToken: "myGitHubToken"
      org: "myGitHubOrg"
      repo: "myGitHubRepo"
      branch: "myBranch"

  - log: "Latest commit SHA: ${latestCommitSHA}"
```

<a name="addStatus"/>

### AddStatus

The `addStatus` action can be used to add status messages to a commit.

**`addStatus` Parameters:**

- `org`: name of GitHub organization where your repository is located.
- `repo`: name of GitHub repository.
- `commitSHA`: ID of the commit which should receive the status update.
- `context`, `state`, `targetUrl` and `description`: attributes of the status
  update. See [the GitHub API documentation](https://developer.github.com/v3/repos/statuses/#parameters)
  for details.

```yaml
flows:
  default:
  - task: github
    in:
      action: "addStatus"
      accessToken: "myGitHubToken"
      org: "myGitHubOrg"
      repo: "myGitHubRepo"
      commitSHA: "dfd5...0262"
      context: "myContext"
      state: "pending"
      targetUrl: "https://concord.example.com/#/process/${txId}"
      description: "my status description"
```
