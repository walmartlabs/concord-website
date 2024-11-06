---
layout: wmt/docs
title:  Concord Inventory
side-navigation: wmt/docs-navigation.html
deprecated: true
description: Plugin for working with Concord's Inventory API
---

# {{ page.title }}

**Note:** Concord Inventory is deprecated in favor of [the JSON Store API](../getting-started/json-store.html).
The current version of [the JSON Store task](./json-store.html) doesn't support
working with Ansible inventories yet, but will replace the `inventory` task in the
future. 

The `inventory` plugin makes data from Concord's Inventory available for direct
usage by `ansible`. Using predefined inputs, this plugin arranges data in the
format required per [Dynamic Inventory Conventions](https://docs.ansible.com/ansible/latest/dev_guide/developing_inventory.html#inventory-script-conventions).

- [Usage](#usage)
- [Ansible Example](#ansible-example)

## Usage

Prior to using this plugin, inventory data must be stored in Concord JSON
storage. Additionally, a query must be created per the API documentation:
[Inventory Query](../api/json-store.html#queries). The results of that query are the
input of this plugin and must contain a list of JSON objects containing a
`host` string and a `data` object. The `host` is added to the hostgroup and all
`data` becomes hostvars.

Example Input (from query):

```json
[ {
  "host" : "example1.exampledomain.com",
  "data" : {
    "ansible_distribution": "RedHat",
    "ansible_python_interpreter": "/usr/bin/python",
    "environment" : "test",
    "location" : "eastus",
    "ipv4": {
      "address": "192.168.1.100",
      "broadcast": "192.168.1.255",
      "netmask": "255.255.255.0",
      "network": "192.168.1.1"
     },
    "serial_number" : "J9J69T68G",
    "deployment_color" : "green"
  }
}, {
  "host" : "example2.exampledomain.com",
  "data" : {
    "ansible_distribution": "Debian",
    "ansible_python_interpreter": "/usr/bin/python",
    "environment" : "test",
    "location" : "westus",
    "ipv4": {
      "address": "192.168.2.100",
      "broadcast": "192.168.2.255",
      "netmask": "255.255.255.0",
      "network": "192.168.2.1"
     },
    "serial_number" : "JDFKKDISHJ7GH89",
    "deployment_color" : "blue"
  }
} ]
```
 
The Inventory plugin ships with Concord so there are no dependencies, though it
is usually used with the [Ansible](./ansible.html) plugin which does
require a dependency definition.

```yaml
flows:
  default:
  - log: "Inventory: ${inventory.ansible('OrgName', 'ProjectName', 'inventory_group_name', 'named_query', {'query': 'parameters'} )}"
``` 

- `OrgName` is optional and defaults to the Organization of the currently
  running process.
- query parameters are optional (needed for parameterized queries only) and
  must be a JSON object.
- all hosts returned by the plugin call are placed in the inventory group
  provided. Multiple groups can be created by calling the inventory plugin
  multiple times.

## Ansible Example

```yaml
configuration:
  dependencies:
    - mvn://com.walmartlabs.concord.plugins.basic:ansible-tasks:{{ site.concord_core_version }}

flows:
  default:
  - task: ansible
    in:
     playbook: playbook.yml
     inventory: "${inventory.ansible('ExampleGroup', 'ExampleProject', 'west_us', 'metadata_query', {'location': 'westus'} )}"
```
