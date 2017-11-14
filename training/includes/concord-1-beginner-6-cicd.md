# Continuous Deployment

> Shipping Software to Customers


## Integrations and Tools

- Looper
- OneOps
- Ansible


## Looper

Continuous integration server of choice.


## OneOps

Cloud Platform as a Service of choice.


## Ansible

Automation engine for application configuration and deployment.


## OneOps Integration

- Boo task
- OneOps task


## Ansible Task

TBD


## Example Deployment Flow

- Commit to GitHub
- Triggers Looper flow
- Deployment to WaRM
- Event from WaRM kicks off Concord flow
- Concord flow runs OneOps or Ansible deployment


## Example Replacement Flow

- OneOps compute or Ansible deployment goes down
- Reboot/repair of system fires event to Concord
- Concord flow triggers new deployment via Ansible or Oneops task


## Example

- https://gecgithub01.walmart.com/devtools/concord-cd-example
- https://ci.walmart.com/job/concord-cd-example/

