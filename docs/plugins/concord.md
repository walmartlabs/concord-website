---
layout: wmt/docs
title:  Concord Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `concord` task allows users to start and manage new processes from within
running processes.

The task is provided automatically for all flows, no external dependencies
necessary.

## Examples

- [process_from_a_process](https://gecgithub01.walmart.com/devtools/concord/tree/master/examples/process_from_a_process) - starting a new subprocess from a flow using a payload archive;
- [fork](https://gecgithub01.walmart.com/devtools/concord/tree/master/examples/fork) - starting a subprocess;
- [fork_join](https://gecgithub01.walmart.com/devtools/concord/tree/master/examples/fork_join) - starting multiple subprocesses and waiting for completion.

## Starting a Process using a Payload Archive

```yaml
flows:
  default:
  - task: concord
    in:
      apiKey: "..."
      action: start
      archive: payload.zip
```

The `start` action starts a new subprocess using the specified payload archive.
The ID of the started process is stored as the first element of `${jobs}` array:

```yaml
- log: "I've started a new process: ${jobs[0]}"
```

## Starting a Process using an Existing Project

```yaml
flows:
  default:
  - task: concord
    in:
      action: start
      project: myProject
      archive: payload.zip
```

The `start` expression with a `project` parameter and an `archive`, starts a new
subprocess in the context of the specified project.

Alternatively, if the project has a repository configured, the process can be
started by configuring the repository:

```yaml
flows:
  default:
  - task: concord
    in:
      action: start
      project: myProject
      repository: myRepo
```

The process is started using the resources provided by the specified archive, 
project and repository.

## Output Variables

Variables of a child process can be accessed via the `outVars` configuration. 
The functionality requires the `sync` parameter to be set to `true`.

```yaml
flows:
  default:
  - task: concord
    in:
      action: start
      project: myProject
      repository: myRepo
      sync: true
      # list of variable names
      outVars:
      - someVar1
      - someVar2
```

Output values are stored as a `jobOut` variable:

```yaml
- log: "We got ${jobOut.someVar1} and ${jobOut.someVar2}!"
```

## Forking a Process

Forking a process creates a copy of the current process. All variables and
files defined at the start of the parent process are copied to the child process
as well:

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

The IDs of the started processes are stored as `${jobs}` array.

**Note** Due to the current limitations, variables and files created
after the start of a process cannot be copied to child processes.

## Forking Multiple Instances

It is possible to create multiple forks of a process with a different
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

The `instances` parameter allows spawning of more than one copy of a process.

The IDs of the started processes arestored as `${jobs}` array.

## Synchronous Execution

By default all subprocesses are started asynchronously. To start a process and
wait for it to complete, use `sync` parameter:

```yaml
flows:
  default:
  - tasks: concord
    in:
      action: start
      archive: payload.zip
      sync: true
```

If a subprocess fails, the task throws an exception.

## Waiting for Completion

To wait for a completion of a process:

```yaml
flows:
  default:
  - ${concord.waitForCompletion(jobIds)}
```

The `jobIds` value is a list (as in `java.util.List`) of process IDs.

The expression returns a map of process statuses:

```json
{
  "56e3dcd8-a775-11e7-b5d6-c7787447ca6d": "FINISHED",
  "5cd83364-a775-11e7-aadd-53da44242629": "FAILED"
}
```

## Handling Cancellation and Failures

Just like regular processes, subprocesses can have `onCancel` and `onFailure` flows.

However, as process forks share their flows, it may be useful to disable
`onCancel` or `onFailure` flows in subprocesses:

```yaml
flows:
  default:
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

The `cancel` action can be used to cancel the execution of a subprocess.

```yaml
flows:
  default:
  - task: concord
    in:
      action: cancel
      instanceId: ${someId}
      sync: true
```

The `instanceId` parameter can be a single value or a list of process
IDs.

Setting `sync` to `true` forces the the task to wait until the specified processes
are stopped.

## Tagging Subprocesses

The `tags` parameters can be used to tag new subprocess with one or multiple
labels.

```yaml
flows:
  default:
  - task: concord
    in:
      action: start
      archive: payload.zip
      tags: ["someTag", "anotherOne"]
```


Tags are useful for filtering (sub)processes:

```yaml
flows:
  default:
  # spawn multiple tagged processes
  
  onCancel:
  - task: concord
    in:
      action: kill
      instanceId: "${concord.listSubprocesses(parentInstanceId, 'someTag')}"
```

## Connection Parameters

By default, the task uses the same Concord instance and user that
started the flow.

Connection parameters can be overridden using the following keys:
- `baseUrl` - Concord REST API endpoint. Defaults to the current
  server's API endpoint address;
- `apiKey` - user's REST API key.

For example:

```yaml
flows:
  default:
  - task: concord
    in:
      baseUrl: "http://concord.example.com:8001"
      apiKey: "lzfJQL4u2gsH7toQveFYSQ"
```
