# Tasks

> Getting Things Done With Concord


## Overview

- Tasks are the glue to external systems
- Implemented in Java
- Pulled as dependencies
- Usage configured in Concord DSL


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


## More About Tasks

- Alternatively invoke via 
  - EL using `${}`
  - EL using `expr`
  - Task name e.g. `log:`
- Easy to implement
- Work with Concord team


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


## Log Task

Via other method e.g. `info`

```
    - ${log.info("mylog", "logging an warn message")}
```

Method names differ for each task!


## Key Value Task

-`kv` task
- create, read, update and delete
- stored in Concord
- project scope
- stringg and long
- sequence generation with `inc`


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


## Crypto Task

- Access to secrets
  - keys
  - credentials
- Encrypt and Decrypt

Note:
- maybe demo, maybe add example to deck..


## Concord Task

Kick off Concord process

tbd


## SMTP Task

tbd


## Slack Example

tbd

## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

