# Workflow Orchestration

> What is this all about?

<!--- vertical -->

## Workflow Orchestration

- Logical flow of activities and tasks
- Takes inputs
- Creates outputs
- Performs actions
- Manage and optimize operation processes
- Automate to improve performance

Note:
- quite abstract
- very flexible what it does
- like a conductor orchestrates musicians in an orchestra
- https://en.wikipedia.org/wiki/Business_process_management

<!--- vertical -->

## Workflow Server

Specific software designed for workflow orchestration

- Define workflows
- Run workflow processes
- Provide user interface for process access
- Support integration with numerous tools

<!--- vertical -->

## Concord

- High-performance, powerful workflow server
- Java-based software
- REST API
- Web-based user interface
- Numerous plugins
- Developed by Strati team at Walmart Labs
- Open source

<!--- vertical -->

## Usage Scenarios

- Support complex software development procedures
- Orchestrate CI/CD builds and deployments
- Provision infrastructure in a public or private cloud with Terraform
- Execute Ansible playbooks and deploy applications
- RUn chaos tests with gremlin
- Orchestrate steps in business processes

<!--- vertical -->

## Components

- Concord Server
- Concord Console
- Concord Projects

<!--- vertical -->

## Concord Server

- Main engine and storage
  - user access
  - secrets
  - organizations
  - projects
  - repositories
  - key/value pairs
- REST API for access
- Process execution on JVM

Receives and processes user requests to call workflow scenarios.

<!--- vertical -->

## Concord Console

Web-based user interface for Concord Server:

- Organizations
- Projects and repositories
- Secrets
- Processes including logs, forms, ...

<!--- vertical -->

## Concord Project

- Created by users
- Stored in git repository
- YAML for flow definitions
- Execution as _process_ on Concord Server

<!--- vertical -->

## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

