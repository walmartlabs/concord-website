---
layout: wmt/docs
title:  OneOps Triggers
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Using `oneops` as an event source allows Concord to receive events from
[OneOps](https://oneops.com). You can configure event properties in the OneOps
notification sink, specifically for use in Concord triggers.

Deployment completion events can be especially useful:

```yaml
flows:
  onDeployment:
  - log: "OneOps has completed a deployment: ${event}"
  
triggers:
- oneops:
    org: "myOrganization"
    asm: "myAssembly"
    env: "myEnvironment"
    platform: "myPlatform"
    type: "deployment"
    deploymentState: "complete"
    useInitiator: true
    entryPoint: onDeployment
```

The `event` object, in addition to its trigger parameters, contains a `payload`
attribute--the original event's data "as is". You can set `useInitiator` to
`true` in order to make sure that process is initiated using `createdBy`
attribute of the event.

The following example uses the IP address of the deployment component to build 
an Ansible inventory for execution of an [Ansible task](../plugins/ansible.html):

```yaml
flows:
  onDeployment:
  - task: ansible
    in:
      ...
      inventory:
        hosts:
          - "${event.payload.cis.public_ip}"
```
