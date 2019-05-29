# Tasks

> Getting Things Done With Concord

<!--- vertical -->

## Overview

- Tasks are the glue to external systems
- Implemented in Java
- Pulled as dependencies
- Usage configured in Concord DSL

Note:
- This is where we get into the meat of concord, and getting things done.
- Tasks are implemented as plugins - written in Java, and available as dependencies,
such as groovy example from earlier, and usage is defined in Concord DSL.

<!--- vertical -->

## Concord Extension Tasks

- Concord
- Crypto
- Key Value
- Log
- Variables

Note:
- provide more features in normal flows
- describe each a bit
- Crypto works with Concord secrets
- Concord task can kick off other tasks
- Used log already, and the `set` step with variables earlier
- Read the other tasks on the list

<!--- vertical -->

## Integration Tasks

- Ansible
- Boo & OneOps
- Docker
- JIRA
- Slack
- SMTP
- Terraform
- Git and GitHub
- and others

Note: 
- describe each a bit
- https://github.com/walmartlabs/concord/tree/master/plugins/tasks
- https://github.com/walmartlabs/concord-plugins/tree/master/tasks

<!--- vertical -->

## Example Usage

Invocation with input, output and error capture:

```yaml
flows:
  default:
  - task: myTask
    in:
      taskVar: ${processVar}
      anotherTaskVar: "a literal value"
    out:
      processVar: ${taskVar}
    error:
    - log: something bad happened
```

Note:
- No surprise, use `task` to invoke a task, add the name, and then
provide input/output/error scenarios
- in - provide variables, as an expr or a literal value
- can capture output with `out` to use later
- react to errors in `error`

<!--- vertical -->

## More About Tasks

- Alternatively invoke via 
  - EL using `${}`
  - EL using `expr`
  - Task name e.g. `log:`
- Easy to implement
- Work with Concord team

Note:
- EL - read these bullets
- Can also call with just the task name, like 'log'

<!--- vertical -->

## Log Task

Simple task to add log output support via task `call` method:

```yaml
flows:
  default:
  - log: "My message"
  - ${log.call("Another message")}
```

Note:
- any task implements call
- Emphasize the 2nd command works just like the first

<!--- vertical -->

## Log Task

Via other method e.g. `info`

```yaml
- ${log.info("mylog", "logging an warn message")}
```

Method names differ for each task!

Note:
- Can use other methods - to figure out what those are, can look at source
- E.g. https://gecgithub01.walmart.com/devtools/concord/tree/master/plugins/tasks/log/src/main/java/com/walmartlabs/concord/plugins/log

<!--- vertical -->

## Key Value Task

- `kv` task
- create, read, update and delete
- stored in Concord
- project scope
- string and long
- sequence generation with `inc`

Note:
- CRUD operattions on key value pair - it's stored IN concord,
which means KVs available across processes in the project

<!--- vertical -->

## Key Value Tasks Examples

```yaml
flows:
  default
  - ${kv.putString("key", "value")}
  - log: ${kv.getString("key")}
  - expr: ${kv.inc("idSeq")}
    out: myId
  - log: "We got an ID: ${myId}"
```

Note:
- Show you can use whatever method you want.
- Create step 1, read, then increment idSeq, get that number out, and log it
- Can be used as a counter (e.g. how many people registered/confirmed attendance for class?)

<!--- vertical -->

## Crypto Task

- Access to secrets
  - keys
  - credentials
- Encrypt secret
  - in project settings in Concord Console
  - or with REST API
- Decrypt in flow with task

Note:
- maybe demo, maybe add example to deck..
- e.g. OneOps API token 
- You create secrets via concord console (go review where again), and they're stored in
concord. 
- The crypto task allows you to access them.
- Can also use task to encrypt secret via API and have it not stored in Concord, but in your repo

<!--- vertical -->

## SMTP Task

Send emails!

First configure:

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins.basic:smtp-tasks:1.6.0
```

Note:
- Send emails! Not core, so need to add as dependency.
- Check Concord version - don't use task version newer than Concord
- Copy dependency string to concord.yml

<!--- vertical -->

## SMTP

And send the email:

```yaml
flows:
  default:
  - task: smtp
    in:
      mail:
        from: ${initiator.attributes.mail}
        to: somebody@example.com
        subject: "Hello"
        message: "Your process started."
```

Or Moustache `template:` file.

Note:
- Copy task block from slide
- In concord.yml, add `- call: notify` to default flow
- Create a `notify` flow, paste in the task block copied from slide
- Update 'to' to be your email
- Commit and demo (log - show smtp in classpath)
- Can use exprs or can use 'template' instead of 'message'
- E.g. https://gecgithub01.walmart.com/strati/training-admin

<!--- vertical -->

## Slack Example

Message to slack channel:

- global config with API Bot token
- add bot to channel
- and use it

```yaml
flows:
  default:
  - task: slack
    in:
      channelId: "your-channel"
      text: "Starting execution on Concord"
```

Note:
- Need to invite Concord bot to channel to post

<!--- vertical -->

## Concord Task

Work with other Concord processes

- Fork current process
- Create sub processes
- Cancel processes
- Wait and get output
- Cancellations and failures

Note:
- Helps you work with other processes - read slide

<!--- vertical -->

## Concord Task Example

```yaml
flows:
  default:
  - task: concord
    in:
      action: start
      org: Default
      project: myProject
      repository: myRepo
```

Note:
- Arguably need to have a really complex scenario to utilize this effectively
- Need to add as a dependency, point out gets more specific line by line

<!--- vertical -->

## HTTP Task

Interact with any REST endpoint.

- very powerful since most applications expose REST API
- built-in
- supports authentication
- response can be captured
- and then used in follow up steps

Note:
- Swiss army knife task, b/c it lets your process interact with REST APIs
- Can get/put to REST APIs
- Since REST APIs are everywhere, lots of versatility w/o a ton of custom plugins
- Supports authentication, and response can be captured and used in follow-up steps

<!--- vertical -->

## HTTP Task Example

```yaml
- task: http
  in:
    method: GET
    url: "http://host:post/path/endpoint"
    response: string
    out: response
- if: ${response.success}
  then:
   - log: "Response received: ${response.content}"
```

Note:
- Walk through example, then show dewey registration
- E.g. https://gecgithub01.walmart.com/devtools/sde-dewey-registration/blob/master/concord.yml

<!--- vertical -->

## More Tasks

Let explore some in source and examples!

- Git
- GitHub
- Gremlin
- JIRA
- Locale
- Automaton
- Datetime
- Terraform

And more are on the way.

Note:
- https://github.com/walmartlabs/concord/tree/master/plugins
- https://github.com/walmartlabs/concord/tree/master/examples
- Go to http://concord.walmart.com/docs/plugins/jira.html and skim through docs

<!--- vertical -->

## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

