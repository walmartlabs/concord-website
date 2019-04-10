---
layout: wmt/docs
title:  Overview
side-navigation: wmt/docs-navigation.html
---

# {{ page.title}}

[Concord](../../overview/index.html) consists of several components. The three
main components are:
- [Server](#concord-server) - the central component, manages the process state
and resources;
- [Console](#concord-console) - provides UI for project and process management,
etc;
- [Agent](#concord-agent) - executes user processes;
- [Database](#database) - stores the process state, all Concord entities, logs,
etc.

# Components

## Concord Server

The Server is the central component. It provides [the API](../api/index.html) which
is used to control processes, manage entities such as projects and secrets,
etc.

A minimal Concord installation contains at least one Server. Multiple servers
can run in active-active or active-passive configurations.

## Concord Console

The Console provides user interface for managing processes, projects, secrets and
other entities.

Read more about the console [here](../console/index.html).

## Concord Agent

The Agent is responsible for process execution. It receives workload from
[Server](#concord-server) and, depending on the configuration of the job,
starts processes in separate JVMs and/or Docker containers.

Depending on [the configuration](./configuration.html#agent-cfg-file) a single
agent can one or many job simultaneously.

A single Concord installation can have hundreds of Agents. It is also possible
to have Agents with different capabilities (e.g. running on different hardware)
connected to the single Concord instance. Which is useful when you need to run
some resource-intensive processes such as Ansible with lots of `forks`.

## Database

Concord uses [PostgreSQL](https://www.postgresql.org/) (10.4 or higher) to
store process state, logs and entities such as projects and secrets.

# Main Concepts

## Processes

Processes are the main concept of Concord. A process is an execution of
[Concord Flows](./concord-dsl.html) in an isolated environment.

A process can run in a [project](#projects), thus sharing configuration and
resources (such as [the KV store](../plugins/key-value.html)) with other
processes in the same project.

Processes can be suspended (typically using a [form](./forms.md)) and resumed.
While suspended processes are not consuming any resources apart from the DB
disk space. See the [Process Execution](./processes.html#execution) section for
more details about the lifecycle of Concord processes.

## Projects

A project is a way to group up processes and use shared environment and
configuration.

## Secrets

Concord provides an API and [the plugin](../plugins/crypto.html) to work with
secrets such as:
- SSH keys;
- username/password pairs;
- single value secrets (e.g. API tokens);
- binary data (files).

Secrets can optionally be protected by a user-provided password.

## Users and Teams

Concord can use an Active Directory/LDAP LDAP server or the local user store
for authentication.

## Organizations

Organizations are, basically, namespaces to which resources such as projects,
secrets, teams and others belong to. 

[Concord](../../about.html) consists of a server and user interface components:

The [Concord Server](#concord-server) provides a REST API for managing
projects and repositories. It receives and processes user requests
to call workflow scenarios. Execution of the processes is managed in isolated
environments for each flow in a cluster of so-called agents.

The [Concord Console](#concord-console) is a web-based user interface for
managing and monitoring the server. It provides features for users to login and
work with projects, secrets, processes and other entities. Find out more about
using it in the
[dedicated documentation section about the Concord Console](../console/index.html).

[Concord Concepts](#concord-concepts) explains more about the components that
are managed and executed by Concord:

- [Projects](#projects)
- [Processes](#processes)
- [Secrets](#secrets)

## Concord Server

The server provides several REST API endpoints for managing its
data, described in the [API documentation](../api/index.html).

The main purpose of the server is to receive a workflow process
definition and its dependencies from a user and execute it remotely
using one of many agents.

The workflow process definition, its dependencies and supporting files are
collected in a single archive file called a "payload".

There are several ways to start a process:

1. Send a complete, self-contained ZIP archive to the server. Its
format is described in a
[separate document](./processes.html#payload-format).
2. Send a JSON request, containing only request parameters and a
reference to a [project](#project).
3. Same as **2**, but sending additional files with the request.

For methods **2** and **3** above, the server builds a payload archive
itself.

The executions of workflows are performed by the agents. Each agent is a
standalone Java application that receives and executes
a [payload](#payload) sent by the server.

## Concord Concepts

Concord contains projects that reference repositories that define
processes.  Concord can associate credentials with resources
and repositories referenced by a project.  The following sections
briefly introduce these concepts.

### Projects

Projects allow users to automatically create payloads by pulling
files from remote GIT repositories and applying templates.

Projects are created with the Concord Console or by using the REST API.

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

As a workflow server, Concord often needs to access protected
resources such as public/private clouds and source control systems.
Concord maintains a set of secrets that can be associated with a
project's resources.
