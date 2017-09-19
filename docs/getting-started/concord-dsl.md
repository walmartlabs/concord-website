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
- [Process Syntax](#process-syntax)
  - [Entry points](#entry-points)
  - [Execution steps](#execution-steps)
  - [Expressions](#expressions)
  - [Tasks](#tasks)
  - [Conditional expressions](#conditional-expressions)
  - [Return command](#return-command)
  - [Groups of steps](#groups-of-steps)
  - [Calling other flows](#calling-other-flows)
  - [Scripting](#scripting)
  - [Variables](#variables)
  - [Docker](#docker)
- [Forms](#forms)
- [Grammar](#grammar)

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

## Process Syntax

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

#### Tasks

Tasks allow you to call Java methods implemented in one of the dependencies of
the project. In addition to calling a task via an expression as above you can
invoke the Java code by using dynamic method resolution or by using
`JavaDelegate` instances.

Dynamic method resolution is the simplest way to call Java code.
Any object that implements the `com.walmartlabs.concord.common.Task`
interface and provides a `call(...)` method сan be called this way.

```yaml
flows:
  main:
    # calling a method with a single argument
    # same as ${myTask.call("hello")}
    - myTask: hello
    
    # calling a method with a single argument
    # the value will be a result of expression evaluation
    - myTask: ${myMessage}
    
    # calling a method with two arguments
    # same as ${myTask.call("warn", "hello")}
    - myTask: ["warn", "hello"]
    
    # calling a method with a single argument
    # the value will be converted into Map<String, Object>
    - myTask: { "urgency": "high", message: "hello" }

    # multiline strings and string interpolation is also supported
    - myTask: |
        those line breaks will be
        preserved. Here will be a ${result} of EL evaluation.
```

If a task implements the `#execute(Context)` method, some additional
features like in/out variables mapping can be used:

```yaml
flows:
  main:
    # calling a task with in/out variables mapping
    - task: myTask
      in:
        taskVar: ${processVar}
        anotherTaskVar: "a literal value"
      out:
        processVar: ${taskVar}
      error:
        - log: something bad happened
```

Further details are available in the [Tasks documentation](tasks.html).

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

### Scripting

Most of the JSR-223 compatible script engines are 
[supported including Python, Groovy and JavaScript](./scripting.html).

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

### Docker

Concord can start a docker container as documented in the 
[Docker usage documentation](./docker.html).

## Forms

Form support is described in a [separate](./forms.html) document.

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
