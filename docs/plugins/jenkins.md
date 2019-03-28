---
layout: wmt/docs
title:  Jenkins Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `jenkins` task allows users to trigger build jobs on a
[Jenkins](http://jenkins-ci.org) continuous integration server as a step of a
flow.

<a name="usage"/>

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:jenkins-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke the task in a flow:

```yaml
flows:
  default:
  - task: jenkins
    in:
      baseUrl: "https://jenkins.example.com"
      username: "myUser"
      apiToken: "myApiToken"
      jobName: "myJob"
```

All parameters sorted in alphabetical order.

- `apiToken`: Jenkins's API token, it can be omitted if Concord provides a
  default API token to call Jenkins jobs in its global configuration;
- `baseUrl`: Jenkins server URL, if not provided a configured default Jenkins
  URL is used;
- `debug`: if `true` enables additional debug output;
- `connectTimeout`: connection timeout in seconds, default value is `30`;
- `jobName`: name of the job on the Jenkins server, if your job is located in a
  folder use `myfolder/job/myjob` as the jobName value;
- `jobTimeout`: timeout waiting for the job in seconds, applies only if
  `sync: true`;
- `parameters`: Parameters to pass, the job has to be configured as
  parameterized job, details in
  [Calling a Parameterized Job](#calling-a-parameterized-job);
- `readTimeout`: network read timeout ins seconds, default value is `30`;
- `sync`: if `true` the task waits for the Jenkins job to complete (default `true`);
- `username`: username to use for the job invocation, it can be omitted if
  Concord provides a default username to use;
- `writeTimeout`: network write timeout in seconds, default value is `30`.

## Calling a Parameterized Job

Concord can trigger parameterized jobs on Jenkins. Following is the list of
supported parameters types.

- String parameter
- Boolean parameter
- File parameter, details in [File Parameter](#file-parameter)
- Choice parameter
- Password parameter

> Note: Set the password parameter value as `<DEFAULT>` in order to use the
> default password set in the Jenkins job configuration

From Jenkins's perspective, `String`, `Boolean`, `Choice` and `Password`
parameters are all simple string `name:value` pairs. Jenkins checks the name of
a parameter and maps the given value to the specified type in Jenkins.
Therefore, any invalid value may result in an exception and a failure to invoke
a job.


```yaml
flows:
  default:
  - task: jenkins
    in:
      baseUrl: "https://jenkins.example.com"
      username: "myUser"
      apiToken: "myApiToken"
      jobName: "myJob"
      parameters:
        stringParameter: "any string value"
        choiceParameter: "any_choice"
        booleanParameter: "true"
        passwordParameter: "${anyPassword}"
```

## File Parameter

For file parameters, the value details the path to a file in the Concord project
in quotes and is prefixed with `@`. The file parameter field `File location` on
your job configuration in Jenkins must be the same as the parameter name here.

For the example below that means the `File location` in Jenkins has to be set to
`some_file_parameter`.

```yaml
flows:
  default:
  - task: jenkins
    in:
      jobName: "myJob"
      parameters:
        stringParameter: "any string value"
        aFile: "@example-file-txt"
```

## Task Output

The last known status of the submitted Jenkins job is saved into the
`jenkinsJob` variable:

```yaml
flows:
  default:
  - task: jenkins
    in:
      ...
  - log: "Build #${jenkinsJob.build} - ${jenkinsJob.status}"
```

> Note that for the jobs submitted with `sync: false` the build number may not
> be available.
