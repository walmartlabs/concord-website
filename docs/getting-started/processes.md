---
layout: wmt/docs
title:  Processes
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

A process is represents an execution of a Concord project using one of the
defined process definition and additional supplied resources.

- [Structure](#structure)
- [Project file](#project-file)
- [Request data](#request-data)
- [Provided Variables](#variables) 
- [Out Variables](#out-variables)
- [Execution](#execution)

<a name="structure"/>
## Structure

Console expects the following structure of a process working directory:

- `concord.yml`: the [project file](#project-file) containing the main project
information and declarations;
- `flows`: directories containing `.yml` process and form definitions;
- `profiles`: directory containing profiles;
- `lib`: directory for additional runtime dependencies.

Anything else will be copied as-is and will be available for a process. The
plugins can require other files to be present in a payload.

The same structure should be used when storing your project in a git repository.
Concord simply clones the repository into the process execution space.

<a name="project-file"/>
## Project File

A payload archive can contain the Concord file `concord.yml`. It uses the
[Concord DSL](./concord-dsl.html). This file will be loaded first and can
contain general configuration, process flow definitions, forms, profiles and
more.

<a name="request-data"/>
## Request Data

A payload's `_main.json` file is either supplied by users or created by the
server from a user's request data.

The request's JSON format:

```json
{
  "entryPoint": "...",
  "activeProfiles": ["myProfile", "..."],
  "otherCfgVar": 123,
  "arguments": {
    "myForm": {
      "name": "John"
    }
  }
}
```

The `entryPoint` parameter is can be used to defined the flow to be used. The 
`activeProfiles` parameter is a list of project file's profiles that will be
used to start a process. If not set, a `default` profile will be used.

<a name="variables"/>
## Provided Variables

Concord automatically provides several built-in variables upon process
execution in addition to the defined [variables](./concord-dsl.html#variables):

- `context`:a reference to a context variables map of a current execution,
instance of `com.walmartlabs.concord.sdk.Context`;
- `txId`: unique identifier of a current execution;
- `tasks`: allows access to available tasks (for example:
  `${tasks.get('oneops')}`);
- `workDir`: path to the working directory of a current process;
- `initiator`: information about user who started a process:
  - `initiator.username`: login, string;
  - `initiator.displayName`: printable name, string;
  - `initiator.groups`: list of user's groups;
  - `initiator.attributes`: other LDAP attributes;
- `requestInfo`: additional request data:
  - `requestInfo.query`: query parameters of a request made using user-facing 
    endpoints (e.g. the portal API).

LDAP attributes must be whitelisted in [the configuration](./configuration.html#ldap).

Availability of other variables and "beans" depends on installed Concord's
plugins and the arguments passed in at the process invocation and stored in the
[request data](#request-data).

<a name="out-variables"/>
## Out Variables

Concord has the ability to return process data when a process completes.
The names or returned variables should be declared when a process starts
using query parameters:
```
$ curl ... http://concord.example.com/api/v1/process?sync=true&out=myVar1
{
  "instanceId" : "5883b65c-7dc2-4d07-8b47-04ee059cc00b",
  "out" : {
    "myVar1" : "my value"
  },
  "ok" : true
}
```
or declared in the `configuration` section:
```yaml
configuration:
  out:
    - myVar1
```

It is also possible to retieve a nested value:
```
$ curl ... http://concord.example.com/api/v1/process?sync=true&out=a.b.c
```
In this example, Concord will look for variable `a`, its field `b` and
the nested field `c`.

When a process starts in the synchronous mode (`sync=true`), the data is
returned in the response. For asynchronous processes, the OUT variables
data can be retrieved with an API call:
```
$ curl ... http://localhost:8001/api/v1/process/5883b65c-7dc2-4d07-8b47-04ee059cc00b/attachment/out.json

{"myVar1":"my value"}
```

Any value type that can be represented as JSON is supported.

<a name="execution"/>
## Execution

A process is executed using the following steps: 

- Project repository data is cloned or updated
- Binary payload from the process invocation is added to the workspace
- Configuration from the project is used
- Configuration from project.yml is merged
- Configuration from an uploaded JSON file is merged
- Configuration from request parameters and selected profiles applied
- Templates are downloaded and applied
- The payload is created and send to the Concord Agent for execution
- Dependencies are downloaded and put on the classpath
- The flow configured as entry point is invoked
