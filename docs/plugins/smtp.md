---
layout: wmt/docs
title:  SMTP Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}


To send email notifications as part of a flow, use the `smtp` task.

In most cases, a Concord administrator takes care of any [prerequisite
connection to your SMTP server](#smtp-as-default-process-variable).

## Usage

To make use of the `smtp` task, first declare the plugin in `dependencies` under 
`configuration`, then specify email parameters within an `smtp` task, as in the
following example:

```yaml
configuration:
  dependencies:
    - mvn://com.walmartlabs.concord.plugins.basic:smtp-tasks:0.50.0
flows:
  default:
  - task: smtp
    in:
      mail:
        from: sender@example.com
        to: recipient@example.com
        subject: "Hello from Concord"
        message: "My message"
```

### Add Optional Parameters and Lists

You can add optional `cc` and `bcc` recipient email addresses, and also an 
optional `replyTo` field.

In the `to`, `cc`, and `bcc` feilds, you can handle multiple addresses either as 
a comma separated list (as in the following `cc` configuration), or a YAML array 
(as in the following `bcc` configuration):

```yaml
flows:
  default:
  - task: smtp
    in:
      mail:
        from: sender@example.com
        to: recipient-a@example.com
        cc: abc@example.com,def@example.com,ghi@example.com
        bcc:
        - 123@example.com
        - 456@example.com
        - 789@example.com
        replyTo: feedback@example.com
        subject: "Hello from Concord"
        message: "My message"
```

### Mustache Template

Looper supports the use of [Mustache](https://mustache.github.io/) to process 
email template files.

This means that, as an optional alternative to `message`, you can specify 
`template` and point to a `mustache` file that contains the message text:

```yaml
        template: mail.mustache
```

When creating content in a template file, you can reference any variable that 
is defined in the flow using double curly braces (`{{}}`), as in the following example:

```
The process for this project was started by {{ initiator.displayName }}.
```

Use variable values that are defined in the flow--attributes or variables like `initiator.displayName`, `initiator.username`, and others.


## SMTP Server

For the SMTP task to work, your email server, hostname and port must be 
specified using one of the following options:

- as a default process variable
- as a configuration dependency within your flow

### SMTP as Default Process Variable
 
The simplest and cleanest way to specify the `smtpServer` is to set up a 
[default process variable](../getting-started/configuration.html#default-process-variable):

1. Under `configuration/dependencies`, specify the `smtp-tasks` plugin. 
2. Add `smtpParams` as an `argument` and specify the SMTP server `host` and 
`port` as child parameters.

Following is an example:

```yaml
configuration:
  dependencies:
    - mvn://com.walmartlabs.concord.plugins.basic:smtp-tasks:0.50.0
  arguments:
    smtpParams:
      host: smtp-gw1.wal-mart.com
      port: 25
```

### Specify SMTP Server Within Flow

In some cases you might want to specify the SMTP server in your own Concord flow 
instead of using the global value. 

To do this:

1. Set the parameters as an argument as in the following example:

```yaml
configuration:
  dependencies:
    - mvn://com.walmartlabs.concord.plugins.basic:smtp-tasks:0.50.0
  arguments:
    smtpParams:
      host: smtp-gw1.wal-mart.com
      port: 25
```

2. Specify the email as input for a task as in the following example:

```yaml
flows:
  default:
  - task: smtp
    in:
      smtp: ${smtpParams}
        mail:
        from: sender@example.com
        to: recipient@example.com
        subject: "Hello from Concord"
        message: "My message"
```




