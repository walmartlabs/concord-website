---
layout: wmt/docs
title:  Ansible Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord supports running [Ansible](https://www.ansible.com/) playbooks with the
`ansible` task as part of any flow. This allows you to provision and manage 
application deployments with Concord.

- [Usage](#usage)
- [Parameters](#parameters)
- [Configuring Ansible](#configuring-ansible)
- [Inline inventories](#inline-inventories)
- [Dynamic inventories](#dynamic-inventories)
- [Secrets](#secrets)
- [Ansible Vault](#ansible-vault)
- [Custom Docker images](#custom-docker-images)
- [Retry and Limit Files](#retry-and-limit-files)
- [Limitations](#limitations)

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies)`:

```yaml
configuration:
  dependencies:
  - "mvn://com.walmartlabs.concord.plugins.basic:ansible-tasks:0.46.0"
```

This adds the task to the classpath and allows you to invoke the task in a flow
using an expression using the `run` method:

```yaml
- ${ansible.run(ansibleParams, ${workDir})}
```

This expression executes an Ansible process using `ansibleParams` arguments in the 
working directory on Concord.

```yaml
configuration:
  arguments:
    ansibleParams:
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
[Ansible configuration](#configuring-ansible);
- `extraVars` - JSON object, used as `--extra-vars`
argument of `ansible-playbook` command. Check [the official
documentation](http://docs.ansible.com/ansible/latest/playbooks_variables.html#id31)
for more details;
- `inventory` - JSON object, an inventory data specifying 
[a static, inline inventories](#inline-inventories)section;
- `inventoryFile` - string, path to an inventory file;
- `dynamicInventoryFile` - string, path to a dynamic inventory
script. See also [Using dynamic inventories] section;
- `user` - string, username to connect to target servers;
- `tags` - string, comma-separated list of [tags](http://docs.ansible.com/ansible/latest/playbooks_tags.html);
- `vaultPassword` - string, password to use with [Ansible Vault](#ansible-vault).
- `verbose` - integer, increase log [verbosity](http://docs.ansible.com/ansible/latest/ansible-playbook.html#cmdoption-ansible-playbook-v). 1-4 correlate to -v through -vvvv.

## Configuring Ansible

Ansible's [configuration](http://docs.ansible.com/ansible/intro_configuration.html)
can be specified under the  `config` key:


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


## Inline Inventories

Using an inline 
[inventory](http://docs.ansible.com/ansible/latest/intro_inventory.html) you 
can specify the details for all target systems  to use.

The example sets the host IP of the `local` inventory item and an
additional variable in `vars`:

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

Alternatively, an inventory file can be uploaded supplied as a separate file
e.g. `inventory.ini`:

```
[local]
127.0.0.1

[local:vars]
ansible_connection=local
````

and specify to use it in `inventoryFile`:

```yaml
configuration:
  ansibleParams:
    playbook: "playbook/hello.yml"
    inventoryFile: inventory.ini
```

## Dynamic Inventories

Alternatively to a static configuration to set the target system for Ansible, 
you can use a script to create the inventory - a 
[dynamic inventory](http://docs.ansible.com/ansible/latest/intro_dynamic_inventory.html).

You can specify the name of the script using the `dynamicInventoryFile` parameter in
in your parameters:

```yaml
configuration:
  ansibleParams:
    playbook: "playbook/hello.yml"
    dynamicInventoryFile: "inventory.py"

flows:
  default:
  - ${ansible.run(ansibleParams, workDir)}
```

Or you can configure it as input parameter for the task:

```yaml
flows:
  default:
  - task: ansible
    in:
      playbook: "playbook/hello.yml"
      dynamicInventoryFile: "inventory.py"
```


The script is automatically marked as executable and passed directly to
`ansible-playbook` command.

## Secrets

The Ansible task can use a key managed as a secret by Concord, that you have
created  or uploaded  via the user interface or the
[REST API](../api/secret.html).

The public part of a key pair should be added as a trusted key to the
target server. The easiest way to check if the key is correct is to
try to login to the remote server like this:
```
ssh -v -i /path/to/the/private/key remote_user@target_host
```

If you are able to login to the target server without any error
messages or password prompt, then the key is correct and can be used
with Ansible and Concord.

The next step is to configure Concord to use the key with your
project with the `privateKey` configuration:

```yaml
flows:
 default:
 - task: ansible
   in:
     privateKey:
       secretName: mySecret
       password: mySecretPassword
```

This exports the key with the provided username and password.


## Ansible Vault

[Ansible Vault](https://docs.ansible.com/ansible/latest/vault.html) allows you
to keep sensitive data in file that can then be accessed in a concord flow 
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

## Custom Docker Images

The Ansible task typically runs on the default Docker container used by Concord
for process executions. In some cases  Ansible playbooks require additional
modules to be installed. You can create a suitable Docker image, publish it to a
registry and subsequently use it in your flow by specifying it as parameter for
`run`:

```yaml
- ${ansible.run('docker.prod.walmart.com/walmartlabs/concord-ansible', params, workDir)}
```

Or as input parameters for the Ansible task:

```yaml
- task: ansible
  in:
    dockerImage: "docker.prod.walmart.com/walmartlabs/concord-ansible"
```

We recommend using `docker.prod.walmart.com/walmartlabs/concord-ansible`
as a base for your custom Docker images.

Please refer to our
[Docker support documentation](../getting-started/docker.html)
for more details.

## Retry and Limit Files

Concord provides support for Ansible "retry files". By
default, when a playbook execution fails, Ansible creates a `*.limit` file which
can be used to restart the execution for failed hosts.

If the `retry` parameter is set to `true`, Concord automatically uses the
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