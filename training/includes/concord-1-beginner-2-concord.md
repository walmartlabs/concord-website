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
- tbd


## Components

- Concord Server
- Concord Agent
- Concord Console


## Concord Server

provides a REST API for managing projects and repositories. It receives and 
processes user requests to call workflow scenarios.


## Concord Agent

is a (remote) workflow executor. Receives scenarios from the server and executes
them in an isolated environment.


## Concord Console

 is a web UI for managing and monitoring the server and its processes.


## Concord Project

- User created
- incl plugin implementations
- in git repo
- using yaml


## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

