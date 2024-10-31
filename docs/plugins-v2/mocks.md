---
layout: wmt/docs
title:  Mocks Task
side-navigation: wmt/docs-navigation.html
description: Safely and efficiently simulate behavior, verify interactions, and validate process logic with the Concord Mocks plugin.
---

# {{ page.title }}

- [Usage](#usage)
- [How to mock a task](#how-to-mock-a-task)
- [How to Mock a task method](#how-to-mock-a-task-method)
- [How to Verify task calls](#how-to-verify-task-calls)

Mocks plugin allow you to:

- **Mock tasks or task methods** – replace specific tasks or task methods with predefined results or behavior;
- **Verify task calls** - verify how many times task was called, what parameters were used during the call.

Mocks help isolate individual components during testing, making tests faster, safer, and more focused.

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../processes-v2/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins.basic:mock-tasks:{{ site.concord_core_version }}
```

## How to Mock a task

You can mock specific tasks to simulate their behavior. 

- Example: Task Mock:
```yaml
flows:
  main:
    - task: myTask
      in:
        param1: "value"
      out: taskResult
    
  myTestFlow:
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
In `myTestFlow`, we set up a mock for the `myTask` task. 
This mock intercepts calls to any `myTask` and overrides its output, 
setting the result to 42 instead of running the actual task.

- Example: Mocking a Task with Specific Input Parameters
```yaml
flows:
  main:
    - task: myTask
      in:
        param1: "value"
      out: taskResult
    
  myTestFlow:
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
In `myTestFlow`, we set up a mock to only intercept `myTask` calls where param1 matched with regular expression "value.*".
When these parameter match, the mock replaces the task's output with `result: 42`

## How to Mock a task method

You can mock specific tasks method to simulate their behavior.

- Example: Task Method Mock
```yaml
flows:
  main:
    - expr: ${myTask.myMethod()}
      out: taskResult
    
  myTestFlow:
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

In `myTestFlow`, we set up a mock to only intercept `myTask.myMethod` calls.
When these parameter match, the mock replaces the task's output with `result: 42`

- Example: Task Method Mock with Input Arguments
```yaml
flows:
  main:
    - expr: ${myTask.myMethod(1)}
      out: taskResult
    
  myTestFlow:
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

In `myTestFlow`, we set up a mock to only intercept `myTask.myMethod` calls with input argument `1`.
When these parameter match, the mock replaces the task's output with `result: 42`

- Example of Task method Mock with input arguments:
```yaml
flows:
  main:
    - expr: ${myTask.myMethod(1, 'someComplexVariableHere')}
      out: taskResult
    
  myTestFlow:
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

In `myTestFlow`, we set up a mock to only intercept `myTask.myMethod` calls with input argument `1` and `any` second argument.
When these parameter match, the mock replaces the task's output with `result: 42`

## How to Verify task calls

The `verify` task allows you to check how many times a specific task (**not necessarily a mocked task**)
with specified parameters was called.

- Example: Verifying a Task Call
```yaml
flows:
  main:
    - task: "myTask"
      out: taskResult
    
  myTestFlow:
    - call: main

    - expr: "${verify.task('myTask', 1).execute()}"
```

In `myTestFlow`, we verify that the `myTask` task was called exactly once without input parameters

- Example: Verifying a Task Method Call
```yaml
flows:
  main:
    - expr: ${myTask.myMethod(1)}
      out: taskResult
    
  myTestFlow:
    - call: main

    - expr: "${verify.task('myTask', 1).myMethod(1)}"
```

In `myTestFlow`, we verify that the `myMethod` method of the `myTask` task was called exactly once with a parameter `1`
