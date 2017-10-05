---
layout: wmt/docs
title:  Concord
side-navigation: wmt/docs-navigation.html
---

# Concord Task

This task allows users to start and manage new processes from within
running processes.

## Starting a Process using a Payload Archive

```yaml
flows:
  default:
  - task: concord
    in:
      action: start
      archive: payload.zip
```

This expression will start a new subprocess using the specified
payload archive. The ID of the started process will be stored as
the first element of `${jobs}` array:

```yaml
- log: "I've started a new process: ${jobs[0]}"
```

## Forking a Process

Forking a process will create a copy of the current process. All
variables and files defined at the start of the parent process will
be copied to the child process as well:

```yaml
flows:
  default:
  - task: concord
    in:
      action: fork
      entryPoint: sayHello
        
  sayHello:
  - log: "Hello from a subprocess!"
```

The IDs of the started processes will be stored as `${jobs}` array.

**Note** Due to the current limitations, variables and files created
after the start of a process cannot be copied to child processes.

## Forking Multiple Instances

It is possible to create multiple forks of a process with different
sets of parameters:

```yaml
flows:
  default:
  - task: concord
    in:
      action: fork
      jobs:
      - entryPoint: pickAColor
        arguments:
          color: "red"
      - entryPoint: pickAColor
        arguments:
          color: "green"
      - entryPoint: pickAColor
        instances: 2
        arguments:
          color: "blue"
```

The `instances` parameters allows spawning more than one copy of a
process.

The IDs of the started processes will be stored as `${jobs}` array.

## Synchronous Execution

By default all subprocesses are started asynchronously. To start a
process and wait for it completion use `sync` parameter:

```yaml
flows:
  default:
  - tasks: concord
    in:
      action: start
      archive: payload.zip
      sync: true
```

If a subprocess fails, the task will throw an exception.

## Waiting for Completion

To wait for a completion of a process:
```yaml
flows:
  default:
  - ${concord.waitForCompletion(jobIds)}
```

The `jobIds` value should be a list (as in `java.util.List`) of
process IDs.

The expression returns a map of process statuses:
```json
{
  "56e3dcd8-a775-11e7-b5d6-c7787447ca6d": "FINISHED",
  "5cd83364-a775-11e7-aadd-53da44242629": "FAILED"
}
```

## Handling Cancellation and Failures

Just like regular processes, subprocesses can have `onCancel` and
`onFailure` flows.

However, as process forks share their flows, it may be useful to
disable `onCancel` or `onFailure` flows in subprocesses:

```yaml
flows:
  main:
  - task: concord
    in:
      action: fork
      disableOnCancel: true
      disableOnFailure: true
      entryPoint: sayHello
      
  sayHello:
  - log: "Hello!"
  - ${misc.throwBpmnError("oh no!")}
  
  # will be invoked only for the parent process
  onCancel:
  - log: "Handling a cancellation..."
  
  # will be invoked only for the parent process
  onFailure:
  - log: "Handling a failure..."
```

## Cancelling Processes

```yaml
flows:
  main:
  - task: concord
    in:
      action: cancel
      instanceId: ${someId}
      sync: true
```

The `instanceId` parameter can be a single value or a list of process
IDs.

Setting `sync` to `true` will make the task to wait until the
specified processes are stopped.

## Tagging Subprocesses

```yaml
flows:
  main:
  - task: concord
    in:
      action: start
      archive: payload.zip
      tags: ["someTag", "anotherOne"]
```

This will start a new subprocess tagged with `someTag` and `anotherOne`.

Tags are useful for filtering (sub)processes:
```yaml
flows:
  main:
  # spawn multiple tagged processes
  
  onCancel:
  - task: concord
    in:
      action: kill
      instanceId: "${concord.listSubprocesses(parentInstanceId, 'someTag')}"
```