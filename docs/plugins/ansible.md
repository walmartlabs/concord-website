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
- [Ansible](#ansible)
- [Parameters](#parameters)
- [Configuring Ansible](#configuring-ansible)
- [Inline inventories](#inline-inventories)
- [Dynamic inventories](#dynamic-inventories)
- [Authentication with Secrets](#secrets)
- [Ansible Vault](#ansible-vault)
- [Custom Docker Images](#docker)
- [Retry and Limit Files](#retry-limit)
- [Ansible Lookup Plugins](#ansible-lookup-plugins)
- [Group Vars](#group-vars)
- [Limitations](#limitations)

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins.basic:ansible-tasks:0.56.0
```

This adds the task to the classpath and allows you to invoke the task in a flow:

```yaml
flows:
  default:
  - task: ansible
    in:
      playbook: playbook/hello.yml
```

## Ansible 

The plugin, with a configuration as above, executes an Ansible playbook with the
Ansible installation running on Concord. 

__The version of Ansible being used is 2.4.3.__

A number of configuration parameters are pre-configred by the plugin:

```
[defaults]
callback_plugins = _callbacks
host_key_checking = false
gather_subset = !facter,!ohai
remote_tmp = /tmp/ansible/$USER
timeout = 120
lookup_plugins = _lookups
[ssh_connection]
control_path = %(directory)s/%%h-%%p-%%r
pipelining = True
```

Further and up to date details are available
[in the source code of the plugin]({{concord_source}}blob/master/plugins/tasks/ansible/src/main/java/com/walmartlabs/concord/plugins/ansible/RunPlaybookTask2.java).

One of the most important lines is `gather_subset = !facter,!ohai`. This disables
some of the variables that are usually available such as `ansible_default_ipv4`. 
The parameters can be overridden in your own Ansible task invocation as
described in [Configuring Ansible](#configuring-ansible):


```
- task: ansible
  in:
    config:
      defaults:
         gather_subset: all
```


## Parameters

All parameter sorted alphabetically. Usage documentation can be found in the 
following sections:

- `config`: JSON object, used to create an
- `debug`: boolean, enables additional debug logging;
[Ansible configuration](#configuring-ansible);
- `dockerImage`: optional configuration to specifiy 
- `dynamicInventoryFile`: string, path to a dynamic inventory
  script. See also [Dynamic inventories](#dynamic-inventories) section;
- `extraEnv`: JSON object, additional environment variables
- `extraVars`: JSON object, used as `--extra-vars`
- `groupVars`: configuration for exporting secrets as Ansible [group_vars](#group-vars) files;
- `inventory`: JSON object, an inventory data specifying
  [a static, inline inventories](#inline-inventories)section;
- `inventoryFile`: string, path to an inventory file;
- `limit`: limit file, see [Retry and Limit Files](#retry-limit)
- `playbook`: string, relative path to a playbook;
  argument of `ansible-playbook` command. Check [the official
  documentation](http://docs.ansible.com/ansible/latest/playbooks_variables.html#id31)
  for more details;
- `privateKey`: path to a privateKey file or with nested `org`, `secretName` and `password`
  the name of a Concord secret SSH key to use to connect to the target servers;
- `user`: string, username to connect to target servers;
- `retry`: retry flag, see [Retry and Limit Files](#retry-limit)
- `tags`: string, a comma-separated list or an array of [tags](http://docs.ansible.com/ansible/latest/playbooks_tags.html);
- `skipTags`: string, a comma-separated list or an array of [tags](http://docs.ansible.com/ansible/latest/playbooks_tags.html) to skip;
- `saveRetryFile`: file name for the retry file, see [Retry and Limit Files](#retry-limit)
- `vaultPassword`: string, password to use with [Ansible Vault](#ansible-vault).
- `verbose`: integer, increase log [verbosity](http://docs.ansible.com/ansible/latest/ansible-playbook.html#cmdoption-ansible-playbook-v). 1-4 correlate to -v through -vvvv.


## Configuring Ansible

Ansible's [configuration](http://docs.ansible.com/ansible/intro_configuration.html)
can be specified under the  `config` key:


```yaml
flows:
  default:
  - task: ansible
    in:
      config:
        defaults:
          forks: 50
        ssh_connection:
          pipelining: True
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
flows:
  default:
  - task: ansible
    in:
      playbook: "playbook/hello.yml"
      inventory:
        local:
          hosts:
            - "127.0.0.1"
          vars:
            ansible_connection: "local"
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
flows:
  default:
  - task: ansible
    in:
      playbook: "playbook/hello.yml"
      inventoryFile: inventory.ini
```

## Dynamic Inventories

Alternatively to a static configuration to set the target system for Ansible,
you can use a script to create the inventory - a
[dynamic inventory](http://docs.ansible.com/ansible/latest/intro_dynamic_inventory.html).

You can specify the name of the script using the `dynamicInventoryFile` as input
parameter for the task:

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


<a name="secrets"/>

## Authentication with Secrets

The Ansible task can use a key managed as a secret by Concord, that you have
created  or uploaded  via the user interface or the
[REST API](../api/secret.html) to connect to the target servers.

The public part of a key pair should be added as a trusted key to the
target server. The easiest way to check if the key is correct is to
try to login to the remote server like this:

```
ssh -v -i /path/to/the/private/key remote_user@target_host
```

If you are able to login to the target server without any error
messages or password prompt, then the key is correct and can be used
with Ansible and Concord.

The next step is to configure the `user` to use to connect to the servers and
the key to use with the `privateKey` configuration:

```yaml
flows:
 default:
 - task: ansible
   in:
     user: app
     privateKey:
       secretName: mySecret
       password: mySecretPassword
```

This exports the key with the provided username and password to the filesystem
as `temporaryKeyFile` and uses the configured username `app` to connect. The
equivalent Ansible command is

```
ansible-playbook --user=app --private-key temporaryKeyFile ...
```

## Ansible Vault

[Ansible Vault](https://docs.ansible.com/ansible/latest/vault.html) allows you
to keep sensitive data in files that can then be accessed in a concord flow.
The password  and the password file for Vault usage can be specified using
`vaultPassword` or  `vaultPasswordFile` parameters:

```yaml
flows:
  default:
  - task: ansible
    in:
      vaultPassword: "myS3cr3t"
      vaultPasswordFile: "get_vault_pwd.py"
```

Any secret values are then made available for usage in the ansible playbook as
usual. 

Our [ansible_vault example project]({{ site.concord_source}}/tree/master/examples/ansible_vault)
shows a complete setup and usage.

<a name="docker"/>

## Custom Docker Images

The Ansible task typically runs on the default Docker container used by Concord
for process executions. In some cases Ansible playbooks require additional
modules to be installed. You can create a suitable Docker image, publish it to a
registry and subsequently use it in your flow by specifying it as input
parameters for the Ansible task:

```yaml
flows:
  default:
  - task: ansible
    in:
      dockerImage: "docker.prod.walmart.com/walmartlabs/concord-ansible"
```

We recommend using `docker.prod.walmart.com/walmartlabs/concord-ansible`
as a base for your custom Docker images.

Please refer to our
[Docker support documentation](../getting-started/docker.html)
for more details.

<a name="retry-limit"/>

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

## Ansible Lookup Plugins

Concord provides a special [Ansible lookup plugin](https://docs.ansible.com/ansible/devel/plugins/lookup.html)
to retrieve password-protected secrets in playbooks:

```yaml
{% raw %}
- hosts: local
  tasks:
  - debug:
      msg: "We got {{ lookup('concord_secret', 'myOrg', 'mySecret', 'myPwd') }}"
      verbosity: 0
{% endraw %}
```

In this example `myOrg` is the name of the organization which owns the secret,
`mySecret` is the name of the retrieved secret and `myPwd` is the password
which was used to store the secret.

If the process was started using a project, then the organization name can be
omitted. Concord will automatically use the name of the project's organization:

```yaml
{% raw %}
- hosts: local
  tasks:
  - debug:
      msg: "We got {{ lookup('concord_secret', 'mySecret', 'myPwd') }}"
      verbosity: 0
{% endraw %}
```

Currently, only simple string value secrets are supported.

See also [the example](https://gecgithub01.walmart.com/devtools/concord/tree/master/examples/secret_lookup)
project.

## Group Vars

Files stored as Concord [secrets](../api/secret.html) can be used as Ansible's
`group_var` files.

For example, if we have a file stored as a secret like this:
```yaml
# myVars.yml
my_name: "Concord"

# saved as:
#   curl ... \
#     -F type=data \
#     -F name=myVars \
#     -F data=@myVars.yml \
#     -F storePassword=myPwd \
#     http://host:port/api/v1/org/Default/secret
```

it can be exported as a group_vars file using `groupVars` parameter:
```yaml
flows:
  default:
  - task: ansible
    in:
      playbook: myPlaybooks/play.yml
      ...
      groupVars:
      - myGroup:
          orgName: "Default"    # optional
          secretName: "myVars"
          password: "myPwd"     # optional
          type: "yml"           # optional, default "yml"
```

In the example above, `myVars` secret will be exported as a file into
`${workDir}/myPlaybooks/group_vars/myGroup.yml` and `my_name` variable will be
available for `myGroup` host group.

Check [the official Ansible documentation](http://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#group-variables)
for more details on how `group_vars` files work.

## Limitations

Ansible's `strategy: debug` is not supported. It requires an interactive terminal and
expects user input and should not be used in Concord's environment.
Playbooks with `strategy: debug` will hang indefinitely, but can be killed using the
REST API or the Console.
