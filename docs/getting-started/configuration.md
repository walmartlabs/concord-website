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

The path to the configuration file must be passed via `ollie.conf` JVM
parameter like so:
```
java ... -Dollie.conf=/opt/concord/conf/server.conf com.walmartlabs.concord.server.Main
```
When using Docker it can be passed as `CONCORD_CFG_FILE` environment variable.

Here's a complete example of the server configuration file including the
default values. All parameters are optional unless specified:
```
concord-server {

    # API port
    port = 8001

    # database connection
    db {
        # (optional) JDBC URL of the database
        url = "jdbc:postgresql://localhost:5432/postgres"

        # primary database user
        appUsername = "postgres"
        # (mandatory)
        appPassword= "..."

        # database user of the inventory system's  
        inventoryUsername = "postgres"
        # (mandatory)
        inventoryPassword = "..."

        # maximum number of connections per database user
        maxPoolSize = 10
    }

    # "remember me" cookie support
    rememberMe {
        # max age of the "remember me" cookie (sec)
        maxAge = 1209600 # two weeks

        # default value, change for production (base64)
        # should be a valid AES key (16, 24 or 32 bytes)
        # if not set, a new random key will be used
        # cipherKey = "..."
    }

    # email notifications (API key expiration, etc)
    # not related to notifications send from user flows
    email {
        enabled = false

        host = "localhost"
        port = "25"

        connectTimeout = 20000
        readTimeout = 10000

        from = "noreply@example.com"
    }

    # process-related configuration
    process {
        # path to a YAML file with the default process variables
        defaultVariables = "..."

        # max age of the process state data (ms)
        maxStateAge = 604800000

        # max age of failed processes to handle (PG interval)
        maxFailureHandlingAge = "3 days"

        # max age of stalled processes to handle (PG interval)
        maxStalledAge = "1 minute"

        # max age of processes which are failed to start (PG interval)
        maxStartFailureAge = "10 minutes"

        # list of state files that must be encrypted before storing
        secureFiles: ["_main.json"]
    }

    queue {
        # maximum rate at which processes are allowed to start (proc/sec)
        # zero or a negative value disables the rate limiting
        rateLimit = 5

        # maximum time to wait if the process start was rate limited (ms)
        maxRateTimeout = 10000
    }

    # audit logging
    audit {
        enabled = true

        # max age of the audit log data (ms)
        maxLogAge = 604800000
    }

    # git repository cache
    repositoryCache {
        # directory to store the local repo cache
        # created automatically if not specified
        cacheDir = "/tmp/concord/repos"

        # directory to store the local repo cache metadata
        # created automatically if not specified
        metaDir = "/tmp/concord/repo_meta"

        # check if concord.yml is present in the repo
        concordFileValidationEnabled = false

        # timeout for checkout operations (ms)
        lockTimeout = 180000
    }

    # process templates
    template {
        # directory to store process template cache
        # created automatically if not specified
        cacheDir = "/tmp/concord/templates"
    }

    # secrets and encryption
    secretStore {
        # default store to use. See below for store configuration sections
        # case insensitive
        default = concord

        # maximum allowed size of binary secrets (bytes)
        maxSecretDataSize = 1048576

        # maximum allowed size of encrypted strings (used in `crypto.decryptString`, bytes)
        maxEncryptedStringLength = 102400

        # (mandatory), base64 encoded values used to encrypt secrets
        serverPassword = "..."
        secretStoreSalt = "..."
        projectSecretSalt = "..."

        # default DB store
        concord {
            enabled = true
        }
    }

    # process triggers
    triggers {
        # disabling all triggers mean that all events (including repository refresh) will be disabled
        disableAll: false

        # the specified event types will be ignored
        # for example:
        #   disabled: ['cron', 'github']
        # will disable cron scheduling and GitHub notifications
        disabled: []
    }

    # API key authentication
    apiKey {
        # if disabled the keys are never expire
        expirationEnabled = false

        # default expiration period (days)
        expirationPeriod =  30

        # how often Concord will send expiration notifications (days)
        notifyBeforeDays = [1, 3, 7, 15]
    }

    # AD/LDAP authentication
    ldap {
        url = "ldap://oldap:389"
        searchBase = "dc=example,dc=org"
        principalSearchFilter = "(cn={0})"
        userSearchFilter = "(cn=*{0}*)"
        usernameProperty = "cn"
        mailProperty = "mail"

        # used by the Console in the AD/LDAP group search
        groupSearchFilter = "(cn=*{0}*)"
        groupNameProperty = "cn"
        groupDisplayNameProperty = "cn"

        systemUsername = "cn=admin,dc=example,dc=org"
        systemPassword = "..."
    }

    # AD/LDAP group synchronization
    ldapGroupSync {
        # interval between runs (seconds)
        interval = 86400 # one day

        # the number of users fetched at the time
        fetchLimit = 100

        # minimal age of the record (PostgreSQL interval)
        minAge = "1 day"
    }

    # GIT-related configuration
    git {
        # OAUth token to use when no repository secrets are specified
        oauth = "..."

        # use GIT's shallow clone
        shallowClone = true

        httpLowSpeedLimit = 1
        httpLowSpeedTime = 600
        sshTimeoutRetryCount = 1
        sshTimeout = 600
    }

    # GitHub integration
    github {
        enabled = false

        # Concord will try to register webhooks for repository URL that contain this domain
        githubDomain = "github.com"

        # GitHub API url
        apiUrl = "https://github.com/api/v3"

        # API secret, can be anything
        secret = "..."
        # OAuth token to use for webhook registration
        oauthAccessToken = "..."

        # webhook (callback) endpoint. Should be a URL that GitHub can use to connect to Concord
        webhookUrl = "http://localhost:8001/events/github/push"

        # webhook refresh interval (ms)
        refreshInterval = 60000

        # use webhooks to refresh the repo cache
        cacheEnabled = false
    }
}
```

A minimal example suitable for local development (assuming [OpenLDAP](./development.html#oldap)):
```
concord-server {
    db {
        appPassword = "q1"
        inventoryPassword = "q1"
    }

    secretStore {
        # just some random values
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

The path to the configuration file must be passed via `ollie.conf` JVM
parameter like so:
```
java ... -Dollie.conf=/opt/concord/conf/server.conf com.walmartlabs.concord.agent.Main
```
When using Docker it can be passed as `CONCORD_CFG_FILE` environment variable.

Here's a complete example of the agent configuration file including the
default values. All parameters are optional unless specified:
```
concord-agent {

    # unique ID of the agent
    # generated on start if not specified
    id = "..."

    # path to the capabilities JSON file
    # optional
    capabilities = "/path/to/capabilities.json"

    # directory to cache dependencies
    dependencyCacheDir = "/tmp/agent/depsCacheDir"

    # directory to store process dependency lists
    dependencyListsDir = "/tmp/agent/dependencyListsDir"

    # directory to store the process payload
    # created automatically if not specified
    # payloadDir = "/tmp/payload"

    # directory to store the process logs
    # created automatically if not specified
    # logDir = /tmp/logs"

    # maximum delay between log chunks
    # determines how ofter the logs are send back to the server
    logMaxDelay = "2 seconds"

    # maximum number of concurrent processes
    workersCount = 3

    # path to a JRE, used in process containers
    javaPath = "..."

    # interval between new payload requests
    pollInterval = "2 seconds"

    # JVM prefork settings
    prefork {
        # maximum time to keep a preforked JVM
        maxAge = "30 seconds"
        # maximum number of preforks
        maxCount = 3
    }

    # server connection settinss
    server {
        apiBaseUrl = "http://localhost:8001"
        apiBaseUrl = ${?SERVER_API_BASE_URL}

        websockerUrl = "ws://localhost:8001/websocket"
        websockerUrl = ${?SERVER_WEBSOCKET_URL}

        verifySsl = false

        connectTimeout = "30 seconds"
        readTimeout = "1 minute"

        retryCount = 5
        retryInterval = "30 seconds"

        # User-Agent header to use with API requests
        # userAgent = "..."

        # interval between WS ping requests
        maxWebSocketInactivity = "2 minutes"

        # (required) API key to use
        # as defined in server/db/src/main/resources/com/walmartlabs/concord/server/db/v0.69.0.xml
        apiKey = "..."
    }

    docker {
        host = "tcp://127.0.0.1:2375"
        host = ${?DOCKER_HOST}

        orphanSweeperEnabled = false
        orphanSweeperPeriod = "15 minutes"
    }

    repositoryCache {
        # directory to store the local repo cache
        # created automatically if not specified
        # cacheDir = "/tmp/concord/repos"

        # timeout for checkout operations (ms)
        lockTimeout = "3 minutes"
    }

    git {
        oauth = "..."

        # use GIT's shallow clone
        shallowClone = true

        httpLowSpeedLimit = 1
        httpLowSpeedTime = 600
        sshTimeoutRetryCount = 1
        sshTimeout = 600
    }

    runner {
        path = null
        path = ${?RUNNER_PATH}

        securityManagerEnabled = false
        javaCmd = "java"
    }
}
```

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

```
smtpParams:
  host: "smtp.example.com"
  port: 25
```
