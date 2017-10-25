# Tasks

> Getting Things Done With Concord


## Overview

- Tasks are the glue to external systems
- Implemented in Java
- Pulled as dependencies
- Usage configured in Concord DSL


## Tasks for Concord Usage

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

- Alternatively invoke via EL
- Easy to implement
- Work with Concord team


## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

