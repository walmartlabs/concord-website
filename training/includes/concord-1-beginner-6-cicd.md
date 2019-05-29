# Continuous Deployment

> Shipping Software to Customers

<!--- vertical -->

## Integrations and Tools

Concord interacts with

- Looper
- OneOps
- Ansible
- Terraform
- Proximity
- JIRA
- Slack
- SMTP

Note:
- Skim over this slide - oneline descriptions are in the next slides

<!--- vertical -->

## Looper

Continuous integration server of choice.

Note:
- Read

<!--- vertical -->

## OneOps

Cloud Platform as a Service of choice.

Note:
- Read

<!--- vertical -->

## Ansible

Automation engine for application configuration and deployment.

Note:
- Read

<!--- vertical -->

## Proximity

Proximity is the repository manager to stores binaries.

- Java binaries from Maven, Gradle, ..
- npm packages
- docker images
- ...

Note:
- Read
- Go to strati -> Proximity -> Documentation

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

Note:
- 2 tasks, boo and OneOps
- Boo - read, then navigate to github.com/oneops/boo
- Boo lets you write yaml file to define OneOps assembly and environments

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
- Gives you access to a feature-rich Ansible integration
- Read bullets - available via Ansible to be used in Concord

<!--- vertical -->

## Example Deployment Flow

- Commit to GitHub
- Triggers Looper flow
- Looper build deploys to Proximity
- Looper kicks off Concord flow
- Concord runs OneOps deployment 
- Or Ansible deployment

Note:
- concord-cd-example
- Read bullets
- Demo available https://gecgithub01.walmart.com/devtools/concord-cd-example
- Open the .looper.yml, line 13 creates new release version and deploys to proximity
- This echos out the release number and starts the concord flow
- This passes to the concord flow
- Open concord.yml, line 25, read flow steps
   - deploy flow: touch the component defined above, update w/ new version, commit and deploy
   - test flow - connects to server on port (line 23) via groovy script
   - notify - sends an email

<!--- vertical -->

## Example Replacement Flow

- OneOps compute or Ansible deployment goes down
- Reboot/repair of system fires event to Concord
- Concord flow triggers new deployment

Note:
- OneOps compute has problems, event sends to Concord, Concord triggers deployment to
reinstate to state before failure

<!--- vertical -->

## Full Provisioning Scenario

- User fills in Concord form
- JIRA task for tracking is created
- Boo task creates a new assembly and env in OneOps
- OneOps plugin runs commit and deploy
- SMTP task sends email to user and manager

Note: 
- Managed Service at Walmart implements that for Cassandra, CloudRDBMS and others.

<!--- vertical -->

## Ansible Static Inventory

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins.basic:ansible-tasks:1.6.0
flows:
  default:
  - task: ansible
    in:
      playbook: playbook/hello.yml
      inventoryFile: inventory.ini
```

Note:
- dependency needed, task name, playbook, and inventory.ini file
- Ansible inventory.ini contains list of computes to connect to
- Go over example in https://gecgithub01.walmart.com/devtools/concord/tree/master/examples/ansible

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

Note:
- Difference is instead of hardcoded IPs/computers like in the .ini file, this
runs a script to determine hosts

<!--- vertical -->

## OneOps Task Example

Configuration:

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:oneops-tasks:1.6.0
configuration:
  arguments:
    oneOpsConfig:
      baseUrl: https://oneops.example.com/
      apiToken: ${crypto.decryptString("encryptedApiTokenValue")}
      org: myOrganization
      asm: myAssembly
      env: myEnvironment
```

Note:
- When working w/ OneOps API, you have to add the API token.
- This is typically by user.
- Encrypt based on your project, and put that in the double-quotes, use the crypto.decryptString

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

Note:
- Reinforce when we went over this earlier

<!--- vertical -->

## OneOps Inventory and Ansible

- Simple assembly with customlb pack
- Get IPs of computes with OneOps task
- Use as static inventory in Ansible task
- Ansible playbook adds software and config

Note:
- concord-pipeline git repo
- concord-oneops-ansible-example git repo
- https://gecgithub01.walmart.com/vn0xxv4/concord-oneops-ansible-example

<!--- vertical -->

## Summary

- Powerful and flexible pipelines
- Simple declaration

Concord, the orchestrator!

Note:
- Go over https://gecgithub01.walmart.com/devtools/concord/tree/master/examples again

<!--- vertical -->

## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>
