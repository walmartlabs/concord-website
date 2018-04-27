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
- `call`: use to call the specific flow in looper, if not provided `default` flow will be executed
- `jobName`: looper's job name
- `parameters`: only for looper's parametrize job, details in [Calling Parameterized Job](#calling-parameterized-job);
- `userName`: looper's username, It can be omitted as concord will provide default username to call looper jobs

### Calling Parameterized Job
Concord can also trigger looper's parameterized jobs, following is the list of supported parameters;

- String parameter
- Boolean parameter
- File parameter, details in [File Parameter](#file-parameter);
- Choice parameter
- Password parameter

**Note:** Set the password parameter value as `<DEFAULT>` in order to use the default password set 
in looper job configuration

From looper's perspective, `String`, `Boolean`, `Choice` and `Password` parameters are all simple string `key:value` pairs. Looper
will check the key and map the given value over the looper's specified type and any invalid value may result in exception.

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
        string_parameter: any_string
        choiceParameter: any_choice
        booleanParameter: true
        passwordParameter: ${anyPassword}
```
### File Parameter
For file parameters, right side value(i.e. path) should be prefixed with 'file://' as shown in the following example:

```yaml
flows:
  default:
  - task: looper
    in:
      jobName: looper-job-name
      parameters:
        string_parameter: any_string
        some_file_parameter: file://path_to_file
```