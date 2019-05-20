---
layout: wmt/docs
title:  Configuration
side-navigation: wmt/docs-navigation.html
---

# {{ page.title}}

The Concord server can be configured via a configuration file. Typically this
is done by the administrator responsible for the Concord installation.

A Concord user does not need to be concerned about these settings and instead
needs to define their processes and further details. Check out
[our quickstart guide](./quickstart.html).

The following configuration details are available:

- [Common Environment Variables](#common-environment-variables)
- [Server Configuration File](#server-cfg-file)
- [Server Environment Variables](#server-environment-variables)
- [Agent Configuration File](#agent-cfg-file)
- [Process Runtime Variables](#process-runtime-variables)
- [Default Process Variables](#default-process-variables)

<a name="common-environment-variables"/>

## Common Environment Variables

<a name="dependencies"/>
### Dependencies

| Variable           | Description                           | Default value |
|--------------------|---------------------------------------|---------------|
| CONCORD_MAVEN_CFG  | Path to a JSON file                   | _empty_       |

Expected format of the configuration file:

```json
{
  "repositories": [
    {
      "id": "central",
      "layout": "default",
      "url": "https://repo.maven.apache.org/maven2/"
    }
  ]
}
```

<a name="server-cfg-file"/>

## Server Configuration File

Concord Server uses [Typesafe Config](https://github.com/lightbend/config)
format for its configuration files.

The path to the configuration file must be passed via `ollie.conf` JVM
parameter like so:

```bash
java ... -Dollie.conf=/opt/concord/conf/server.conf com.walmartlabs.concord.server.Main
```

When using Docker it can be passed as `CONCORD_CFG_FILE` environment variable.

The complete configuration file for the Server can be found in
[the source code repository](https://github.com/walmartlabs/concord/blob/master/server/dist/src/main/resources/concord-server.conf).

A minimal example suitable for local development (assuming [OpenLDAP](./development.html#oldap)):

```json
concord-server {
    db {
        appPassword = "q1"
        inventoryPassword = "q1"
    }

    secretStore {
        # just some random base64 values
        serverPassword = "cTFxMXExcTE="
        secretStoreSalt = "SCk4KmBlazMi"
        projectSecretSalt = "I34xCmcOCwVv"
    }

    ldap {
        url = "ldap://oldap:389"
        searchBase = "dc=example,dc=org"
        systemUsername = "cn=admin,dc=example,dc=org"
        systemPassword = "admin"
    }
}
```

<a name="server-environment-variables"/>

## Server Environment Variables

All parameters are optional.

### Forms

| Variable        | Description                          | Default value               |
|-----------------|--------------------------------------|-----------------------------|
| FORM_SERVER_DIR | Directory to store custom form files | _a new temporary directory_ |

### HTTPS support

| Variable       | Description                                  | Default value |
|----------------|----------------------------------------------|---------------|
| SECURE_COOKIES | Enable `secure` attribute on server cookies. | false         |

<a name="agent-cfg-file"/>

## Agent Configuration File

Concord Agent uses [Typesafe Config](https://github.com/lightbend/config)
format for its configuration files.

The path to the configuration file must be passed via `ollie.conf` JVM
parameter like so:

```bash
java ... -Dollie.conf=/opt/concord/conf/server.conf com.walmartlabs.concord.agent.Main
```

When using Docker it can be passed as `CONCORD_CFG_FILE` environment variable.

The complete configuration file for the Agent can be found in
[the source code repository]({{ site.concord_source}}tree/master/agent/src/main/resources/concord-agent.conf).

The configuration file is optional for local development.

## Process Runtime Variables

Specific Concord project executions are processes on the so-called _agents_.
The following parameters affect the agent configuration used for any process
execution. All parameters are optional.

| Variable          | Description                                     | Default value               |
|-------------------|-------------------------------------------------|-----------------------------|
| SERVER_HOST       | Hostname of the server.                         | `localhost`                 |
| SERVER_PORT       | Port of the server's API for agents.            | `8101`                      |
| AGENT_LOG_DIR     | Directory to store payload execution log files. | _a new temporary directory_ |
| AGENT_PAYLOAD_DIR | Directory to store unpacked payload files.      | _a new temporary directory_ |
| AGENT_JAVA_CMD    | Path to `java` executable.                      | `java`                      |
| DEPS_CACHE_DIR    | Path to a directory for the dependency cache.   | _a new temporary directory_ |

## Default Process Variables

As a Concord administrator, you can set default variable values that
are automatically set in all process executions.

This allows you to set global parameters such as the connection details for
an SMTP server used by the [SMTP task](../plugins/smtp.html) in one central
location separate from the individual projects.

The values are configured in a YAML file. The path to the file and the name are
configured in [the server's configuration file](#server-cfg-file). The
following example, shows how to configure an SMTP server to be used by all
processes. As a result, project authors do not need to specify the SMTP server
configuration in their
own `concord.yml`.

```yml
smtpParams:
  host: "smtp.example.com"
  port: 25
```
