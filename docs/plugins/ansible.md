---
layout: wmt/docs
title:  Ansible Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord supports running Ansible playbooks with the `ansible` task as part of
any flow.

- [Usage](#usage)
- [Parameters](#parameters)
- [Configuring Ansible](#configuring-ansible)
- [Ansible Vault](#ansible-vault)
- [Inline inventories](#inline-inventories)
- [Dynamic inventories](#dynamic-inventories)
- [Using SSH keys](#using-ssh-keys)
- [Custom Docker images](#custom-docker-images)
- [Retry and Limit Files](#retry-and-limit-files)
- [Limitations](#limitations)

## Usage

To use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies)`:

```yaml
configuration:
  dependencies:
  - "mvn://com.walmartlabs.concord.plugins.basic:ansible-tasks:0.46.0"
```

This adds the task to the classpath and allows you to invoke the task in a flow
using an expression using the `run` method:

```yaml
- ${ansible.run(params, ${workDir})}
```

This expression executes an Ansible process using `params` arguments in the 
working directory on Concord.

```yaml
configuration:
  arguments:
    params:
      playbook: playbook/hello.yml
```

Alternatively you can use the `task` syntax and specify the input parameters

```yaml
- task: ansible
  in:
    playbook: playbook/hello.yml
    ...
```

A full list of available parameters is described [below](#parameters).

## Parameters

- `playbook` - string, relative path to a playbook;
- `debug` - boolean, enables additional debug logging;
- `config` - JSON object, used to create an
[Ansible configuration](http://docs.ansible.com/ansible/latest/intro_configuration.html)
file. See also the [Configuring Ansible](#configuring-ansible)
section;
- `extraVars` - JSON object, used as `--extra-vars`
argument of `ansible-playbook` command. Check [the official
documentation](http://docs.ansible.com/ansible/latest/playbooks_variables.html#id31)
for more details;
- `inventory` - JSON object, an inventory data in
[the standard JSON format](http://docs.ansible.com/ansible/latest/dev_guide/developing_inventory.html#id1). More information can be found in the 
[inline inventories](#inline-inventories) section;
- `inventoryFile` - string, path to an inventory file;
- `dynamicInventoryFile` - string, path to a dynamic inventory
script. See also [Using dynamic inventories] section;
- `user` - string, username to connect to target servers;
- `tags` - string, comma-separated list of [tags](http://docs.ansible.com/ansible/latest/playbooks_tags.html);
- `vaultPassword` - string, password to use with [Ansible Vault](#ansible-vault).
- `verbose` - integer, increase log [verbosity](http://docs.ansible.com/ansible/latest/ansible-playbook.html#cmdoption-ansible-playbook-v). 1-4 correlate to -v through -vvvv.

## Configuring Ansible

Ansible's [configuration](http://docs.ansible.com/ansible/intro_configuration.html)
can be specified under `config` key:


```yaml
- task: ansible
  in:
    config:
      defaults:
        - forks: 50
      ssh_connection:
        - pipelining: True
```

which is equivalent to:

```
[defaults]
forks = 50

[ssh_connection]
pipelining = True
```

## Ansible Vault

Password for 
[Ansible Vault](http://docs.ansible.com/ansible/latest/playbooks_vault.html)
files can be specified using `vaultPassword` or  `vaultPasswordFile` parameters:

```yaml
flows:
  default:
  - task: ansible
    in:
      vaultPassword: "myS3cr3t"
      vaultPasswordFile: "get_vault_pwd.py"
```

The `vaultPasswordFile` value must be a relative path to the file in
the working directory of a process.

For the projects using "ansible" template, set `vaultPassword` or
`vaultPasswordFile` variables in a top-level JSON object of a
`request.json` file:
```json
{
  "vaultPassword": "..."
}
```

## Inline Inventories

An inventory file can be inlined with the request JSON. For example:

```json
{
  "playbook": "playbook/hello.yml",
  "inventory": {
    "local": {
      "hosts": ["127.0.0.1"],
      "vars": {
        "ansible_connection": "local"
      }
    }
  }
}
```

Or as a task parameter:
```yaml
configuration:
  ansibleParams:
    playbook: "playbook/hello.yml"
    inventory:
      local:
        hosts:
        - "127.0.0.1"
        vars:
          ansible_connection: "local"

flows:
  default:
  - ${ansible.run(ansibleParams, workDir)}
```

Alternatively, an inventory file can be uploaded as a separate file:

```
curl -v \
-H "Authorization: auBy4eDWrKWsyhiDp3AQiw" \
-F request=@request.json \
-F inventory=@inventory.ini \
http://localhost:8001/api/v1/process/myProject:myRepo
```


## Dynamic Inventories

Path to a 
[dynamic inventory script](http://docs.ansible.com/ansible/latest/intro_dynamic_inventory.html)
can be specified using `dynamicInventoryFile` parameter in a task parameters object:

```yaml
configuration:
  ansibleParams:
    playbook: "playbook/hello.yml"
    dynamicInventoryFile: "inventory.py"

flows:
  default:
  - ${ansible.run(ansibleParams, workDir)}
```

Or as an IN-parameter:
```yaml
flows:
  default:
  - task: ansible
    in:
      playbook: "playbook/hello.yml"
      dynamicInventoryFile: "inventory.py"
```

Alternatively, a dynamic inventory script can be uploaded as a
separate file:

```
curl -v \
-H "Authorization: auBy4eDWrKWsyhiDp3AQiw" \
-F request=@request.json \
-F dynamicInventory=@inventory.py \
http://localhost:8001/api/v1/process/myProject:myRepo
```

In any case, it will be marked as executable and passed directly to
`ansible-playbook` command.


## Using SSH Keys

First, upload an
[existing SSH key pair](../api/secret.html#upload-an-existing-ssh-key-pair)
or [create a new one](../api/secret.html#generate-a-new-ssh-key-pair).

Public part of the key pair should be added as a trusted key to the
target server. The easiest way to check if the key is correct is to
try to login to the remote server like this:
```
ssh -v -i /path/to/the/private/key remote_user@target_host
```

If you are able to login to the target server without any error
messages or password prompt, then the key is correct and can be used
with Ansible and Concord.

The next step will be configuring Concord to use the key with your
project or a standalone flow/playbook.

This can be done by adding `ansible.privateKeys` section to the
project's configuration, the Concord file or request JSON:

```json
{
  "ansible": {
    "privateKeys": [
      {
        "repository": "myRepo",
        "secret": "mySshKeyPair"
      },
      {
        "repository": ".*",
        "secret": "mySshKeyPair"
      }
    ]
  }
}
```

Where `repository` is the pattern, matching the name of a project's
repository and `secret` is the name of the uploaded SSH key pair.

A `.*` pattern can be used when there is no repositories configured
or you want to use a single key for any repository.

In the Concord file, the keys can be configured in a similar way:
```yaml
configuration:
  ansible:
    privateKeys:
      repository: ".*"
      secret: "mySshKeyPair"
```

## Custom Docker Images

Sometimes Ansible playbooks require additional modules to be
installed. In this case, users can provide a custom Docker image:

```yaml
# as an expression:
- ${ansible.run('docker.prod.walmart.com/walmartlabs/concord-ansible', params, workDir)}

# or as a task step:
- task: ansible
  in:
    dockerImage: "docker.prod.walmart.com/walmartlabs/concord-ansible"
```

We recommend using `docker.prod.walmart.com/walmartlabs/concord-ansible`
as a base for your custom Ansible images.

Please refer to [Docker support](../getting-started/docker.html)
document for more details.

## Retry and Limit Files

The plugin provides support for Ansible "retry files" (aka "retry files"). By
default, when a playbook execution fails, Ansible creates a `*.limit` file which
can be used to restart the execution for failed hosts.

If the `retry` parameter is set to `true`, the plugin automatically uses the
existing retry file of the playbook:

```yaml
flows:
  default:
  - task: ansible
    in:
      playbook: playbook/hello.yml      
      retry: true
```

The equivalent ansible command is

```
ansible-playbook --limit @${workDir}/playbook/hello.retry
```

Alternatively, the `limit` parameter can be specified directly:

```yaml
flows:
  default:
  - task: ansible
    in:
      playbook: playbook/hello.yml
      # will use @${workDir}/my.retry file
      limit: @my.retry
```

The equivalent ansible command is

```
ansible-playbook --limit @my.retry
```

If the `saveRetryFile` parameter is set to `true`, then the generated `*.retry` file
is saved as a process attachment and can be retrieved using the REST API:

```yaml
flows:
  default:
  - task: ansible
    in:
      saveRetryFile: true
```


```
curl ... http://concord.example.com/api/v1/process/${processId}/attachments/ansible.retry
```

## Limitations

Ansible's `strategy: debug` is not supported. It requires an interactive terminal and
expects user input and should not be used in Concord's environment.
Playbooks with `strategy: debug` will hang indefinitely, but can be killed using the
REST API or the Console.