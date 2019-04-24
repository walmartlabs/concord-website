---
layout: wmt/docs
title:  Git and GitHub Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The Git plugin supports direct operations on git repositories with the `git`
task and interactions with git repositories hosted on GitHub with the `github`
task.

- [Usage](#usage)
- [Git Task](#git-task)
  - [Clone a Repository](#clone)
  - [Commit and Push Changes](#commit-push)
  - [Create and Push a New Branch](#branch)
  - [Merge Branches](#merge)
- [GitHub Task](#github-task)
  - [Create and Merge a Pull Request](#pr)
  - [Comment on a Pull Request](#commentPR)
  - [Close a Pull Request](#closePR)
  - [Create a Tag](#tag)
  - [Merge Branches](#github-merge)
  - [Fork a Repo](#fork)
  - [Get Branch List](#getBranchList)
  - [Get Tag List](#getTagList)
  - [Get Latest Commit SHA](#getLatestSHA)
  
<a name="usage"/>

## Usage

To be able to use the plugin in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

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

- `url`: Required - the SSH or HTTPS URL of git repository
  - `auth`: Required for HTTPS `url` values, details in [Basic authentication](#basic-authentication)
  - `privateKey`: Required for SSH `url` values.
- `workingDir`: Required - the name of the directory inside the process space on
  the Concord server into which the git repository is cloned before any
  operation is performed.
- `action`: Required - the name of the operation to perform.
- `org` of the `privateKey` parameter: Optional - the name of the organization
  in Concord org where the secret can be located, if not specified defaults to
  `Default`.
- `secretName` of the `privateKey` parameter: Required - the name of the Concord
  [secret](../api/secret.html) used for the SSH connection to the git 
  repository on the remote server.
- `ignoreErrors`: instead of throwing exceptions on operation failure, returns
  the result object with the error, if set to `true`.
- `out`: variable to store the [Git task response](#response).

Following is an example showing the common parameters with private key based authentication:

```yaml
flows:
  default:
  - task: git
    in:
      action: actionName
      url: "git@git.example.com:example-org/git-project.git"
      workingDir: "git-project"
      privateKey:
        org: myOrg
        secretName: mySecret
```

<a name="basic-authentication"/>

## Basic Authentication

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
      action: actionName
      url: "https://git.example.com/example-org/git-project.git"
      workingDir: "git-project"
      auth:
        basic:
          username: any_username
          password: any_password
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
      action: clone
      url: "git@git.example.com:example-org/git-project.git"
      workingDir: "git-project"
      privateKey:
        org: myOrg
        secretName: mySecret
      baseBranch: feature-a
      out: response
      ignoreErrors: true

  - if: "${!response.ok}"
      then:
       - log: "Clone action failed: ${response.error}"
```

The `baseBranch` parameter is optional and specifies the name of the branch to
use check out after the clone operation. If not provided, the default branch of
the repository is used - typically called `master`.

<a name="commit-push"/>

### Commit and Push Changes

The `commit` action of the `git` task can be used to commit your changes made on
the cloned repository. You can push the changes to origin by setting
`pushChanges` to `true`. The `commit` action is dependent on a prior `clone`
action, so make sure `clone` action is performed first.


```yaml
- task: git
    in:
      action: commit
      workingDir: "git-project"
      privateKey:
         org: myOrg
         secretName: mySecret
      baseBranch: feature-a
      commitMessage: "my commit message"
      commitUsername: myUserId
      commitEmail: myEmail
      pushChanges: true
      out: response

- if: "${response.ok}"
      then:
       - log: "Commit action completed successfully."
```

The `baseBranch` parameter is mandatory and specifies the name of the branch to
use to commit the changes. The `commitMessage` is a message to add to your
commit operataion. The `pushChanges` parameter is optional and defaults to
`false`, when omitted. The `commitUsername` and `commitEmail` are mandatory
parameters to capture committer details.

<a name="branch"/>

## Create and Push a New Branch

The `createBranch` action of the `git` task allows the creation of a new
branch in the process space. The new branch can be pushed back to the remote
origin. The following parameters are needed in addition to the general
parameters:

- `baseBranch`: Optional - the name of the branch to use as starting point for
the new branch. If not provided, the default branch of the repository is used -
typically called `master`.
- `newBranch`: Required - the name of new branch.
- `pushBranch`: Required configuration to determine if the new branch
is pushed to the origin repository - `true` or `false`.

The following example creates a new feature branch called `feature-b` off the
`master` branch and pushes the new branch back to the remote origin.

```yaml
flows: default:
  - task: git
    in:
      action: createBranch
      url: "git@git.example.com:example-org/git-project.git"
      workingDir: "git-project"
      privateKey:
        org: myOrg
        secretName: mySecret
      baseBranch: master
      newBranch: feature-b
      pushBranch: true
      out: response

  - if: "${response.ok}"
        then:
         - log: "Create-branch action completed successfully."
```

<a name="merge"/>

## Merge Branches

The `merge` action of the `git` task can be used to merge branches using the
following parameters:

- `sourceBranch`: Required - the name of the branch where your changes are
  implemented.
- `destinationBranch`: Required - the name of the branch into which the branches
  have to be merged.

The following example merges the changes in the branch `feature-a` into the
`master` branch.

```yaml
flows:
  default:
  - task: git
    in:
      action: merge
      url: "git@git.example.com:example-org/git-project.git"
      workingDir: "git-project"
      privateKey:
        org: myOrg
        secretName: mySecret
      sourceBranch: feature-a
      destinationBranch: master
      out: response

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

The `apiUrl` configures the GitHub API endpoint. It is best configured globally
as 
[default process configuration](../getting-started/configuration.html#default-process-variable):
with a `githubParams` argument:

```yaml
configuration:
  arguments:
    githubParam:
      apiUrl: "https://github.example.com/api/v3"
```

The authors of specific projects on the Concord server can then specify the
remaining parameters:
  
- `accessToken`: Required - the GitHub
  [access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/).
- `org`: Required - the name of the GitHub organization or user in which the git
  repository is located.
- `repo`: Required - the name of the git repository.

The following example includes a locally defined `apiUrl`:

```yaml
flows:
  default:
  - task: github
    in:
      action: createPr
      apiUrl: "https://github.example.com/api/v3"
      accessToken: myGitToken
      org: myOrg
      repo: myRepo
```

Examples below take advantage of a globally configured `apiUrl`.

<a name="pr"/>

## Create and Merge a Pull Request

The `createPr` and `mergePr` actions of the `github` task allow the creation and
merging a pull request in GitHub. Executed one after another, the tasks can be
used to create and merge a pull request within one Concord process.

The following parameters are needed by the `createPr` action:

- `prTitle`: Required - the title used for the pull request.
- `prBody`: Required - the description body for the pull request.
- `prSourceBranch`: Required - the name of the branch from where your changes
  are implemented.
- `prDestinationBranch`: Required - the name of the branch into which the
  changes are merged.

The example below creates a pull request to merge the changes from branch
`feature-a` into the `master` branch:

```yaml
flows:
  default:
  - task: github
    in:
      action: createPr
      accessToken: myGitToken
      org: myOrg
      repo: myRepo
      prTitle: "Feature A"
      prBody: "Feature A implements the requirements from request 12."
      prSourceBranch: feature-a
      prDestinationBranch: master
    out:
      prId: ${myPrId}
```

The `mergePr` action can be used to merge a pull request. The pull request
identifier has to be known to perform the action. It can be available from a
form value, an external invocation of the process or as output parameter from
the `createPr` action. The example below uses the pull request identifier `myPrId`,
that was populated with a value in the `createPr` action above.

```yaml
flows:
  default:
  - task: github
    in:
      action: mergePr
      accessToken: myGitToken
      org: myOrg
      repo: myRepo
      prId: ${myPrId}
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

```yaml
flows:
  default:
  - task: github
    in:
      action: commentPR
      accessToken: myGitToken
      org: myOrg
      repo: myRepo
      prId: ${myPrId}
      prComment: "Some pr comment"
```

<a name="closePR"/>

## Close a Pull Request

The `closePR` action can be used to close a pull request. The pull request
identifier has to be known to perform the action. It can be available from a
form value, an external invocation of the process or as output parameter from
the `createPr` action. The example below uses the pull request identifier `myPrId`,
that was populated with a value in the `createPr` action above.

```yaml
flows:
  default:
  - task: github
    in:
      action: closePR
      accessToken: myGitToken
      org: myOrg
      repo: myRepo
      prId: ${myPrId}
```

<a name="tag"/>

## Create a Tag

The `createTag` action of the `github` task can create a tag based on a specific
commit SHA. This commit identifier has to be supplied to the Concord flow -
typically via a parameter from a form or a invocation of the flow from another
application. One example is the usage of the Concord task in the Looper
continuous integration server.

- `commitSHA`: Required - the SHA of the git commit to use for the tag creation.
- `tagVersion`: Required - the name of the tag e.g. a version string `1.0.1`.
- `tagMessage`: Required - the message associated with the tagging.
- `tagAuthorName`: Required - the name of the author of the tag.
- `tagAuthorEmail`: Required - the email of the author of the tag.


```yaml
flows:
  default:
  - task: github
    in:
      action: createTag
      accessToken: myGitToken
      org: myOrg
      repo: myRepo
      tagVersion: 1.0.0
      tagMessage: "Release 1.0.0"
      tagAuthorName: "Jane Doe"
      tagAuthorEmail: jane@example.com
      commitSHA: ${gitHubBranchSHA}
```

<a name="github-merge"/>

## Merge Branches

The `merge` action of the `github` task can merge two branches of a repository
on GitHub. Compared to [merging branches with the git](#merge) task, it does not
require a local clone of the repository and is therefore faster in the execution
and requires no local storage on the Concord server.

The parameters identifying the branches to merge have to be supplied to the
Concord flow - typically by a parameter from a form or a invocation of the flow
from another application. One example is the usage of the Concord task in the
Looper continuous integration server.

- `base`: Required - the name of the base branch into which the head is merged.
- `head`: Required - the identifier for the head to merge. Head can be specified
  by using a branch name or a commit SHA1.
- `commitMessage`: Required - - the message to use for the merge commit. If
  omitted, a default message is used. Expressions can be used to add process
  information.

```yaml
flows:
  default:
  - task: github
    in:
      action: merge
      accessToken: myGitToken
      org: myOrg
      repo: myRepo
      base: master
      head: ${gitHubBranchName}
      commitMessage: "Automated merge performed by Concord flow."
```

<a name="fork"/>

## Fork

The `forkRepo` action can be used to fork a git repository on GitHub. By
default, the `repo` is forked into your personal account asscociated with the
`accessToken`.

The following parameters are needed in addition to the general parameters:

- `org`: Required, name of GitHub organization where your repository is located
- `repo`: Required, name of GitHub repository that you want to fork
- `targetOrg`: optional, if a value is specified the repository is forked into
  specified organization, otherwise the target is the personal space of the user
  specified with the `accessToken`

```yaml
flows:
  default:
  - task: github
    in:
      action: forkRepo
      accessToken: myGitToken
      org: myOrg
      repo: myRepo
      targetOrg: myforkToOrg
```

<a name="getBranchList"/>

## GetBranchList

The `getBranchList` action can be used to get the list of  branches of a GitHub
repository. The output of the action is stored in a variable `branchList`. It
can used at later point in the flow

The following parameters are needed in addition to the general parameters:

- `org`: Required, name of GitHub organization where your repository is located
- `repo`: Required, name of GitHub repository for which you want to get the
  branch list

```yaml
flows:
  default:
  - task: github
    in:
      action: getBranchList
      accessToken: myGitToken
      org: myOrg
      repo: myRepo
```

<a name="getTagList"/>

## GetTagList

The `getTagList` action can be used to get the  list of tags of a GitHub
repository. The output of the action is stored in a variable `tagList`. It can
used at later point in the flow.

The following parameters are needed in addition to the general parameters:

- `org`: Required, name of GitHub organization where your repository is located
- `repo`: Required, name of GitHub repository for which you want to get the tag
  list

```yaml
flows:
  default:
  - task: github
    in:
      action: getTagList
      accessToken: myGitToken
      org: myOrg
      repo: myRepo
```

<a name="getLatestSHA"/>

## GetLatestSHA

The `getLatestSHA` action can be used to get the SHA identifier of latest commit
for a given branch. By default, it gets the SHA from the `master` branch. The
output of the action is stored in the variable `latestCommitSHA`. It can used at
later point in the flow.

The following parameters are needed in addition to the general parameters:

- `org`: Required, name of GitHub organization where your repository is located
- `repo`: Required, name of GitHub repository
- `branch`: name of Github branch from which you want to get the latest commit
  SHA. Defaults to `master`

```yaml
flows:
  default:
  - task: github
    in:
      action: getLatestSHA
      accessToken: myGitToken
      org: myOrg
      repo: myRepo
      branch: myBranch
```
