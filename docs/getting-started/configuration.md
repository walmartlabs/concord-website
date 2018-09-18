---
layout: wmt/docs
title:  Configuration
side-navigation: wmt/docs-navigation.html
---

# {{ page.title}}

The Concord server can be configured via a number of environment
variables. Typically this is done by the administrator responsible for the
Concord installation.

The environment variables can be set in a startup script or similar
location. When using docker they can be passed as parameters with a `docker run`
command.

A Concord user does not need to be concerned about these settings and instead
needs to define their processes and further details. Check out
[our quickstart guide](./quickstart.html).

The following configuration details are available:

- [Common Environment Variables](#common-environment-variables)
- [Server Configuration File](#server-cfg-file)
- [Server Environment Variables](#server-environment-variables)
- [Server LDAP Authentication](#server-ldap-authentication)
- [Server Slack Connection](#slack)
- [Server GitHub Connection](#github)
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

    # email notifications (API key expiration, etc)
    # not related to notifications send from user flows
    email {
        enabled = false

        host = "localhost"
        port = "25"

        connectTimeout = 20000
        readTimeout = 10000

        from = "noreply@walmart.com"
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

        # process state archive
        archive {
            enabled = false

            # the archival task's period (ms)
            period = 60000

            # maximum time after which the entry will be considered "stalled" (ms)
            stalledAge = 3600000

            # maximum process age after which it is moved to the archive (ms)
            processAge = 86400000

            # maximum parallelism of upload operations
            uploadThreads = 4

            # max age of an archive (ms), disabled if 0
            maxArchiveAge = 1209600000
        }

        # process checkpoints
        checkpoints {
        
            # process checkpoints archive            
            archive {
                enabled = false

                # the archival task's period (ms)
                period = 60000

                # maximum time after which the entry will be considered "stalled" (ms)
                stalledAge = 3600000

                # maximum parallelism of upload operations
                uploadThreads = 4

                # max age of an archive (ms), disabled if 0
                maxArchiveAge = 1209600000
            }
        }
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

        # support for storing secret's binaries in Keywhiz
        keywhiz {
            enabled = false
            
            # automation API URL 
            url = "https://localhost:4444"
            
            # SSL authentication
            trustStore = "/path/to/trustStore.p12"
            trustStorePassword = "..."            
            keyStore = "/path/to/keystore.p12"
            keyStorePassword = "..."
            
            connectTimeout = 5000
            soTimeout = 5000
            connectionRequestTimeout = 5000
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
        systemUsername = "cn=admin,dc=example,dc=org"
        systemPassword = "..."
    }

    # GIT-related configuration
    git {
        # OAUth token to use when no repository secrets are specified
        oauth = "..."

        # use GIT's shallow clone
        shallowClone = true
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

    # S3 support for process state and checkpoint archives
    s3 {
        enabled = false

        # list of S3-compatible endpoints
        destinations: [
            {
                url: "http://localhost:9090",
                accessKey: "a",
                secretKey: "b",
                bucketName: "archive"
            },
            {
                url: "http://localhost:9091",
                accessKey: "a",
                secretKey: "b",
                bucketName: "archive"
            }
        ]
    }
}
```

A minimal example suitable for local development:
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
        principalSearchFilter = "(cn={0})"
        userSearchFilter = "(cn=*{0}*)"
        usernameProperty = "cn"
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
