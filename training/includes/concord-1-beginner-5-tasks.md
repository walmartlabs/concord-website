# Tasks

> Getting Things Done With Concord

<!--- vertical -->

## Overview

- Tasks are the glue to external systems
- Implemented in Java
- Pulled as dependencies
- Usage configured in Concord DSL

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

<!--- vertical -->

## Integration Tasks

- Ansible
- Boo & OneOps
- Docker
- JIRA
- Slack
- SMTP
- Teamrosters

Note: 
- describe each a bit
- https://gecgithub01.walmart.com/devtools/concord/tree/master/plugins/tasks
- https://gecgithub01.walmart.com/devtools/concord-plugins/tree/master/tasks

<!--- vertical -->

## Example Usage

Invocation with input, output and error capture:

```
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

<!--- vertical -->

## More About Tasks

- Alternatively invoke via 
  - EL using `${}`
  - EL using `expr`
  - Task name e.g. `log:`
- Easy to implement
- Work with Concord team

<!--- vertical -->

## Log Task

Simple task to add log output support via task `call` method:

```
flows:
  default:
  - log: "My message"
  - ${log.call("Another message")}
```

Note:
any task implements call

<!--- vertical -->

## Log Task

Via other method e.g. `info`

```
- ${log.info("mylog", "logging an warn message")}
```

Method names differ for each task!

<!--- vertical -->

## Key Value Task

- `kv` task
- create, read, update and delete
- stored in Concord
- project scope
- string and long
- sequence generation with `inc`

<!--- vertical -->

## Key Value Tasks Examples

```
flows:
  default
  - ${kv.putString("key", "value")}
  - log: ${kv.getString("key")}
  - expr: ${kv.inc("idSeq")}
    out: myId
  - log: "We got an ID: ${myId}"
```

<!--- vertical -->

## Crypto Task

- Access to secrets
  - keys
  - credentials
- Encrypt secret via API
- Decrypt in flow with task

Note:
- maybe demo, maybe add example to deck..
- e.g. OneOps API token 

<!--- vertical -->

## SMTP Task

Send emails!

First configure:

```
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins.basic:smtp-tasks:0.73.0
```

<!--- vertical -->

## SMTP

And send the email:

```
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

<!--- vertical -->

## Slack Example

Message to slack channel:

- global config with API Bot token
- add bot to channel
- and use it

```
flows:
  default:
  - task: slack
    in:
      channelId: "you-channel"
      text: "Starting execution on Concord"
```

<!--- vertical -->

## Concord Task

Work with other Concord processes

- Fork current process
- Create sub processes
- Cancel processes
- Wait and get output
- Cancellations and failures

<!--- vertical -->

## Concord Task Example

```
flows:
  default:
  - task: concord
    in:
      action: start
      project: myProject
      repository: myRepo
```

<!--- vertical -->

## HTTP Task

Interact with any REST endpoint.

- very powerful since most applications expose REST API
- built-in
- supports authentication
- response can be captured
- and then used in follow up steps

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

<!--- vertical -->

## More Tasks

Let explore some in source and examples!

- Git
- GitHub
- JIRA
- Locale
- Automaton

And more are on the way.

Note:
- https://gecgithub01.walmart.com/devtools/concord/tree/master/plugins
- https://gecgithub01.walmart.com/devtools/concord/tree/master/examples

<!--- vertical -->

## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

