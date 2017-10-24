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

Specific software designed for workflow orchestration and BPM

- Define workflows
- Run workflow processes
- Provide user interface for process access
- Support integration with numerous tools


## Concord

- A workflow server
- Java-based software
- REST API
- Web-based user interface
- Numerous plugins
- Developed by SDE team at Walmart Labs

Note:
- open source in future


## Usage Scenarios

- Support software development processes
- Orchestrate CI/CD builds and deployments
- Provision infrastructure in a public or private cloud
- Execute Ansible playbooks and deploy applications
- Orchestrate steps in business processes


## Components

- Concord Server
- Concord Console
- Concord Agents


## Concord Server

- Main engine and storage
  - user access
  - projects
  - repositories
  - key/value pairs
- REST API for access

Receives and processes user requests to call workflow scenarios on agents.


## Concord Console

Web-based user interface for Concord Server and its processes. 

- Projects and repositories
- Processes
- Secrets


## Concord Project

- Created by Users
- Stored in git repository
- YAML for flow definitions
- Execution on Concord Server


## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

