---
layout: wmt/docs
title:  Installation
---

# {{ page.title }} 

The fastest way to get a Concord server instance up and running is to use the
pre-built Docker images to run all three components of Concord: 
the Concord Agent, the Concord Server, and the Concord Console.

After finishing these steps you can read the [Introduction to
Concord](./index.html) to understand the basic concepts of Concord
or set up your first project with the [quick start tips](./quickstart.html).

## Prerequisites

### Docker

  If you do not already have Docker installed, see
  https://www.docker.com/ to obtain Docker.  You can install Docker
  through various methods that are outside the scope of this document.

  Once you have installed Docker see Walmart's [Nexus and
  Docker](http://sde.walmart.com/docs/warm/docker.html)
  instructions to find the location of the private Docker registry
  containing Concord's pre-built images - docker.prod.walmart.com.

### Referencing a private Docker registry

  If you are using a private Docker registry, add its name to an image
  name in the examples below.  For example, if your private docker
  registry is running on `docker.prod.walmart.com` this command:
 
```
docker run ... walmartlabs/concord-agent
```

  would be run as:

```
docker run ... docker.prod.walmart.com/walmartlabs/concord-agent
```

## Starting Concord Docker Images

  There are four components to Concord: the Agent, the Server, the
  Console and the Database. Follow these steps to start all four
  components and run a simple process to test your Concord instance.

### Step 1. Create a LDAP configuration file

  Use the example in [LDAP](./configuration.html#ldap) section of
  Configuration document. You'll need the parameters suitable for
  your environment.
  
### Step 2. Start the Database

```
docker run -d \
-p 5432:5432 \
--name db \
-e 'POSTGRES_PASSWORD=q1' \
hub.docker.prod.walmart.com/library/postgres:latest
```

### Step 3. Start the Concord Server

```
docker run -d \
-p 8001:8001 \
-p 8101:8101 \
--name server \
--link db \
-v /path/to/ldap.properties:/opt/concord/conf/ldap.properties:ro \
-e 'LDAP_CFG=/opt/concord/conf/ldap.properties' \
-e 'DB_URL=jdbc:postgresql://db:5432/postgres' \
docker.prod.walmart.com/walmartlabs/concord-server
```
  
  Replace `/path/to/ldap.properties` with the path to the file
  created on the previous step.
  
  This will start the server with an in-memory database and temporary
  storage for its working files. Please see the
  [Configuration](./configuration.html) description to configure a more
  permanent storage.
  
### Step 4. Check the Concord Server Logs
  
```
docker logs server
```

### Step 5. Start the Concord Agent

```
docker run -d \
--name agent \
--link server \
docker.prod.walmart.com/walmartlabs/concord-agent
```
  
### Step 6. Start the Concord Console (optional)

```
docker run -d -p 8080:8080 \
--name console \
--link server \
docker.prod.walmart.com/walmartlabs/concord-console
```
  
  The console will be available on
  [http://localhost:8080](http://localhost:8080).

### Step 7. First Project

As a next step you can create your first project as detailed in the
[quickstart guide](./quickstart.html).


### (Optional) Stop and Remove the Containers

```
docker rm -f console agent server db
```
