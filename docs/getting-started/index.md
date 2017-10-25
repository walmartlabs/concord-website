---
layout: wmt/docs
title:  Overview
side-navigation: wmt/docs-navigation.html
---

# {{ page.title}} 

[Concord](../about.html) consists of the a server and user interface components:

The [Concord Server](#concord-server) provides a REST API for managing
projects and repositories. It receives and processes user requests
to call workflow scenarios. Execution of the processes is managed in isolated
environments for each flow in a cluster of so-called agents.

The [Concord Console](#concord-console) is a web-based user interfacefor managing and
monitoring the server.

[Concord Concepts](#concord-concepts) explains more about the components that
are managed and executed by Concord:

- [Projects](#projects)
- [Processes](#processes)
- [Secrets](#secrets)

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

The executions of worksflows is performed by the agents. Each agent is a
standalone Java application that receives and executes
a [payload](#payload) sent by the server.

## Concord Console

The console is a web application for managing and monitoring the server. It
provides features for users to login and work with projects, secrets, processes
and other entities.

## Concord Concepts

Concord contains projects that reference repositories that define
processes.  Concord can associate credentials with resources
and repositories referenced by a project.  The following sections
briefly introduce these concepts.

### Projects

Projects allow users to automatically create payloads by pulling
files from remote GIT repositories and applying templates.

Projects are created with the Concord Concole or by using the REST API.

### Processes

A process is the execution of a workflow defined by the combination
of request data, a user's files, project templates, and the contents
of a repository.  These four components result in a specific process
that is executed and which can be inspected in the Concord Console.

An example of a process can be the provisioning of cloud
infrastructure from a OneOps Boo template or the execution of an Ansible
playbook. A far simpler example of a process can be the execution of
a simple logging task to print "Hello World" as shown in the
[Concord Quickstart](./quickstart.html).

### Secrets

As a workflow server Concord often needs to access protected
resources such as public/private clouds and source control systems.
Concord maintains a set of secrets that can be associated with a
project's resources.
