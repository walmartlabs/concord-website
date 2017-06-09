---
layout: wmt/docs
title:  Extensions
---

# Quick start

The fastest way to get a Concord instance up and running is to use the
pre-built Docker images to run all three components of Concord: the
Concord Agent, the Concord Server, and the Concord Console.

After finishing these steps you can read the [Introduction to
Concord](./index.html) to understand the basic concepts of Concord.

## Prerequisites

### Docker

  If you do not already have Docker installed, see
  https://www.docker.com/ to obtain Docker.  You can install Docker
  through various methods that are outside the scope of this document.

  Once you have installed Docker see Walmart's [Nexus and
  Docker](https://confluence.walmart.com/display/PGPTOOLS/Docker+and+Nexus)
  instructions to find the location of the private Docker registry
  containing Concord's pre-built images - docker.prod.walmart.com.

### Referencing a private Docker registry

  If you are using a private Docker registry, add its name to an image
  name in the examples below.  For example, if your private docker
  registry is running on docker.prod.walmart.com this command:
 
  ```
  docker run ... walmartlabs/concord-agent
  ```

  would be run as:

  ```
  docker run ... docker.prod.walmart.com/walmartlabs/concord-agent
  ```

## Starting Concord Docker Images

  There are three components to Concord: the Agent, the Server, and
  the Console.  Follow these steps to start all three components and
  run a simple process to test your Concord instance.

### Step 1. Create a LDAP configuration file

  Use the example in [LDAP](./configuration.html#ldap) section of
  Configuration document. You'll need the parameters suitable for
  your environment.

### Step 2. Start the Concord Server

  ```
  docker run -d \
  -p 8001:8001 \
  -p 8101:8101 \
  --name server \
  -v /path/to/ldap.properties:/opt/concord/conf/ldap.properties:ro \
  -e 'LDAP_CFG=/opt/concord/conf/ldap.properties' \
  --network=host \
  walmartlabs/concord-server
  ```
  
  Replace `/path/to/ldap.properties` with the path to the file
  created on the previous step.
  
  This will start the server with an in-memory database and temporary
  storage for its working files. Please see the
  [Configuration](./configuration.html) description to configure a more
  permanent storage.
  
### Step 3. Check the Concord Server Logs
  
  ```
  docker logs server
  ```

### Step 4. Start the Concord Agent

  ```
  docker run -d \
  --name agent \
  --network=host \
  walmartlabs/concord-agent
  ```
  
### Step 5. Start the Concord Console

  ```
  docker run -d -p 8080:8080 \
  --name console \
  -e 'SERVER_PORT_8001_TCP_ADDR=localhost' \
  -e 'SERVER_PORT_8001_TCP_PORT=8001' \
  --network=host \
  walmartlabs/concord-console
  ```

### Step 6. Create a simple Concord project

  Create a zip archive containing a single `.concord.yml` file (starting with
  a dot):

  ```yaml
  flows:
    main:
      - log: "Hello, ${name}"
      
  variables:
    entryPoint: "main"
    arguments:
      name: "world"
  ```
  
  The format is described in [Project file](./processes.html#project-file)
  document.

### Step 7. Start a New Concord Process

  ```
  curl -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" \
       -H "Content-Type: application/octet-stream" \
       --data-binary @archive.zip http://localhost:8001/api/v1/process
  ```
  
  The response should look like:
  ```json
  {
    "instanceId" : "a5bcd5ae-c064-4e5e-ac0c-3c3d061e1f97",
    "ok" : true
  }
  ```

### Step 8. Check the Concord Server Logs

  ```
  docker logs server
  ```
  
  If everything went okay, you should see something like this:

  ```
  15:14:26.009 ... - updateStatus ['1b3dedb2-7336-4f96-9dc1-e18408d6b48e', 'ed097181-44fd-4235-973a-6a9c1d7e4b77', FINISHED] -> done
  ```

  You can also check the log by opening it in
  [the Concord console](http://localhost:8080/).

### (Optional) Stop and remove the containers

  ```
  docker rm -f console agent server
  ```
