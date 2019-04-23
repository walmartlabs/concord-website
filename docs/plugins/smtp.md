---
layout: wmt/docs
title:  SMTP Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

To send email notifications as a step of a flow, use the `smtp` task.

## Usage

To make use of the `smtp` task, first declare the plugin in `dependencies` under
`configuration`. This allows you to add an `smtp` task in any flow as a step.

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins.basic:smtp-tasks:{{ site.concord_core_version }}
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

The `mail` input parameters includes the parameters `from` to specify the email
address to be used as the sender address, `to` for the recipient address,
`subject` for the message subject and `message` for the actual message body.

## Optional Parameters

You can add `cc` and `bcc` recipient email addresses, and  specify 
a `replyTo` address.

In the `to`, `cc`, and `bcc` fields, you can handle multiple addresses, either as 
a comma separated list shown in the following `cc` configuration, or a YAML array 
as in the following `bcc` configuration:

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

To send an email to the process initiator, you can use the
attribute `initiator.attributes.mail`.

## Message Template

Concord supports the use of a separate file for longer email messages. As an
alternative to `message`, specify `template` and point to a file in your project
that contains the message text:

```yaml
        template: mail.mustache
```

The template engine [Mustache](https://mustache.github.io/) is used to process
email template files, so you can use any variables from the Concord process
context in the message.

When creating content in a template file, you can reference any variable that is
defined in the flow using double open `{` and closing curly braces `}` in the
template file:

<pre>
<code>
The process for this project was started by &#123;&#123; initiator.displayName  &#125;&#125;.
</code>
</pre>

## SMTP Server

For email notifications with the `smtp` task to work, the connections details
for your SMTP server must specified using one of the following options:

- as a global default process configuration
- as a configuration within your Concord file

In most cases, a Concord administrator takes care of this configuration on a
global default process configuration.

### SMTP as Default Process Configuration
 
The simplest and cleanest way to activate the task and specify the SMTP server
connection details is to set up a
[default process configuration](../getting-started/configuration.html#default-process-variable):

1. Under `configuration/dependencies`, specify the `smtp-tasks` plugin. 
2. Add `smtpParams` as an `argument` and specify the SMTP server `host` and 
`port` as attributes:

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins.basic:smtp-tasks:0.66.0
  arguments:
    smtpParams:
      host: smtp.example.com
      port: 25
```

### Specific SMTP Server in Your Concord File

In some cases you might want to specify the SMTP server in your own Concord
flow, instead of using the global configuration. This approach is required if no
global configuration is set up.

First, add the plugin as a dependency:

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins.basic:smtp-tasks:0.66.0
```
 
Then set the `smtpParams` with the connection details for any usage of
the `smtp` task:

```yaml
flows:
  default:
  - task: smtp
    in:
      smtpParams:
        host: smtp.example.com
        port: 25
      mail:
        from: sender@example.com
        to: recipient@example.com
        subject: "Hello from Concord"
        message: "My message"
```

Consider using a global variable to store the parameters in case of multiple
`smtp` invocations.
