# Workflow Orchestration and BPM

> What is it all about?


## Workflow Orchestration

- Logical flow of activities and tasks
- Takes inputs
- Creates outputs
- Performs actions

Note:
- quite abstract
- very flexible what it does
- like a conductor orchestrates musicians in a orchestra


## BPM

_Business Process Management_

- Manage and optimize operation processes
- Automate to improve performance

Note:
- https://en.wikipedia.org/wiki/Business_process_management


## Workflow/BPM Server

Specific software designed for workflow orchestration and BPM

- tbd 1
- tbd 2
- tbd 3
- user interface for job access
- integration with other tools


## Concord

- A workflow/BPM server
- BPM engine inside
- Java-based software
- Developed by SDE team at Walmart Labs


## Usage Scenarios

- Provision infrastructure in a public or private cloud
- Execute Ansible playbooks and deploy applications
- Orchestrate CI/CD builds and deployments
- TBD


## Components

- Concord Server
- Concord Console
- Concord Agent


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

- Processes
- Projects
- Secrets


## Concord Agent

- Remote workflow executor
- Receives scenarios from the server
- Executes them in isolated environments


## Concord Project

- Created by Users
- Incl plugin implementations
- Stored in in git repository
- YAML for flow description


## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

