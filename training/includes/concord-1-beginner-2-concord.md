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

Note:
- Supports workflows; 1st define what happens in the workflow, then the workflow server goes and runs that workflow.
- Needs to be able to run a lot concurrently, sending to stores, windows machines, VMs
- Need to give you visibility to the workflow status - what's done, failed, in progress, or still queued up
- A workflow server that can't integrate w/ tools to get the job done is useless

<!--- vertical -->

## Concord

- High-performance, powerful workflow server
- Java-based software
- REST API
- Web-based user interface
- Numerous plugins
- Developed by Strati team at Walmart Labs
- Open source

Note:
- Just read slide

<!--- vertical -->

## Usage Scenarios

- Support complex software development procedures
- Orchestrate CI/CD builds and deployments
- Provision infrastructure in a public or private cloud with Terraform
- Execute Ansible playbooks and deploy applications
- Run chaos tests with gremlin
- Orchestrate steps in business processes

Note:
- Just read slide - these are reasons to use workflow servers

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


Note:
- The brain of the operation - user access, secrets storage including SSH keys for GitHub, remote nodes or to OneOps
- Manages the projects themselves - our demos, team work, all separate projects are in their own repos, but managed by the Concord server
- Has a storage for key value pairs as well as a policy engine built in and a secrets management system that hooks into keywhiz
- Concord's job is to execute processes, and to do that it spins up JVMs and runs the processes on them
- Concord is a proper cloud app; when we say server it's not just one, it is a cluster of servers
<!--- vertical -->

## Concord Console

Web-based user interface for Concord Server:

- Organizations
- Projects and repositories
- Secrets
- Processes including logs, forms, ...

Note:
- This is the UI we'll get familiar with today.
- This is where we configure our project and a repo, and where we create the secret that we use to connect to GitHub
- Also a place we can kick off processes and look at logs

<!--- vertical -->

## Concord Project

- Created by users
- Stored in git repository
- YAML for flow definitions
- Execution as _process_ on Concord Server

Note:
- This is where you define what happens in your workflow and is executed as a process on the Concord Server
- Essentially a git repo with a specific YAML file in it with our flows defined
- Note we'll go over YAML a bit later

<!--- vertical -->

## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

