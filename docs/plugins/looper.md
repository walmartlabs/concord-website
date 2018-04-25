---
layout: wmt/docs
title:  Looper Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}
The `looper` task allows users to trigger looper jobs as part of a flow. 

<a name="usage"/>

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:looper-tasks:0.40.1
```

This adds the task to the classpath and allows you to invoke the task in a flow:

```yaml
flows:
  default:
  - task: looper
    in:
      baseUrl: https://looper.example.com
      userName: looper_username
      apiToken: looper_api_token
      jobName: looper-job-name
```
All parameters sorted in alphabetical order.

- `apiToken`: looper's api token, It can be omitted as concord will provide default api token to call looper jobs
- `baseUrl`: looper's server url, if not provided default looper url will be used
- `jobName`: looper's job name
- `parameters`: only for looper's parametrize job, details in [Call Parameterize Job](#call-parameterize-job);
- `userName`: looper's username, It can be omitted as concord will provide default username to call looper jobs

### Call Parameterize Job
Concord can also call looper's parameterize jobs, Following is ths list of supported parameters;

- String parameter
- Boolean parameter
- File parameter
- Choice parameter
- Password parameter, user must set the password parameter value as `<DEFAULT>` in order to use the default password set 
in looper job configuration

From looper's perspective, `String`, `Boolean`, `Choice` and `Password` parameters are all simple string `key:value` pairs. Looper
will check the key and map the given value over the looper's specified type so any invalid value may result in exception.

```yaml
flows:
  default:
  - task: looper
    in:
      baseUrl: https://looper.example.com
      userName: looper_username
      apiToken: looper_api_token
      jobName: looper-job-name
      parameters:
        string_parameter: abc123
        choiceParameter: any_choice
        booleanParameter: true
        passwordParameter: ${anyPassword}
```
### File parameter
For file parameter, value must prefix with `file://` otherwise it will not consider as file parameter, kindly see below example;

```yaml
flows:
  default:
  - task: looper
    in:
      jobName: looper-job-name
      parameters:
        string_parameter: abc123
        some_file_parameter: file://path_to_file
```

### Limitations
`looper` task is not currently log the schedule job url because looper doesn't return any schedule job url in response for
parameterize job;