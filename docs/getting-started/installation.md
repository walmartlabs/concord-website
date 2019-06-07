---
layout: wmt/docs
title:  Installation
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The fastest way to get a Concord instance up and running is to use the
pre-built Docker images to run all four components of Concord:

- the Database
- Concord Server
- Concord Console
- Concord Agent

If you already have access to a Concord deployment or after finishing these
installation steps, you can read the [Introduction to Concord](./index.html)
to understand the basic concepts of Concord or set up your first project with
the [quick start tips](./quickstart.html).

## Prerequisites

### Docker

If you do not already have Docker installed, find binaries and instructions
on the [Docker website](https://www.docker.com/). You can install Docker through
various methods that are outside the scope of this document.

### Referencing a Private Docker Registry

If you are using a private Docker registry, add its name to an image name in
the examples below.  For example, if your private docker registry is running
on `docker.myorg.com` this command:

```
docker run ... walmartlabs/concord-agent
```

has to be run as:

```
docker run ... docker.myorg.com/walmartlabs/concord-agent
```

## Starting Concord Docker Images

There are four components to Concord: the Server, the
Console, the Database and an agent. Follow these steps to start all four
components and run a simple process to test your Concord instance.

<a name="step-1">
### Step 1. Start the Database

Concord uses [PostgreSQL](https://www.postgresql.org/) version 10.4 or higher:
```bash
docker run -d \
-e 'POSTGRES_PASSWORD=q1' \
-p 5432:5432 \
--name db \
library/postgres:10.4
```

Verify that the Database is running and ready to accept connections:
```
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
c3b438edc980        postgres:10.4       "docker-entrypoint.s…"   3 seconds ago       Up 1 second         5432/tcp            db

$ psql -U postgres -h localhost -p 5432 postgres
Password for user postgres: (enter "q1")

postgres=# select 1;
 ?column?
----------
        1
(1 row)
```

<a name="step-2">
### Step 2. Create the Server's Configuration File

Create a `server.conf` file somewhere on the local filesystem with the
following content:
```
concord-server {
    db {
        url="jdbc:postgresql://db:5432/postgres"
        appPassword = "q1"
        inventoryPassword = "q1"
    }

    secretStore {
        serverPassword = "cTE="
        secretStoreSalt = "cTE="
        projectSecretSalt = "cTE="
    }

    # AD/LDAP authentication
    ldap {
        url = "ldaps://AD_OR_LDAP_HOST:3269"
        searchBase = "DC=myorg,DC=com"
        principalSearchFilter = "(&(sAMAccountName={0})(objectCategory=person))"
        userSearchFilter = "(&(|(sAMAccountName={0}*)(displayName={0}*))(objectCategory=person))"
        usernameProperty = "sAMAccountName"
        systemUsername = "me@myorg.com"
        systemPassword = "secret"
    }
}
```

Make sure that the `db` section contains the same password you speficied on
[Step 1](#step-1).

The `secretStore` parameters define the keys that are used
to encrypt user secrets. The keys must be base64-encoded:
```bash
$ echo -ne "q1" | base64
cTE=
```

The `ldap` section parameters depends on your organization's Active Directory
or LDAP server setup. If you wish to use a local OpenLDAP instance, follow the
[Using OpenLDAP for Authentication](./development.html#oldap) guide.

The configuration file format and available parameters described in the
[Configuration](../configuration.html) document.

### Step 3. Start the Concord Server

```bash
docker run -d \
-p 8001:8001 \
--name server \
--link db \
-v /path/to/server.conf:/opt/concord/conf/server.conf:ro \
-e CONCORD_CFG_FILE=/opt/concord/conf/server.conf \
walmartlabs/concord-server
```

Replace `/path/to/server.conf` with the path to the file created on
[Step 2](#step-2).

Check the server's status:
```
$ docker logs server
...
14:38:17.866 [main] [INFO ] com.walmartlabs.concord.server.Main - main -> started in 5687ms
...

$ curl -i http://localhost:8001/api/v1/server/version
...
{
  "version" : "0.99.0",
  "env" : "n/a",
  "ok" : true
}
```

### Step 4. Start a Concord Agent

```bash
docker run -d \
--name agent \
--link server \
-e SERVER_API_BASE_URL=http://server:8001 \
walmartlabs/concord-agent
```

Check the agent's status:
```
$ docker logs agent
...
4:41:45.530 [queue-client] [INFO ] c.w.c.server.queueclient.QueueClient - connect ['ws://server:8001/websocket'] -> done
...
```

### Step 6. Start the Concord Console

```bash
docker run -d -p 8080:8080 \
--name console \
--link server \
-v "/path/to/repo/docker-images/console.conf:/opt/concord/console/nginx/app.conf:ro" \
walmartlabs/concord-console
```

Replace `/path/to/repo` with your path to the Concord's repository.

The console is available on [http://localhost:8080](http://localhost:8080).
Try logging in using your AD/LDAP credentials.

## First Project

As a next step you can create your first project as detailed in the
[quickstart guide](../quickstart.html).


## Clean Up

Once you have explored Concord you can stop and remove the containers.

```bash
docker rm -f console agent server db
```
