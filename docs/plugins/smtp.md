---
layout: wmt/docs
title:  SMTP Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The SMTP `smtp` task supports sending email messages as part of a flow.

## Usage

This task needs to be declared as a dependency to be used and the SMTP server
used to send the message has to be specified with hostname and port.

The simplest and cleanest way to specify the `smtpServer` is to specify it as a 
[default process variable](../getting-started/configuration.html#default-process-variable)
called `smtpParams`.

```yaml
configuration:
  dependencies:
    - mvn://com.walmartlabs.concord.plugins.basic:smtp-tasks:0.50.0
  arguments:
    smtpParamsServer:
      host: smtp-gw1.wal-mart.com
      port: 25
```

With the global configuration in place, email messages can be sent using the task:

```yaml
flows:
  default:
    - task: smtp
      in:
        smtp: ${smtpServer}
        mail:
          from: sender@example.com
          to: recipient@example.com
          subject: "Hello from Concord"
          message: "My message"
```

The `message` can be replaced with a `template`. It is configured to
the name of a file that contains the message text. It is added into the email
via processing with [Mustache](https://mustache.github.io/) and can therefore
use variable values from the flow such as attributes or `initiator.displayName`,
`initiator.username` and others.

```
          template: mail.moustache
```

To specify the SMTP server in your own Concord file instead taking advantage of
a global default value, set the parameter as an argument:

```yaml
configuration:
  dependencies:
    - mvn://com.walmartlabs.concord.plugins.basic:smtp-tasks:0.50.0
  arguments:
    smtpParams:
      host: smtp-gw1.wal-mart.com
      port: 25
```

And then specify the email as input for a task:

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

You can specifying multiple recipients using several options.

- add`cc` and/or `bcc` fields
- add a recipient list as a CSV into any recipient field

In addition, you can add an optional `replyTo` field and specify one or more 
recipients to which replies can be sent.

Here's an example:

```yaml
flows:
  default:
    - task: smtp
      in:
        smtp: ${smtpParams}
        mail:
          from: sender@example.com
          to: recipient-a@example.com
          cc: recipient-b@example.com
          bcc: recipient-c@example.com,recipient-d@example.com
          replyTo: feedback@example.com,product-team@example.com
          subject: "Hello from Concord"
          message: "My message"
```



