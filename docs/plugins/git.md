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
  - [Create and Push a New Branch](#branch)
  - [Merge Branches](#merge)
- [GitHub Task](#github-task)
  
<a name="usage"/>
## Usage

To be able to use the plugin in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:git-task:0.42.1
```

This adds the Git plugin to the classpath and allows you to invoke the
[Git task](#git-task) or the [GitHub task](#github-task).

## Git Task

The `git` task allows users to trigger git operations as a step of a flow. The
operations are run via git command usage on the Concord server in the process
execution space.

The `git` task uses a number of input parameters that are common for all
operations:

- `url`: Required - the SSH URL of git repository
- `workingDir`: Required - the name of the directory inside the process space on
  the Concord server into which the git repository is cloned before any
  operation is performed.
- `action`: Required - the name of the operation to perform.
- `org` of the `privateKey` parameter: Optional - the name of the organization
  in Concord org where the secret can be located, if not specified defaults to
  `Default`.
- `secretName` of the `privateKey` parameter: Required - the name of the Concord
  secret used for the SSH connection to the git repository on the remote server.

Following is an example showing the common parameters:

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
```

The `baseBranch` parameter is optional and specifies the name of the branch to
use check out after the clone operation. If not provided, the default branch of
the repository is used - typically called `master`.

<a name="branch"/>
## Create and Push a New Branch

The `createNewBranch` action of the `git` task allows the creation of a new
branch in the process space. The new branch can be pushed back to the remote
origin. The following parameters are needed in addition to the general
parameters:

- `baseBranch`: Optional - the name of the branch to use as starting point for
the new branch. If not provided, the default branch of the repository is used -
typically called `master`.
- `newBranchName`: Required - the name of new branch.
- `pushNewBranchToOrigin`: Required configuration to determine if the new branch
is pushed to the origin repository - `true` or `false`.

The following example creates a new feature branch called `feature-b` off the
`master` branch and pushes the new branch back to the remote origin.

```yaml
flows: default:
  - task: git
    in:
      action: createNewBranch
      url: "git@git.example.com:example-org/git-project.git"
      workingDir: "git-project"
      privateKey:
        org: myOrg
        secretName: mySecret
      baseBranch: master
      newBranchName: feature-b
      pushNewBranchToOrigin: true
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
      action: createNewBranch
      url: "git@git.example.com:example-org/git-project.git"
      workingDir: "git-project"
      privateKey:
        org: myOrg
        secretName: mySecret
      sourceBranch: feature-a
      destinationBranch: master
```



         

## GITHUB TASK
The `GitHub` task allows users to trigger git operations on 
[GitHub](https://gecgithub01.walmart.com/) server as a step of a flow.

<a name="usage"/>

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:git-task:0.42.1
```

This adds the GitHub task to the classpath and allows you to invoke the GitHub task in a flow:

## Create PR and Merge 

Below GITHUB task can be used to create a New PR and Merge it.

```yaml
flows:
  default:
  - task: github
    in:
      action: createPRAndMerge
      accessToken: myGitToken
      org: myOrg
      repo: myRepo
      PRTitle: myPRTitle
      PRBody: myPRBody
      PRSourceBranch: mySource
      PRDestinationBranch: myDest
```

Following is a complete list of available configuration attributes:
- `action`: Required. Set this parameter to `createPRAndMerge` to trigger `Create PR and Merge ` operation or set it to             `CreateTag` to trigger a `Create Tag` operation.
- `accessToken`: Required. GitHub Access Token 
- `org`: Required. Name of the Org where the GitRepo is present.
- `repo`: Required. Name of the GitRepo
- `PRTitle`: Required. Pull Request Title
- `PRBody`: Required. Pull Request Body
- `PRSourceBranch`: Required. The name of the branch where your changes are implemented.
- `PRDestinationBranch`: Required. The name of the branch you want the changes pulled into.
- `tagVersion`: Required. The tag's name. This is typically a version (e.g., "v0.0.1").
- `tagMessage`: Required. The tag message.
- `taggerUID`: Required. The name of the author of the tag.
- `taggerEMAIL`: Required. The email of the author of the tag.
- `branchSHA`: Required. The SHA of the successful git commit that user want to tag. This gets passed from the Looper build


## Create Tag

Below GITHUB task can be used to Create Tag on Last successful commit/Looper Build

```yaml
#Parameters required are shown below
flows:
  default:
  - task: gitHub
    in:
      action: CreateTag
      accessToken: myGitToken
      org: myOrg
      repo: myRepo
      tagVersion: myVersion
      tagMessage: myMsg
      taggerUID: myUserID
      taggerEMAIL: myEmailID
      branchSHA: ${gitHubBranchSHA}
```

