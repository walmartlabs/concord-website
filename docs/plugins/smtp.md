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

```yaml
configuration:
  dependencies:
    - mvn://com.walmartlabs.concord.plugins.basic:smtp-tasks:0.50.0
  arguments:
    smtpServer:
      host: smtp-gw1.wal-mart.com
      port: 25
```

With the global configuration in place, email messages can be sent with the task:

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

You can use the email address of the process initiator with the value
`${initiator.attributes.mail}` as the `from` address.
