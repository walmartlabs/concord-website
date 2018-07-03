# Continuous Deployment

> Shipping Software to Customers

<!--- vertical -->

## Integrations and Tools

Concord interacts with

- Looper
- OneOps
- Ansible
- Proximity
- JIRA
- Slack
- SMTP

<!--- vertical -->

## Looper

Continuous integration server of choice.

<!--- vertical -->

## OneOps

Cloud Platform as a Service of choice.

<!--- vertical -->

## Ansible

Automation engine for application configuration and deployment.

<!--- vertical -->

## Proximity

Proximity is the repository manager to stores binaries.

- Java binaries from Maven, Gradle, ..
- npm packages
- docker images
- ...

<!--- vertical -->

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

<!--- vertical -->

## Ansible Task

Feature-rich Ansible integration

- Run playbooks
- Static inventories
- Dynamic inventories
- Ansible Vault support

and more.

Note:
- Concord = improved, more flexible version of Ansible Tower

<!--- vertical -->

## Example Deployment Flow

- Commit to GitHub
- Triggers Looper flow
- Looper build deploys to Proximity
- Looper kicks off Concord flow
- Concord runs OneOps deployment 
- Or Ansible deployment

Note:
- https://gecgithub01.walmart.com/devtools/concord-cd-example
- https://ci.walmart.com/job/concord-cd-example/

<!--- vertical -->

## Example Replacement Flow

- OneOps compute or Ansible deployment goes down
- Reboot/repair of system fires event to Concord
- Concord flow triggers new deployment

<!--- vertical -->

## Full Provisioning Scenario

- User fills in Concord form
- JIRA task for tracking is created
- Boo task creates a new assembly and env in OneOps
- OneOps plugin runs commit and deploy
- SMTP task sends email to user and manager

Note: 
Managed Service at Walmart implements that for Cassandra, CloudRDBMS and others.

<!--- vertical -->

## Ansible Static Inventory

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins.basic:ansible-tasks:0.73.0
flows:
  default:
  - task: ansible
    in:
      playbook: playbook/hello.yml
      inventoryFile: inventory.ini
```

<!--- vertical -->

## Ansible Dynamic Inventory

```yaml
flows:
  default:
  - task: ansible
    in:
      playbook: "playbook/hello.yml"
      dynamicInventoryFile: "inventory.py"
```

<!--- vertical -->

## OneOps Task Example

Configuration:

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:oneops-tasks:0.46.0
configuration:
  arguments:
    oneOpsConfig:
      baseUrl: https://oneops.example.com/
      apiToken: ${crypto.decryptString("encryptedApiTokenValue")}
      org: myOrganization
      asm: myAssembly
      env: myEnvironment
```

<!--- vertical -->

## OneOps Task Example

Usage:

```yaml
flows:
  default:
  - ${oneops.updatePlatformVariable(oneOpsConfig, "webappserver", "version", "1.0.0")}
  - ${oneops.touchComponent(oneOpsConfig, "webappserver", "fqdn")}
  - ${oneops.commitAndDeploy(oneOpsConfig)}
```

<!--- vertical -->

## OneOps Inventory and Ansible

- Simple assembly with customlb pack
- Get IPs of computes with OneOps task
- Use as static inventory in Ansible task
- Ansible playbook adds software and config

Note:
- https://gecgithub01.walmart.com/devtools/concord-pipeline
- https://gecgithub01.walmart.com/vn0xxv4/concord-oneops-ansible-example

<!--- vertical -->

## Summary

- Powerful and flexible pipelines
- Simple declaration

Concord, the orchestrator!

<!--- vertical -->

## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>
