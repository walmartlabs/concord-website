# Continuous Deployment

> Shipping Software to Customers


## Integrations and Tools

Concord interacts with

- Looper
- OneOps
- Ansible
- WaRM
- JIRA
- Slack
- SMTP

## Looper

Continuous integration server of choice.


## OneOps

Cloud Platform as a Service of choice.


## Ansible

Automation engine for application configuration and deployment.


## WaRM

Walmart Repository Manager stores binaries.


## OneOps Integration

- Boo task
  - create assembly and env
  - delete assembly
- OneOps task
  - variables and tag
  - IP numbers and instance 
  - adjust scale
  - touch 
  - commit and deploy


## Ansible Task

Feature rich Ansible integration

- Run playbooks
- Static inventories
- Dynamic inventories
- Ansible Vault support

and more.

Note:
- Concord = improved, more flexible version of Ansible Tower


## Example Deployment Flow

- Commit to GitHub
- Triggers Looper flow
- Looper build deploys to WaRM
- Looper kicks off Concord flow
- Concord runs OneOps deployment 
- Or Ansible deployment

Note:
- https://gecgithub01.walmart.com/devtools/concord-cd-example
- https://ci.walmart.com/job/concord-cd-example/


## Example Replacement Flow

- OneOps compute or Ansible deployment goes down
- Reboot/repair of system fires event to Concord
- Concord flow triggers new deployment


## Full Provisioning Scenario

- User fills in Concord form
- JIRA task for tracking is created
- Boo task creates a new assembly and env in OneOps
- OneOps plugin runs commit and deploy
- SMTP task sends email to user and manager

Note: 
Managed Service at Walmart implements that for Cassandra, CloudRDBMS and others.


## Ansible Static Inventory

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins.basic:ansible-tasks:0.46.0
flows:
  default:
  - task: ansible
    in:
      playbook: playbook/hello.yml
      inventoryFile: inventory.ini
```


## Ansible Dynamic Inventory

```yaml
flows:
  default:
  - task: ansible
    in:
      playbook: "playbook/hello.yml"
      dynamicInventoryFile: "inventory.py"
```


## OneOps Task Example

Configuration:

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:oneops-tasks:0.35.0
configuration:
  arguments:
    oneOpsConfig:
      baseUrl: https://oneops.example.com/
      apiToken: ${crypto.decryptString("encryptedApiTokenValue")}
      org: myOrganization
      asm: myAssembly
      env: myEnvironment
```

## OneOps Task Example

Usage:

```yaml
flows:
  default:
  - ${oneops.updatePlatformVariable(oneOpsConfig, "webappserver", "version", "1.0.0")}
  - ${oneops.touchComponent(oneOpsConfig, "webappserver", "fqdn")}
  - ${oneops.commitAndDeploy(oneOpsConfig)}
```


## OneOps Inventory and Ansible

- Simple assembly with customlb pack
- Get IPs of computes with OneOps task
- Use as static inventory in Ansible task
- Ansible playbook adds software and config

Note:
- https://gecgithub01.walmart.com/devtools/concord-pipeline
- https://gecgithub01.walmart.com/vn0xxv4/concord-oneops-ansible-example


## Summary

- Powerful and flexible pipelines
- Simple declaration

Concord, the orchestrator!


## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>


