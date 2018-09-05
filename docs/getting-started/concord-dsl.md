---
layout: wmt/docs
title:  Concord DSL
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The Concord DSL defines the syntax used in the Concord file - a `concord.yml`
file in the root of your project. It is based on using the simple, human
readable format [YAML](http://www.yaml.org/) and defines all your workflow
process flows, configuration, forms and other aspects:

- [Example](#example)
- [Project Configuration in `configuration`](#configuration)
  - [Entry Point](#entry-point)
  - [Dependencies](#dependencies)
  - [Template](#template)
  - [Arguments](#arguments)
  - [Debug](#debug)
- [Process Definitions in `flows:`](#flows)
  - [Entry points](#entry-points)
  - [Execution steps](#execution-steps)
  - [Expressions](#expressions)
  - [Conditional expressions](#conditional-expressions)
  - [Return command](#return-command)
  - [Groups of steps](#groups-of-steps)
  - [Loops](#loops)
  - [Calling other flows](#calling-other-flows)
  - [Error handling](#error-handling)
  - [Throwing exceptions](#throw-step)
  - [Setting variables](#set-step)
- [Named Profiles in `profiles`](#profiles)

Some features are more complex and you can find details in separate documents:

- [Scripting](./scripting.html)
- [Tasks](./tasks.html)
- [Forms](./forms.html)

Additional features are available by using tasks available in a
[number of plugins](../plugins/index.html).

## Example

```yaml
flows:
  default:
    - log: "Getting started now"
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
- the `default` flow automatically configured as the process starting point
- a simple log message is created to start
- the `sendEmail` [task](./tasks.html) (1) is executed using two input
  parameters: `to` and `subject`. The output of the task is stored in `result`
  variable.
- `if` [expression](#expressions) (2) is used to either call `reportSuccess`
  sub-flow (3) or to log a failure message;
- `reportSuccess` flow is calling a Java bean using the EL syntax (4).

The actual task names and their required parameters may differ. Please refer to
the [task documentation](./tasks.html) and the specific task used for details.

<a name="configuration"/>
## Project Configuration in `configuration`

Overall configuration for the project and process executions is contained in the
`configuration:` top level element of the Concord file:

- [Entry Point](#entry-point)
- [Dependencies](#dependencies)
- [Template](#template)
- [Arguments](#arguments)
- [Debug](#debug)

### Entry Point

The `entryPoint` configuration sets the name of the flow that will be used for
process executions. Without specific configuration the flow labelled `default`
is used automatically, if it exists.

```yaml
configuration:
  entryPoint: "main"
flows:
  main:
  - log: "Hello World"
```

### Dependencies

The `dependencies` array allows users to specify the URLs of dependencies such
as

- Concord plugins and their dependencies 
- dependencies needed for specific scripting language support
- other dependencies required for process execution

```yaml
configuration:
  dependencies:
    # maven URLs...
    - mvn://org.codehaus.groovy:groovy-all:2.4.12
    # or direct URLs
    - https://repo1.maven.org/maven2/org/codehaus/groovy/groovy-all/2.4.12/groovy-all-2.4.12.jar"
    - https://repo1.maven.org/maven2/org/apache/commons/commons-lang3/3.6/commons-lang3-3.6.jar"
```

The artifacts are downloaded and added to the classpath for process execution
and are typically used for [task implementations](./tasks.html).

Multiple versions of the same artifact are replaced with a single one, according
to standard Maven resolution rules.

Usage of the `mvn:` URL pattern is preferred since it uses the centrally
configured [list of repositories](./configuration.html#dependencies) and
downloads not only the specified dependency itself, but also any required
transitive dependencies. This makes the Concord project independent of access to
a specific repository URL, and hence more portable.

Maven URLs provide additional options:

- `transitive=true|false` - include all transitive dependencies
(default `true`);
- `scope=compile|provided|system|runtime|test` - use the specific dependency scope
(default `compile`).

The syntax for the Maven URL uses the groupId, artifactId and version values -
the GAV coordinates of a project. For example the Maven pom.xml for the Groovy
scripting language runtime has the following definition:

```xml
<project>
  <groupId>org.codehaus.groovy</groupId>
  <artifactId>groovy-all</artifactId>
  <version>2.4.12</version>
  ...
</project>
```

This results in the path
`org/codehaus/groovy/groovy-all/2.4.12/groovy-all-2.4.12.jar` in the Central
Repository and any repository manager proxying the repository.

The `mvn` syntax uses the short form for GAV coordinates
`groupId:artifactId:version`, so for example
`org.codehaus.groovy:groovy-all:2.4.12` for Groovy.

The same logic applies to all other dependencies including Concord plugins.

### Template

A template can be used to allow inheritance of all the configuration of another
project. The value for the `template` field has to be a valid URL pointing to
a JAR-archive of the project to use as template. 

The template is downloaded for [process execution](./processes.html#execution)
and exploded in the workspace. More detailed documentation, including
information about available templates, is available in the
[templates section](../templates/index.html).

### Arguments

Default values for arguments can be defined in the `arguments` section of the
configuration as simple key/value pairs as well as nested values

```yaml
configuration:
  arguments:
    name: "Example"
    coordinates:
      x: 10
      y: 5
      z: 0
flows:
  default:
    - log: "Project name: ${name}"
    - log: "Coordinats (x,y,z): ${coordinates.x}, ${coordinates.y}, ${coordinates.z}
```

Values of `arguments` can contain [expressions](#expressions). Expressions can
use all regular tasks.

```yaml
configuration:
  arguments:
    listOfStuff: ${myServiceTask.retrieveListOfStuff()}
    myStaticVar: 123
```

The variables are evaluated in the order of definition. For example, it is
possible to use a variable value in another variable if the former is defined
earlier than the latter:

```yaml
configuration:
  arguments:
    name: "Concord"
    message: "Hello, ${name}"
```

Variable value can be [defined or modified with the set step](#set) and a
[number of variables](./processes.html#variables) are automatically set in each
process and available for usage.

### Debug

Enabling the `debug` configuration option causes Concord to log paths of all
resolved dependencies. It is useful for debugging classpath conflict issues.

```yaml
configuration:
  debug: true
```


<a name="flows"/>

## Process Definitions in `flows:`

Process definitions are configured in named sections under the `flows:` 
top-level element in the Concord file.

### Entry Points

Entry point define the name and start of process definitions within the
top-level `flows:` element. Concord uses entry points as a starting step of an
execution. A single Concord file can contain multiple entry points.

```yaml
flows:
  default:
    - ...
    - ...

  anotherEntry:
    - ...
    - ...
```

An entry point must be followed by one or more [execution steps](#execution-steps).



<a name="execution-steps"/>

### Execution Steps

<a name="expressions"/>
#### Expressions

Expressions must be valid
[Java Expresssion Language EL 3.0](https://github.com/javaee/el-spec) syntax
and can be simple evaluations or perform actions by invoking more complex code.

Short form:
```yaml
flows:
  default:
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
  default:
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

Literal values, for example arguments or [form](#forms) field values, can
contain expressions:

```yaml
flows:
  default:
    - myTask: ["red", "green", "${colors.blue}"]
    - myTask: { nested: { literals: "${myOtherTask.doSomething()}"} }
```

Classes from the package `java.lang` can be accessed via EL syntax:

```
    - log: "Process running on ${System.getProperty('os.name')}"
```

### Conditional Expressions


```yaml
flows:
  default:
    - if: ${myVar > 0}
      then:                           # (1)
        - log: it's clearly non-zero
      else:                           # (2)
        - log: zero or less

    - ${myBean.acceptValue(myVar)}    # (3)
```

In this example, after `then` (1) or `else` (2) block are completed,
the execution continues with the next step in the flow (3).

To compare a value (or a result of an expression) with multiple
values, use the `switch` block:

```yaml
flows:
  default:
    - switch: ${myVar}
      red:
        - log: "It's red!"
      green:
        - log: "It's definitely green"
      default:
        - log: "I don't know what it is"

    - log: "Moving along..."
```

In this example, branch labels `red` and `green` are the compared
values and `default` is the block which will be executed if no other
value fits.

Expressions can be used as branch values:

```yaml
flows:
  default:
    - switch: ${myVar}
      ${aKnownValue}:
        - log: "Yes, I recognize this"
      default:
        - log: "Nope"
```

### Return Command

The `return` command can be used to stop the execution of the current
(sub) flow:

```yaml
flows:
  default:
    - if: ${myVar > 0}
      then:
        - log: moving along
      else:
        - return
```

### Exit Command

The `exit` command can be used to stop the execution of the flow:

```yaml
flows:
  default:
    - if: ${myVar > 0}
      then:
        - exit
    - log: "message"
```

### Groups of Steps

Several steps can be grouped in one block. This allows `try-catch`-like
semantics:

```yaml
flows:
  default:
    - log: a step before the group
    
    - try:
      - log: "a step inside the group"
      - ${myBean.somethingDangerous()}
      error:
        - log: "well, that didn't work"
```


### Calling Other Flows

Flows, defined in the same YAML document, can be called by their names or using
the `call` step.

```yaml
flows:
  default:
  - log: hello
  
  # short form: call another flow by its name 
  - mySubFlow
  
  # full form: use `call` step
  - call: anotherFlow
    # (optional) additional call parameters
    in:
      msg: "Hello!"
    
  - log: bye
    
  mySubFlow:
  - log: "a message from the sub flow"

  anotherFlow:
  - log: "message from another flow: ${msg}"
```

### Loops

Concord flows can iterate through a collection of items in a loop using the
`call` step and the `withItems` collection of values.

```yaml
  - call: myFlow
    withItems:
    - "first element"
    - "second element"
    - 3
    - false

  # withItems can also be used with tasks
  - task: myTask
    in:
      myVar: ${item}
    withItems:
    - "first element"
    - "second element"
```

The collection of items to iterate over can be provided by an expression:

```yaml
configuration:
  arguments:
    myItems:
    - 100500
    - false
    - "a string value"

flows:
  default:
  - call: myFlow
    withItems: ${myItems}
```

The items are available in the invoked flow with the `${item}` expression.

```yaml
  myFlow:
  - log: "We got ${item}"
```

Complex objects can be used in loops as well:

```yaml
flows:
  default:
  - call: deployToClouds
    withItems:
    - name: cloud1
      fqdn: cloud1.myapp.example.com
    - name: cloud2
      fqdn: cloud2.myapp.example.com

  deployToClouds:
  - log: "Starting deployment to ${item.name}"
  - log: "Using fqdn ${item.fqdn}"
```

### Error Handling

The full form syntax allows using input variables (call arguments) and supports
error handling:

Task and expression errors are normal Java exceptions, which can be
"caught" and handled using a special syntax.

Expressions, tasks, groups of steps and flow calls can have an
optional `error` block, which will be executed if an exception occurrs.

```yaml
flows:
  default:
  # handling errors in an expression
  - expr: ${myTask.somethingDangerous()}
    error:
    - log: "Gotcha! ${lastError}"

  # handling errors in tasks
  - task: myTask
    error:
    - log: "Fail!"

  # handling errors in groups of steps
  - try:
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

If an error was caught, the execution will continue from the next step.

```yaml
flows:
  default:
  - expr: ${misc.throwBpmnError('Catch that!')}
    error:
    - log: "A"

  - log: "B"
```

An execution logs `A` and then `B`.

When a process cancelled (killed) by a user, a special flow
`onCancel` is executed:

```yaml
flows:
  default:
  - log: "Doing some work..."
  - ${sleep.ms(60000)}

  onCancel:
  - log: "Pack your bags, boys. Show's cancelled"
```

Similarly, `onFailure` flow is executed if a process crashes:

```yaml
flows:
  default:
  - log: "Brace yourselves, we're going to crash!"
  - ${misc.throwBpmnError('Handle that!')}

  onFailure:
  - log: "Yep, we just did"
```

In both cases, the server starts a "child" process with a copy of
the original process state and uses `onCancel` or `onFailure` as an
entry point.

**Note**: if a process was never suspended (e.g. had no forms or no
forms were submitted), then `onCancel`/`onFailures` receive a
copy of the initial state of a process, which was created when the
original process was started by the server.

This means that no changes in the process state before suspension
will be visible to the "child" processes:

```yaml
flows:
  default:
  # let's change something in the process state...
  - set:
      myVar: "xyz"

  # will print "The default flow got xyz"
  - log: "The default flow got ${myVar}"

  # ...and then crash the process
  - ${misc.throwBpmnError('Boom!')}

  onFailure:
  # will log "I've got abc"
  - log: "And I've got ${myVar}"

configuration:
  arguments:
    # original value
    myVar: "abc"
```

<a name="throw-step"/>

### Throwing Exceptions

The `throw` step can be used to throw a new RuntimeException with the supplied
message anywhere in a flow including `error` sections, but also in
[conditional expressions](#conditional-expressions) such as if-then or
switch-case.

```yaml
flows:
  default:
  - try:
    - log: "Do something dangerous here"
    error:
    - throw: "oh, something went wrong."
```

Alternatively a caught exception can be thrown again using the `lastError` variable.

```yaml
flows:
  default:
  - try:
    - log: "Do something dangerous here"
    error:
    - throw: ${lastError}
```

<a name="set-step"/>

### Setting Variables

The `set` step can be used to set variables in the current process context:

```yaml
flows:
  default:
  - set:
      a: "a-value"
      b: 3
  - log: ${a}
  - log: ${b}
```

Nested data can be updated using the `.` syntax:

```yaml
configuration:
  arguments:
    myComplexData:
      nestedValue: "Hello"

flows:
  default:
  - set:
      myComplexData.nestedValue: "Bye"
      
  # will print "Bye, Concord"
  - log: "${myComplexData.nestedValue}, Concord"
```
  
A [number of variables](./processes.html#variables) are automatically set in
each process and available for usage.

<a name="profiles"/>
## Named Profiles in `profiles`

Profiles are named collections of configuration, forms and flows and can be used
to override defaults set in the top-level content of the Concord file. They are
created by inserting a name section in the `profiles` top-level element.

Profile selection is configured when a process is
[executed](./processes.html#execution).

For example, if the process below is executed using the `myProfile` profile, 
the value of `foo` is `bazz` and appears in the log instead of the default
`bar`.

```yaml
configuration:
  arguments:
    foo: "bar"
    
profiles:
  myProfile:
    configuration:
      arguments:
        foo: "bazz"
flows:
  default:
  - log: "${foo}"
```

The `activeProfiles` parameter is a list of project file's profiles that is
used to start a process. If not set, a `default` profile is used.

The active profile's configuration is merged with the default values
specified in the top-level `configuration` section. Nested objects are 
merged, lists of values are replaced:

```yaml
configuration:
  arguments:
    nested:
      x: 123
      y: "abc"
    aList:
    - "first item"
    - "second item"  

profiles:
  myProfile:
    configuration:
      arguments:
        nested:
          y: "cba"
          z: true
        aList:
        - "primer elemento"
        - "segundo elemento"

flows:
  default:
  # Expected next log output: 123 cba true
  - log: "${nested.x} ${nested.y} ${nested.z}"
  # Expected next log output: ["primer elemento", "segundo elemento"]
  - log: "${aList}"
```

Multiple active profiles are merged in the order they are specified in
`activeProfiles` parameter:

```bash
$ curl ... -F activeProfiles=a,b http://concord.example.com/api/v1/process
```

In this example, values from `b` are merged with the result of the merge
of `a` and the default configuration.
