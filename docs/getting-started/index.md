---
layout: wmt/docs
title:  Overview
---

# Overview

Concord consists of three components:

1. [Concord Server](#concord-server) provides a REST API for managing
projects and repositories. It receives and processes user requests
to call workflow scenarios.

2. [Concord Agent](#concord-agent) is a (remote) workflow executor. Receives
scenarios from the server and executes them in an isolated
environment.

3. [Concord Console](#concord-console) is a web UI for managing and
monitoring the server and its processes.

## Concord Server

The server provides several REST API endpoints for managing it's
data, they are described in the [API documentation](../api/index.html).

The main purpose of the server is to receive a workflow process
definition and its dependencies from a user and execute it remotely
using the agent.

Workflow process definitions, its dependencies and supporting files
collected in a single archive file called "payload".

There are several ways to start a process:

- send a complete, self-contained ZIP archive to the server. Its
format is described in a
[separate document](./processes.html#payload-format);
- send a JSON request, containing only request parameters and a
reference to a [project](#project);
- same as **2**, but sending additional files with the request.

For methods **2** and **3**, the server will build a payload archive
itself.


## Concord Agent

The agent is a standalone Java application that receives and executes
a [payload](#payload) sent by the server.


## Concord Console 

The console is a web application for managing and monitoring the
server.

## Concord Concepts

Concord contains projects that reference repositories that define
processes.  Concord can associate credentials with resources
and repositories referenced by a project.  The following sections
briefly introduce these concepts.

### Projects

Projects allow users to automatically create payloads by pulling
files from remote GIT repositories and applying templates.

Projects are created using the REST API or the
UI.

### Processes

A process is the execution of a workflow defined by the combination
of request data, a user's files, project templates, and the contents
of a repository.  These four components result in a specific process
that is executed and which can be inspected in the Concord Console.

An example of a process can be the provisioning of cloud
infrastructure from a OneOps Boo template or the execution of an Ansible
playbook.  A far simpler example of a process can be the execution of
a simple logging task to print "Hello World" as shown in the
[Concord Quickstart](./quickstart.html).

### Credentials

As a workflow server Concord often needs to access protected
resources such as public/private clouds and source control systems.
Concord maintains a set of credentials that can be associated with a
project's resources.
