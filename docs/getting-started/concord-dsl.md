---
layout: wmt/docs
title:  Concord DSL
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The Concord DSL defines the syntax used in the Concord file - a `concord.yml`
file in the root of your project. It is based on using the simple, human
readable format [YAML](http://www.yaml.org/) and defines all your workflow
process, forms and other aspects:

- [Example](#example)
- [Configuration](#configuration)
  - [Provided variables](#provided-variables)
  - [Dependencies](#dependencies)
- [Process Definition in `flows:`](#flows)
  - [Entry points](#entry-points)
  - [Execution steps](#execution-steps)
  - [Expressions](#expressions)
  - [Conditional expressions](#conditional-expressions)
  - [Return command](#return-command)
  - [Groups of steps](#groups-of-steps)
  - [Calling flows](#calling-other-flows)
- [Profiles](#profiles)
- [Grammar](#grammar)

Some features are more complex and you can find details in separate documents:

- [Scripting](./scripting.html)
- [Tasks](./tasks.html)
- [Forms](./forms.html)
- [Docker](./docker.html)

## Example

```yaml
flows:
  main:
    - task: sendEmail                               # (1)
      in:
        to: me@localhost.local
        subject: Hello, Concord!
      out:
        result: operationResult
      error:
        - log: "email sending error"
    - if: ${result.ok}                              # (2)
      then:
        - reportSuccess                             # (3)
      else:
        - log: "Failed: ${lastError.message}"

  reportSuccess:
    - ${dbBean.updateStatus(result.id, "SUCCESS")}; # (4)
```

In this example:
- the `sendEmail` [task](./tasks.html) (1) is executed using two input
  parameters: `to` and `subject`. The output of the task is stored in `result`
  variable.
- `if` [expression](#expressions) (2) is used to either call `reportSuccess`
  sub-flow (3) or to log a failure message;
- `reportSuccess` flow is calling a Java bean using the EL syntax (4).

Note: the actual task names and their required parameters may differ.
Please refer to the specific task's documentation.

<a name="flows"/>
## Process Definition in `flows:`

### Entry Points

Entry point define the name and start of process definitions within the
top-level `flows:` element. Concord uses entry points as a starting step of an
execution. A single Concord file can contain multiple entry points.

```yaml
flows:
  main:
    - ...
    - ...

  anotherEntry:
    - ...
    - ...
```

An entry point must be followed by one or more execution steps.

### Execution Steps

<a name="expressions"/>
#### Expressions

Expressions are used to invoke some 3rd-party code. All expressions
must be valid
[Java Expresssion Language EL 3.0](https://github.com/javaee/el-spec) syntax.

Short form:
```yaml
flows:
  main:
    # calling a method
    - ${myBean.someMethod()}

    # calling a method with an argument
    - ${myBean.someMethod(myContextArg)}

    # literal values
    - ${1 + 2}

    # EL 3.0 extensions:
    - ${[1, 2, 3].stream().map(x -> x + 1).toList()}
```

Full form:
```yaml
flows:
  main:
    - expr: ${myBean.someMethod()}
      out: myVar
      error:
        - ${log.error("something bad happened")}
```

Full form can optionally contain additional declarations:
- `out` field: contains the name of a variable, in which a result of
the expression will be stored;
- `error` block: to handle any exceptions thrown by the evaluation.
Exceptions are wrapped in `BpmnError` type.

See [the list of automatically provided variables](./processes.html#provided-variables).

Literal values, for example arguments or [form](#forms) field values, can
contain expressions:

```yaml
flows:
  main:
    - myTask: ["red", "green", "${colors.blue}"]
    - myTask: { nested: { literals: "${myOtherTask.doSomething()}"} }
```

### Conditional Expressions


```yaml
flows:
  main:
    - if: ${myVar > 0}
      then:                           # (1)
        - log: it's clearly non-zero
      else:                           # (2)
        - log: zero or less

    - ${myBean.acceptValue(myVar)}    # (3)
```

In this example, after `then` (1) or `else` (2) block are completed,
the execution continues with the next step in the flow (3).

### Return Command

The `return` command can be used to stop the execution of the current
(sub) flow:

```yaml
flows:
  main:
    - if: ${myVar > 0}
      then:
        - log: moving along
      else:
        - return
```

### Groups of Steps

Several steps can be grouped in one block. This allows `try-catch`-like
semantics:

```yaml
flows:
  main:
    - log: a step before the group
    - ::
      - log: a step inside the group
      - ${myBean.somethingDangerous()}
      error:
        - log: well, that didn't work
```

### Calling Other Flows

Flows, defined in the same YAML document, can be called by their names:

```yaml
flows:
  main:
    - log: hello
    - mySubFlow
    - log: bye

  mySubFlow:
    - log: a message from the sub flow
```

The full form syntax allows using input variables (call arguments) and supports
error handling:

```yaml
flows:
  main:
    - call: mySubFlow
      in:
        name: "Concord"
      error:
        - log: "Oh, no"

  mySubFlow:
    - if: "${name != 'Concord'}"
      then:
        - return: strangerDanger
    - log: "Hello, ${name}"
```

Similar to [tasks](#tasks), the `in` variables can use expressions.

## Error Handling

### Capturing Errors

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

Similarly, `onFailure` flow will be executed if a process crashed:
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

### Variables

The `set` command can be used to set variables in the current flow:

```yaml
flows:
  main:
    - set:
        a: "a-value"
        b: 3
    - log: ${a}
    - log: ${b}
```


## Configuration

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

Values of `arguments` can contain [expressions](./concord-dsl.html#expressions).
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

### Provided Variables

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

### Dependencies

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

## Profiles

Profiles can override default variables, flows and forms. For
example, if the process above will be executed using `myProfile`
profile, then the default value of `myForm.name` will be `world`.

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
  default:
    variables:
      ??
  myProfile:
    variables:
      arguments:
        myAlias: "world"
        myForm: {name: "${myAlias}"}
```

The `activeProfiles` parameter is a
list of project file's profiles that will be used to start a process. If not
set, a `default` profile will be used.





## Grammar

Formal definition (PEG-like).

```
expression := VALUE_STRING ${.*}
value := VALUE_STRING | VALUE_NUMBER_INT | VALUE_NUMBER_FLOAT | VALUE_TRUE | VALUE_FALSE | VALUE_NULL | arrayOfValues | object
arrayOfValues := START_ARRAY value* END_ARRAY
object := START_OBJECT (FIELD_NAME value)* END_OBJECT
identifier := VALUE_STRING
formName := VALUE_STRING ^form \((.*)\)$

outField := FIELD_NAME "out" identifier
errorBlock := FIELD_NAME "error" steps

kv := FIELD_NAME value
inVars := FIELD_NAME "in" START_OBJECT (kv)+ END_OBJECT
outVars := FIELD_NAME "out" START_OBJECT (kv)+ END_OBJECT

exprOptions := (outField | errorBlock)*
taskOptions := (inVars | outVars | outField | errorBlock)*
callOptions := (inVars | outVars | errorBlock)*
groupOptions := (errorBlock)*
formCallOptions := (kv)*
dockerOptions := (kv)*

exprShort := expression
exprFull := FIELD_NAME "expr" expression exprOptions
taskFull := FIELD_NAME "task" VALUE_STRING taskOptions
taskShort := FIELD_NAME literal
ifExpr := FIELD_NAME "if" expression FIELD_NAME "then" steps (FIELD_NAME "else" steps)?
returnExpr := VALUE_STRING "return"
returnErrorExpr := FIELD_NAME "return" VALUE_STRING
group := FIELD_NAME ":" steps groupOptions
callFull := FIELD_NAME "call" VALUE_STRING callOptions
callProc := VALUE_STRING
script := FIELD_NAME "script" VALUE_STRING (FIELD_NAME "body" VALUE_STRING)?
formCall := FIELD_NAME "form" VALUE_STRING formCallOptions
vars :=  FIELD_NAME "vars" START_OBJECT (kv)+ END_OBJECT
docker := FIELD_NAME "docker" VALUE_STRING dockerOptions

stepObject := START_OBJECT docker | group | ifExpr | exprFull | formCall | taskFull | callFull | inlineScript | taskShort END_OBJECT
step := returnExpr | returnErrorExpr | exprShort | callProc | stepObject
steps := START_ARRAY step+ END_ARRAY

formField := START_OBJECT FIELD_NAME object END_OBJECT
formFields := START_ARRAY formField+ END_ARRAY

procDef := FIELD_NAME steps
formDef := formName formFields

defs := START_OBJECT (formDef | procDef)+ END_OBJECT
```
