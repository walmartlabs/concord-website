---
layout: wmt/docs
title:  Processes
side-navigation: wmt/docs-navigation.html
---

# Processes

  * [Structure of a process](#structure-of-a-process)
  * [Project file](#project-file)
  * [Request data](#request-data)
  * [Variables](#variables)
  * [Provided variables](#provided-variables)
  * [Dependencies](#dependencies)
  * [Error handling](#error-handling)
    - [Capturing errors](#capturing-errors)
    - [Handling user cancellations and failures](#handling-user-cancellations-and-failures)

## Structure of a Process

The server expects the following structure of a process working
directory:
- `.concord.yml` or `concord.yml` - main project file;
- `_main.json` - request data in JSON format (see
[below](#request-data));
- `processes` and/or `flows` - directories containing `.yml` process
and form definitions;
- `profiles` - directory containing profiles;
- `lib` - directory for additional runtime dependencies.

Anything else will be copied as-is and will be available for a
process. The plugins can require other files to be present in a
payload.

## Project File

A payload archive can contain a project file: `.concord.yml`.
This file will be loaded first and can contain process and flow
definitions, input variables and profiles:

```yaml
flows:
  main:
  - form: myForm
  - log: Hello, ${myForm.name}

forms:
  myForm:
  - name: {type: "string"}

variables:
  dependencies: ["..."]
  otherCfgVar: 123
  arguments:
    myForm: {name: "stranger"}

profiles:
  myProfile:
    variables:
      arguments:
        myAlias: "world"
        myForm: {name: "${myAlias}"}
```

Profiles can override default variables, flows and forms. For
example, if the process above will be executed using `myProfile`
profile, then the default value of `myForm.name` will be `world`.

See also [the YAML format for describing flows and forms](./yaml.html).

## Request Data

A payload's `_main.json` file is either supplied by users or created
by the server from a user's request data.

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

Only `entryPoint` parameter is mandatory. The `activeProfiles`
parameter is a list of project file's profiles that will be used to
start a process. If not set, a `default` profile will be used.

## Variables

Before executing a process, variables from a project file and a
request data are merged. Project variables override default project
variables and then user request's variables are applied.

There are a few variables which affect execution of a process:
- `template` - the name of a [template](../templates/index.html), will be
used by the server to create a payload archive;
- `dependencies` - array of URLs, list of external JAR dependencies.
See the [Dependencies](#dependencies) section for more details;
- `arguments` - a JSON object, will be used as process arguments.

Values of `arguments` can contain [expressions](./yaml.html#expressions).
Expressions can use all regular "tasks" plus external `dependencies`:

```yaml
variables:
  arguments:
    listOfStuff: ${myServiceTask.retrieveListOfStuff()}
    myStaticVar: 123
```

The variables are evaluated in the order of definition. For example,
it is possible to use a variable value in another variable if the
former is defined earlier than the latter:
```yaml
variables:
  arguments:
    name: "Concord"
    message: "Hello, ${name}"
```

## Provided Variables

Concord automatically provides several built-in variables:
- `context` - a reference to a context variables map of a current
execution, instance of `com.walmartlabs.concord.sdk.Context`;
- `txId` - unique identifier of a current execution;
- `tasks` - allows access to available tasks (for example:
  `${tasks.get('oneops')}`);
- `workDir` - path to the working directory of a current process;
- `initiator` - information about user who started a process:
  - `initiator.username` - login, string;
  - `initiator.displayName` - printable name, string;
  - `initiator.groups` - list of user's groups;
  - `initiator.attributes` - other LDAP attributes;
- `requestInfo` - additional request data:
  - `requestInfo.query` - query parameters of a request made using
  user-facing endpoints (e.g. the portal API).

LDAP attributes must be whitelisted in [the configuration](./configuration.html#ldap).

Availability of other variables and "beans" depends on installed
Concord's plugins and arguments passed on a process' start.
See also the document on [how to create custom tasks](./tasks.html).

## Dependencies

The `variables.dependencies` array allow users to include external
dependencies - 3rd-party code and Concord plugins. Each element of
the array must be a valid URL:
```yaml
variables:
  dependencies:
  - "http://central.maven.org/maven2/org/codehaus/groovy/groovy-all/2.4.11/groovy-all-2.4.11.jar"
```

Dependencies are automatically downloaded by the Agent and added to
the classpath of a process.

## Error handling

### Capturing errors

Task and expression errors are normal Java exceptions, which can be
"caught" and handled using a special syntax.

Expressions, tasks, groups of steps and flow calls can have an
optional `error` block, which will be executed if an exception
occurred:
```yaml
flows:
  main:
  # handling errors in an expression
  - expr: ${myTask.somethingDangerous()}
    error:
    - log: "Gotcha! ${lastError}"

  # handling errors in tasks
  - task: myTask
    error:
    - log: "Fail!"

  # handling errors in groups of steps
  - ::
    - ${myTask.doSomethingSafe()}
    - ${myTask.doSomethingDangerous()}
    error:
    - log: "Here we go again"

  # handling errors in flow calls
  - call: myOtherFlow
    error:
    - log: "That failed too"
```

The `${lastError}` variable contains the last caught
`java.lang.Exception` object.

If an error was caught, the execution will continue from the next
step:
```yaml
flows:
  main:
  - expr: ${misc.throwBpmnError('Catch that!')}
    error:
    - log: "A"

  - log: "B"
```
will log `A` and then `B`.

### Handling user cancellations and failures

When a process cancelled (killed) by a user, a special flow
`onCancel` will be executed:
```yaml
flows:
  main:
  - log: "Doing some work..."
  - ${sleep.ms(60000)}

  onCancel:
  - log: "Pack your bags, boys. Show's cancelled"
```

Similarly, `onFailre` flow will be executed if a process crashed:
```yaml
flows:
  main:
  - log: "Brace yourselves, we're going to crash!"
  - ${misc.throwBpmnError('Handle that!')}

  onFailure:
  - log: "Yep, we just did"
```

In both cases, the server will start a "child" process with a copy of
the original process state and use `onCancel` or `onFailure` as an
entry point.

**Note**: if a process was never suspended (e.g. had no forms or no
forms were submitted), then `onCancel`/`onFailures` will receive a
copy of the initial state of a process, which was created when the
original process was started by the server.

This means that no changes in the process state before suspension
will be visible to the "child" processes:
```yaml
flows:
  main:
  # let's change something in the process state...
  - set:
      myVar: "xyz"

  # will print "The main flow got xyz"
  - log: "The main flow got ${myVar}"

  # ...and then crash the process
  - ${misc.throwBpmnError('Boom!')}

  onFailure:
  # will log "I've got abc"
  - log: "And I've got ${myVar}"

variables:
  entryPoint: main
  arguments:
    # original value
    myVar: "abc"
```

In the future, Concord will provide a way to explicitly capture the
state of a process - a "checkpoint" mechanism.

