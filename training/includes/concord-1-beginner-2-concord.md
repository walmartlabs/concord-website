# Workflow Orchestration and BPM

> What is it all about?


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
- like a conductor orchestrates musicians in a orchestra
- https://en.wikipedia.org/wiki/Business_process_management


## Workflow Server

Specific software designed for workflow orchestration and BPM

- define workflows
- run workflow processes
- provide user interface for process access
- support integration with numerous tools


## Concord

- A workflow server
- Workflow engine inside
- Java-based software
- REST API
- Web-based user interface
- Developed by SDE team at Walmart Labs


## Usage Scenarios

- Orchestrate steps in busines processes
- Support software development processes
- Provision infrastructure in a public or private cloud
- Execute Ansible playbooks and deploy applications
- Orchestrate CI/CD builds and deployments


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


## Concord Agent

- Remote workflow executor
- Receives scenarios from the server
- Executes them in isolated environments


## Concord Project

- Created by Users
- Including plugin implementations
- Stored in git repository
- YAML for flow definitions


## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

