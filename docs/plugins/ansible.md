---
layout: wmt/docs
title:  Ansible
---

# Ansible task

## Running existing playbooks

### Without creating a Concord project

1. Create a ZIP archive containing the playbook;
2. Create a `request.json` file of the following structure:
   ```json
   {
    "template": "ansible",
    "playbook": "playbook/my.yml"
   }
   ```
   The `playbook` parameter is the path to a playbook inside of the
   archive. Make sure that they are the same.
3. Send the archive and `request.json` file to Concord:
   ```
   curl -v \
   -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" \
   -F request=@request.json \
   -F archive=@archive.zip \
   http://localhost:8001/api/v1/process
   ```
4. Open the Concord's Console and check the process logs.

See also the full [example](https://gecgithub01.walmart.com/devtools/concord/tree/master/examples/ansible_template).

### From a GIT repository.

Please refer to the [ansible_project](https://gecgithub01.walmart.com/devtools/concord/tree/master/examples/ansible_project)
example.

## Limitations

Ansible's `strategy: debug` is not supported. It requires an interactive terminal and
user input and shouldn't be used in Concord's environment.
Playbooks with `strategy: debug` will hang indefinitely, but can be killed using the
REST API or the Console.


## Configuring Ansible

Ansible's [[configuration]](http://docs.ansible.com/ansible/intro_configuration.html)
can be specified under `config` key in `request.json`:

```json
{
  "playbook": "playbook/hello.yml",
  ...
  "config": {
    "defaults": {
      "forks": 50
    },
    "ssh_connection": {
      "pipelining": "True"
    }
  }
}
```

which is equivalent to:

```
[defaults]
forks = 50

[ssh_connection]
pipelining = True
```

## Raw payload

### Vault password files

For the projects using "ansible" template, set `vaultPassword` variable
in a top-level JSON object of a `request.json` file:
```json
{
  "vaultPassword": "..."
}
```

When using the raw payload format, set
`arguments.ansibleCfg.vaultPassword` variable in a request JSON object:
```json
{
  "arguments": {
    "ansibleCfg": {
      "vaultPassword": "..."
    }
  }
}
```

Alternatively, a file named `_vaultPassword` can be added to the root
directory of a payload.

## Ansible projects

### Using dynamic inventories

To use a dynamic inventory script, upload it as a `dynamicInventory`
value in the process call:

```
curl -v \
-H "Authorization: auBy4eDWrKWsyhiDp3AQiw" \
-F request=@request.json \
-F dynamicInventory=@inventory.py \
http://localhost:8001/api/v1/process/myProject:myRepo
```

It will be marked as executable and passed directly
to `ansible-playbook` command.

### Using inline inventories

An inventory file can be inlined with the request JSON. For example:

```json
{
  "playbook": "playbook/hello.yml",
  ...
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

Concord creates a "fake" dynamic inventory script that returns the
content of `inventory` field.

### Using SSH keys

The Ansible plugin supports calling a playbook with a specific SSH key.

1. Upload a SSH key pair. See the [uploading an existing key pair](../getting-started/security.html#uploading-an-existing-key-pair)
document.
2. Add a private key section to a project configuration:

    ```json
    {
      "cfg": {
       "ansible": {
         "privateKeys": [
           {
             "repository": "myRepo",
             "secret": "mySshKeyPair"
           }
         ]
       }
     }
    }
    ```
    Where `repository` is the pattern matching the name of a project's
    repository and `secret` is the name of the uploaded SSH key pair.
