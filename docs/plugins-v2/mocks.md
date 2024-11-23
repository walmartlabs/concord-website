---
layout: wmt/docs
title:  Mocks Task
side-navigation: wmt/docs-navigation.html
description: Safely and efficiently simulate behavior, verify interactions, and validate process logic with the Concord Mocks plugin.
---

# {{ page.title }}

- [Usage](#usage)
- [Mock definition](#mock-definition)
  - [Fields for Mocking a Task](#fields-for-mocking-a-task)
  - [Fields for Mocking a Task Method](#fields-for-mocking-a-task-method)
- [How to mock a Task](#how-to-mock-a-task)
  - [Example: Mocking a Task Call](#example-mocking-a-task-call) 
  - [Example: Mocking a Task Call and Executing a Flow Instead of the Original Task](#example-mocking-a-task-call-and-executing-a-flow-instead-of-the-original-task)
  - [Example: Mocking a Task with Specific Input Parameters](#example-mocking-a-task-with-specific-input-parameters)
- [How to Mock a Task method](#how-to-mock-a-task-method)
  - [Example: Mocking a Task Method](#example-mocking-a-task-method)
  - [Example: Mocking a Task Method and Executing a Flow Instead of the Original Task method](#example-mocking-a-task-method-and-executing-a-flow-instead-of-the-original-task-method)
  - [Example: Mocking a Task Method with Input Arguments](#example-mocking-a-task-method-with-input-arguments)
- [How to Verify Task Calls](#how-to-verify-task-calls)
  - [Example: Verifying a Task Call](#example-verifying-a-task-call)
  - [Example: Verifying a Task Method Call](#example-verifying-a-task-method-call)

Mocks plugin allow you to:

- **"Mock" tasks or task methods** – replace specific tasks or task methods with
  predefined results or behavior;
- **Verify task calls** - verify how many times task was called, what parameters were used during
  the call.

Mocks help isolate individual components during testing, making tests faster, safer, and more
focused.

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../processes-v2/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins.basic:mock-tasks:{{ site.concord_core_version }}
```

## Mock definition

Mocks in Concord flows are defined as a `mocks` variable. This variable contains a list of mock definitions, 
each describing how tasks or task methods should behave during testing. 
The fields in a mock definition vary depending on whether you are mocking a task or a task method.

### Fields for Mocking a Task

The following fields are used when mocking a [task call step](../processes-v2/flows.html#task-calls). 
These mocks are applied to steps where tasks are invoked.

| Field         | Type   | Description                                                                                   | Required |   
|---------------|--------|-----------------------------------------------------------------------------------------------|----------|
| `task`        | String | The name of the task being mocked                                                             | **Yes**  |
| `in`          | Object | Input parameters that the task must match for the mock to be applied. Used for mock selection | No       |
| `stepName`    | String | The name of the flow step where the task is invoked. Used for mock selection                  | No       |
| `stepMeta`    | Map    | Metadata for the flow step. Used for mock selection                                           | No       |
| `out`         | Map    | The output to return from the task when this mock is applied                                  | No       |
| `throwError`  | String | The error message to throw when this mock is applied                                          | No       |
| `executeFlow` | String | The name of a flow to execute instead of returning output or throwing an error                | No       |

Selection Criteria: A mock for a task is selected if:
- The task name matches;
- The in, stepName, and stepMeta fields (if provided) match the task invocation parameters.

Key Behavior of `executeFlow`
- The input parameters of the task are passed directly to the flow as-is. The flow can access these parameters directly by their original names;
- The result of the mocked task can be specified by defining the result variable in the flow.

### Fields for Mocking a Task Method

The following fields are used when mocking a [task method](../processes-v2/flows.html#expressions). 
These mocks are applied to steps where specific methods of a task are invoked.

| Field         | Type   | Description                                                                                  | **Required** |
|---------------|--------|----------------------------------------------------------------------------------------------|--------------|
| `task`        | String | The name of the task containing the method being mocked                                      | **Yes**      |
| `method`      | String | The name of the method being mocked                                                          | **Yes**      |
| `args`        | List   | The arguments that the method must match for the mock to be applied. Used for mock selection | No           |
| `stepName`    | String | The name of the flow step where the method is invoked. Used for mock selection               | No           |
| `stepMeta`    | Map    | Metadata for the flow step. Used for mock selection                                          | No           |
| `throwError`  | String | The error message to throw when this mock is applied                                         | No           |
| `executeFlow` | String | The name of a flow to execute instead of returning output or throwing an error               | No           |
| `result`      | Any    | The result to return from the method when this mock is applied                               | No           |

Selection Criteria: A mock for a task method is selected if:
- The task name matches;
- The task method matches;
- The args, stepName, and stepMeta fields (if provided) match the method invocation.

Key Behavior of `executeFlow`
- The method arguments are passed to the flow as a single variable named `args`. This variable contains a list of the method arguments;
- The result of the mocked task can be specified by defining the result variable in the flow.

## How to Mock a Task

You can mock specific tasks to simulate their behavior. 

### Example: Mocking a Task Call

```yaml
flows:
  main:
    - task: myTask
      in:
        param1: "value"
      out: taskResult

  mainTest:
    - set:
        mocks:
          # Mock the myTask task call 
          - task: "myTask"
            out:
              result: 42

    - call: main
      out: taskResult

    - log: "${taskResult}"   # prints out 'result=42'
```

In `mainTest`, we set up a "mock" for the `myTask` task. This mock intercepts calls to any `myTask`
instance and overrides the output, setting the result to `42` instead of running the actual task.

### Example: Mocking a Task Call and Executing a Flow Instead of the Original Task

```yaml
flows:
  main:
    - task: myTask
      in:
        param1: "value"
      out: taskResult

  mainTest:
    - set:
        mocks:
          # Mock the myTask task call 
          - task: "myTask"
            executeFlow: myTaskAsAFlow

    - call: main
      out: taskResult

    - log: "${taskResult}"   # prints out 'result=42'

  myTaskAsAFlow:
    - log: "${param1}" # prints out `value`
    - set:
        result:
          result: 42
```

In `mainTest`, we set up a "mock" for the `myTask` task. This mock intercepts calls to any `myTask`
instance and executes the `myTaskAsAFlow` flow instead of the original task.

### Example: Mocking a Task with Specific Input Parameters

```yaml
flows:
  main:
    - task: myTask
      in:
        param1: "value"
      out: taskResult

  mainTest:
    - set:
        mocks:
          # Mock the myTask task call 
          - task: "myTask"
            in:
              param1: "value.*"  # regular expression allowed for values
            out:
              result: 42

    - call: main
      out: taskResult

    - log: "${taskResult}"   # prints out 'result=42'
```

In `mainTest`, we set up a mock to only intercept `myTask` calls where param1 matched with regular
expression "`value.*`". When these parameter match, the mock replaces the task's output with
`result: 42`

## How to Mock a Task Method

In addition to mocking entire tasks, you can also mock specific methods of a task.

### Example: Mocking a Task Method

```yaml
flows:
  main:
    - expr: ${myTask.myMethod()}
      out: taskResult

  mainTest:
    - set:
        mocks:
          # Mock the myTask task call 
          - task: "myTask"
            method: "myMethod"
            result: 42

    - call: main
      out: taskResult

    - log: "${taskResult}"   # prints out 'result=42'
```

In `mainTest`, we set up a mock to only intercept `myTask.myMethod` calls.
When these parameter match, the mock replaces the task's output with `result: 42`

### Example: Mocking a Task Method and Executing a Flow Instead of the Original Task method

```yaml
flows:
  main:
    - expr: ${myTask.myMethod(1, "one")}
      out: taskResult

  mainTest:
    - set:
        mocks:
          # Mock the myTask task call 
          - task: "myTask"
            method: "myMethod"
            args: 
              - 1
              - "one"
            executeFlow: myTaskMyMethodAsAFlow

    - call: main
      out: taskResult

    - log: "${taskResult}"   # prints out 'result=42'

  myTaskMyMethodAsAFlow:
    - log: "${args[0]}" # prints 1
    - log: "${args[1]}" # prints "one"
    - set:
        result:
          result: 42
```

In `mainTest`, we set up a mock to only intercept `myTask.myMethod` calls with input arguments [1, "one"].
When these parameter match, the mock executes the `myTaskMyMethodAsAFlow` flow instead of the original task method.

### Example: Mocking a Task Method with Input Arguments

```yaml 
flows:
  main:
    - expr: ${myTask.myMethod(1)}
      out: taskResult

  mainTest:
    - set:
        mocks:
          # Mock the myTask task call 
          - task: "myTask"
            args:
              - 1
            method: "myMethod"
            result: 42

    - call: main
      out: taskResult

    - log: "${taskResult}"   # prints out 'result=42'
```

In `mainTest`, we set up a mock to only intercept `myTask.myMethod` calls with input argument `1`.
When these parameter match, the mock replaces the task's output with `result: 42`

### Example: Mocking a Task Method with Multiple Arguments

```yaml
flows:
  main:
    - expr: ${myTask.myMethod(1, 'someComplexVariableHere')}
      out: taskResult

  mainTest:
    - set:
        mocks:
          # Mock the myTask task call 
          - task: "myTask"
            args:
              - 1
              - ${mock.any()}    # special argument that matches any input argument
            method: "myMethod"
            result: 42

    - call: main
      out: taskResult

    - log: "${taskResult}"   # prints out 'result=42'
```

In `mainTest`, we set up a mock to only intercept `myTask.myMethod` calls with input argument `1`
and `any` second argument. When these parameter match, the mock replaces the task's output with
`result: 42`

## How to Verify Task Calls

The `verify` task allows you to check how many times a specific task
(**not necessarily a mocked task**) with specified parameters was called.

### Example: Verifying a Task Call

```yaml
flows:
  main:
    - task: "myTask"
      out: taskResult

  mainTest:
    - call: main

    - expr: "${verify.task('myTask', 1).execute()}"
```

In `mainTest`, we verify that the `myTask` task was called exactly once without input parameters

### Example: Verifying a Task Method Call

```yaml
flows:
  main:
    - expr: ${myTask.myMethod(1)}
      out: taskResult

  mainTest:
    - call: main

    - expr: "${verify.task('myTask', 1).myMethod(1)}"
```

In `mainTest`, we verify that the `myMethod` method of the `myTask` task was called exactly once
with a parameter `1`.
