---
layout: wmt/docs
title:  Git and GitHub Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

## GIT TASK
The `Git` task allows users to trigger git operations on 
Concord server as a step of a flow.

<a name="usage"/>

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:git-task:0.42.1
```

This adds the Git task to the classpath and allows you to invoke the Git task in a flow:

## Create New Branch

Below GIT task can be used to create a New Branch and push it to origin

```yaml
flows:
  default:
  - task: git
    in:
      action: createNewBranch
      url: myRepoUrl
      workingDir: myWorkingDir
      baseBranch: perf_testing
      newBranchName: MyNewBranch
      pushNewBranchToOrigin: true
      privateKey:
         org: myOrg
         secretName: mySecret
```

Following is a complete list of available configuration attributes:

- `action`: Required. Set this parameter to `createNewBranch` to trigger `Create New Branch` operation or set it to             `MergeBranch` to trigger a `Merge` operation.
- `url`: Required. ssh url of the GitRepo
- `workingDir`: Required. All the GitRepo files will be cloned to this directory on Concord Sever
- `baseBranch`: New branch will be created based on this input parameter. If not provided `default` Master Branch will be        used as base to create New Branch
- `newBranchName`: Required. Name of New Branch
- `pushNewBranchToOrigin`: Required. Set this Parmeter to 'false' if you dont want to push the New Branch to origin
- `sourceBranch`: Required. The name of the branch where your changes are implemented.
- `destinationBranch`: Required. The name of the branch you want the changes pulled into.
- `org`: Name of the Concord Org where the secret exists. If not specified searches for the secret in Default Org.
- `secretName`: Name of the 'secret'

## Merge Operation

Below GIT task can be used to Perform Git Merge Operation: 

```yaml
flows:
  default:
  - task: git
    in:
      action: MergeBranch   
      url: myRepoUrl
      workingDir: myDir
      sourceBranch: mySourceBranch
      destinationBranch: myDestBranch
      privateKey:
         org: myOrg
         secretName: mySecret
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

