# Workflow Orchestration

> What is this all about?


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


## Workflow Server

Specific software designed for workflow orchestration

- Define workflows
- Run workflow processes
- Provide user interface for process access
- Support integration with numerous tools


## Concord

- High-performance, powerful workflow server
- Java-based software
- REST API
- Web-based user interface
- Numerous plugins
- Developed by SDE team at Walmart Labs

Note:
- open source in future


## Usage Scenarios

- Support complex software development procedures
- Orchestrate CI/CD builds and deployments
- Provision infrastructure in a public or private cloud
- Execute Ansible playbooks and deploy applications
- Orchestrate steps in business processes


## Components

- Concord Server and Agents
- Concord Console
- Concord Projects


## Concord Server

- Main engine and storage
  - user access
  - secrets
  - projects
  - repositories
  - key/value pairs
- REST API for access
- Agents for process execution

Receives and processes user requests to call workflow scenarios.


## Concord Console

Web-based user interface for Concord Server:

- Projects and repositories
- Secrets
- Processes


## Concord Project

- Created by users
- Stored in git repository
- YAML for flow definitions
- Execution as process on Concord Server/Agents


## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

