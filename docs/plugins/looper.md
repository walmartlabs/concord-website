---
layout: wmt/docs
title:  Looper Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `looper` task allows users to trigger build jobs on a
[Looper](https://looper.walmart.com) continuous integration server as a step of
a flow.

<a name="usage"/>

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:looper-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke the task in a flow:

```yaml
flows:
  default:
  - task: looper
    in:
      baseUrl: https://looper.example.com
      username: looper_username
      apiToken: looper_api_token
      jobName: looper-job-name
```

All parameters sorted in alphabetical order.

- `apiToken`: Looper's API token, It can be omitted if Concord provides a
  default API token to call Looper jobs in its global configuration
- `baseUrl`: Looper server URL, if not provided a configured default Looper URL
  is used
- `call`: name of a specific flow to use for the execution of the Looper job, if
  not provided `default` flow is used
- `jobName`: name of the job on the Looper server
- `parameters`: Parameters to pass, the job has to be configured as
  parameterized job, details in
  [Calling Parameterized Job](#calling-parameterized-job);
- `username`: username to use for the job invocation, it can be omitted if
  Concord provides a default username to use;
- `sync`: if `true` the task waits for the Looper job to complete.

### Calling Parameterized Job

Concord can trigger parameterized jobs on Looper. Following is the list of
supported parameters types.

- String parameter
- Boolean parameter
- File parameter, details in [File Parameter](#file-parameter);
- Choice parameter
- Password parameter

**Note:** Set the password parameter value as `<DEFAULT>` in order to use the
default password set in Looper job configuration

From Looper's perspective, `String`, `Boolean`, `Choice` and `Password`
parameters are all simple string `name:value` pairs. Looper checks the name of a
parameter and maps the given value over specified type in Looper. Therefore, any
invalid value may result in an exception and a failure to invoke a job.


```yaml
flows:
  default:
  - task: looper
    in:
      baseUrl: https://looper.example.com
      username: looper_username
      apiToken: looper_api_token
      jobName: looper-job-name
      parameters:
        string_parameter: any_string
        choiceParameter: any_choice
        booleanParameter: true
        passwordParameter: ${anyPassword}
```
### File Parameter

For file parameters, the value details the path to a file in the Concord
project in quotes and prefixed with `@`:

```yaml
flows:
  default:
  - task: looper
    in:
      jobName: looper-job-name
      parameters:
        string_parameter: any_string
        some_file_parameter: "@example-file-txt"
```

### Task Output

The last known status of the submitted Looper job is saved into `looperJob`
variable:

```yaml
flows:
  default:
  - task: looper
    in:
      ...
  - log: "Build #${looperJob.build} - ${looperJob.status}"
```

Note that for the jobs submitted without `sync: true` the build number may not
be available.
