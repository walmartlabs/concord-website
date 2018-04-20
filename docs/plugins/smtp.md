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

The syntax used to reference any variable defined in the flow requires the usage
of `{{}}` in the template file.

```
The process for this project was started by {{ initiator.displayName }}.
```

To specify the SMTP server in your own Concord file instead of taking advantage of
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

Besides the above mentioned parameters for `mail` for the identifying the sender
`from` and the recipient `to` you can specify emails for carbon copy `cc` and
blind carbon copy `bcc` recipients. 

In addition, you can add an optional `replyTo` field.

The `to`, `cc` and `bcc` parameters support the usage of multiple addresses as a
comma separated list as seen in `cc` configuration or YAML array in the `bcc`
configuration:

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



