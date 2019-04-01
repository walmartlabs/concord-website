---
layout: wmt/docs
title:  Policies
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Policies is a powerful and flexible mechanism to control different
characteristics of processes and system entities.

## Overview

A policy is a JSON document describing rules that can affect the execution of
processes, creation of entities such as project and secrets, define the limits
for the process queue, etc.

Policies can be applied system-wide as well as linked to an organization, a
specific project or to a user.

Policies can be created using the [Policy API](../api/policy.html). Currently,
only the users with the administrator role can create or link policies.

Policies can inherent other policies - in this case the parent policies are
applied first, going from the \"oldest\" ancestors to the latest link.

## Document Format

There are two types of objects in the policy document: `allow/deny/warn` actions
and free-form group of attributes:

```json
{
  "[actionRules]": {
    "deny": [
      {
        ...rule...
      }
    ],
    "warn": [
      {
        ...rule...
      }
    ],
    "allow": [
      {
        ...rule...
      }
    ]
  },
  
  "[anotherRule]": {
    ...rule...
  }
}
```

Here's the list of currently supported rules:
- [ansible](#ansible-rule) - controls the execution of
[Ansible](../plugins/ansible.html) plays;
- [dependency](#dependency-rule) - applies rules to process dependencies;
- [entity](#entity-rule) - controls creation or update of entities
  such as organizations, projects and secrets;
- [file](#file-rule) - applies to process files;
- [processCfg](#process-configuration-rule) - allows changing the process'
  `configuration` values;
- [queue](#queue-rule) - controls the process queue behaviour;
- [task](#task-rule) - applies rules to flow tasks;
- [workspace](#workspace-rule) - controls the size of the workspace.

## Ansible Rule

Ansible rules allow you to control the execution of
[Ansible](../plugins/ansible.html) plays.

The syntax:

```json
{
  "action": "ansibleTaskName",
  "params": [
    {
      "name": "paramName",
      "values": ["arrayOfValues"]
    }
  ],
  "msg": "optional message"
}
```

The `action` attribute defines the name of the Ansible step and the `params`
object is matched with the step's input parameters. The error message can be
specified using the `msg` attribute.

For example, to forbid a certain URI from being used in the Ansible's
[get_url](https://docs.ansible.com/ansible/2.6/modules/get_url_module.html)
step:

```json
{
  "ansible": {
    "deny": [
      {
        "action": "get_url",
        "params": [
          {
            "name": "url",
            "values": ["https://jsonplaceholder.typicode.com/todos"]
          }
        ],
        "msg": "Found a forbidden URL"
      }
    ]
  }
}
```

If someone tries to use the forbidden URL in their `get_url`, they see a
message in the process log:

```
ANSIBLE:  [ERROR]: Task 'get_url (get_url)' is forbidden by the task policy: Found a
ANSIBLE: forbidden URL
```

The Ansible rule supports
[regular JUEL expressions](./concord-dsl.html#expressions) which are evaluated
each time the Ansible plugin starts using the current process' context. This
allows users to create context-aware Ansible policies:

```json
{
  "ansible": {
    "deny": [
      {
        "action": "maven_artifact",
        "params": [
          {
            "artifact_url": "url",
            "values": ["${mySecretTask.getForbiddenArtifacts()}"]
          }
        ]
      }
    ]
  }
}
```

**Note:** the `artifact_url` from the example above is not a standard
[maven_artifact](https://docs.ansible.com/ansible/2.6/modules/maven_artifact_module.html)
step's parameter. It is created dynamically from the supplied values of
`repository_url`, `group_id`, `artifact_id`, etc.

## Dependency Rule

Dependency rules provide a way to control which process dependencies are allowed
for use.

The syntax:

```json
{
  "scheme": "...scheme...",
  "groupId": "...groupId...",
  "artifactId": "...artifactId...",
  "fromVersion": "1.0.0",
  "toVersion": "1.1.0",
  "msg": "optional message"
}
```

The attributes:
- `scheme` - the dependency URL scheme. For example: `http` or `mvn`;
- `groupId` and `artifactId` - parts of the dependency's Maven GAV (only for
`mvn` dependencies);
- `fromVersion` and `toVersion` - define the version range (only for `mvn`
dependencies).

For example, restricting a specific version range of a plugin can be done like
so:

```json
{
  "dependency": {
    "deny": [
      {        
        "groupId": "com.walmartlabs.concord.plugins.basic",
        "artifactId": "ansible-tasks",
        "toVersion": "1.13.1",
        "msg": "Usage of ansible-tasks <= 1.14.0 is forbidden"
      }
    ]
  }
}
```

In this example, all versions of the `ansible-tasks` dependency lower than
`1.13.1` are rejected.

Another example, warn users every time they are trying to use non-`mvn`
dependencies:

```json
{
"dependency": {
    "warn": [
      {
        "msg": "Using direct dependency URLs is not recommended. Consider using mvn:// dependencies.",
        "scheme": "^(?!mvn.*$).*"
      }
    ]
  }
}
```

## Entity Rule

Entity rules control the creation or update of Concord
[organizations](../api/org.html), [projects](../api/project.html) and
[secrets](../api/secret.html).

The syntax:

```json
{
  "entity": "entityType",
  "action": "action",
  "conditions": {
    "param": "value"
  },
  "msg": "optional message"
}
```

The currently supported `entity` types are:

- `org`
- `project`
- `secret`

Available actions:

- `create`
- `update`

The `conditions` are matched against an object containing both the entity's
and the entity's owner attributes:

```json
{
  "owner": {
    "id": "...userId...",
    "username": "...username...",
    "userType": "LOCAL or LDAP",
    "email": "...",
    "displayName": "...",
    "groups": ["AD/LDAP groups"],
    "attributes": {
      ...other AD/LDAP attributes...
    }  
  },
  "entity": {
    ...entity specific attributes...
  }
}
``` 

Different types of entities provide different sets of attributes:

- `org`:
  - `id` - organization ID (UUID, optional);
  - `name` - organization name;
  - `meta` - metadata (JSON object, optional);
  - `cfg` - configuration (JSON object, optional).
- `project`:
  - `id` - project ID (UUID, optional);
  - `name` - project name;
  - `orgId` - the project's organization ID (UUID);
  - `orgName` - the project's organization name;
  - `visibility` - the project's visibility (`PUBLIC` or `PRIVATE`);
  - `meta` - metadata (JSON object, optional);
  - `cfg` - configuration (JSON object, optional).
- `secret`:
  - `name` - project name;
  - `orgId` - the secrets's organization ID (UUID);
  - `type` - the secret's type;
  - `visibility` - the secret's visibility (`PUBLIC` or `PRIVATE`, optional);
  - `storeType` - the secret's store type (optional).

For example, to restrict creation of projects in the `Default` organization use:

```json
{
   "entity": {
      "deny": [
         {
            "msg": "project in default org are disabled",
            "action": "create",
            "entity": "project",
            "conditions":{
               "entity": {
                  "orgId": "0fac1b18-d179-11e7-b3e7-d7df4543ed4f"
               }
            }
         }
      ]
   }
}
``` 

To prevent users with a specific AD/LDAP group from creating any new entities:

```json
{
   "entity": {
      "deny":[  
         {
            "action": ".*",
            "entity": ".*",
            "conditions": {
               "owner": {
               	  "userType": "LDAP",
               	  "groups": ["CN=SomeGroup,.*"]
               } 
            }
         }
      ]
   }
}
```

## File Rule

The file rules control the types and sizes of files that are allowed in
the process' workspace.

The syntax:
```json
{
  "maxSize": "1G",
  "type": "...type...",
  "names": ["...filename patterns..."],
  "msg": "optional message"
}
```

The attributes:

- `maxSize` - maximum size of a file (`G` for gigabytes, `M` - megabytes, etc);
- `type` - `file` or `dir`;
- `names` - filename patterns (regular expressions).

For example, to forbid files larger than 128Mb:

```json
{
  "file": {
    "deny": [
      {
        "maxSize": "128M",
        "msg": "Files larger than 128M are forbidden"
      }
    ]
  }
}
```

## Process Configuration Rule

The `processCfg` values are merged into the process' `configuration` object,
overriding any existing values with the same keys:

```json
{
  "...variable...": "...value..."
}
```

For example, to force a specific [processTimeout](./concord-dsl.html#timeout)
value:

```json
{
  "processCfg": {
    "processTimeout": "PT2H"
  }
}
```

Or to override a value in `arguments`:

```json
{
  "processCfg": {
      "arguments": {
        "message": "Hello from Concord!"
      }
  }
}
```

## Queue Rule

The queue rule controls different aspects of the process queue - the maximum
number of concurrently running processes, the default process timeout, etc.

The syntax:

```json
{
  "concurrent": {
    "maxPerOrg": "10",
    "maxPerProject": "5",
    "msg": "optional message"
  },
  "process": {
    ...process status rule...
  },
  "processPerOrg": {
    ...process status rule...
  },
  "processPerProject": {
    ...process status rule...
  },
  "forkDepth": {
    "max": 5,
    "msg": "optional message"
  },
  "processTimeout": {
    "max": "PT1H",
    "msg": "optional message"
  } 
}
```

The attributes:

- `concurrent` - controls the number of concurrently running processes:
  - `maxPerOrg` - max number of running processes per organization;
  - `maxPerProject` - max number of running processes per project;
- `process`, `processPerOrg`, `processPerProject` - controls the maximum number
of processes for a specific status (see below);
- `forkDepth` - the maximum allowed depth of process forks, i.e. how many
_ancestors_ a process can have. Can be used to prevent "fork bombs";
- `processTimeout` - limits the maximum allowed value of the
[processTimeout parameter](./concord-dsl.html#timeout).

The process status rule has the following syntax:

```json
{
  "max": {
    "...status...": 5,
    "...another status...": 1
  },
  "msg": "optional message"
}
```

The `max` value controls the number of concurrent processes allowed for a
specific status. It can effectively control how many processes can an
organization or a project start concurrently.  

For example:

```json
{
  "queue": {
    "forkDepth": {
      "max": 5
    },
    "concurrent": {
      "max": 40
    }
  }
}
```

## Task Rule

Task rules control the execution of flow tasks. They can trigger on specific
methods or parameter values.

The syntax:

```json
{
  "taskName": "...task name...",
  "method": "...method name...",
  "params": [
    {
      "name": "...parameter name...",
      "index": 0,
      "values": [
        false,
        null
      ],
      "protected": true
    }
  ],
  "msg": "optional message"
}
```

The attributes:

- `taskName` - name of the task (as in the task's `@Named` annotation);
- `method` - the task's method name;
- `params` - list of the task's parameters to match.

The `params` attribute accepts a list of parameter definitions:

- `name` - name of the parameter in the process' `Context`;
- `index` - index of the parameter in the method's signature;
- `values` - a list of values to trigger on;
- `protected` - if `true` the parameter will be treated as a protected
variable.

For example, if there is a need to disable a specific task based on some
variable in the process' context, it can be achieved with a policy:

```json
{
  "task": {
    "deny": [
      {
        "taskName": "ansible",
        "method": "execute",
        "params": [
          {
            "name": "gatekeeperResult",
            "index": 0,
            "values": [
              false,
              null
            ],
            "protected": true
          }
        ],        
        "msg": "I won't run Ansible without running the Gatekeeper task first"
      }
    ]
  }
}
```

In this example, because the Ansible's plugin method `execute` accepts
a `Context`, the policy executor looks for a `gatekeeperResult` in
the process' context.

## Workspace Rule

The workspace rule allows control of the overall size of the process'
workspace.

The syntax:

```json
{    
  "maxSizeInBytes": 1024,
  "ignoredFiles": ["...filename patterns..."],    
  "msg": "optional message"
}
```

The attributes:

- `maxSizeInBytes` - maximum allowed size of the workspace minus the
`ignoredFiles` (in bytes);
- `ignoredFiles` - list of filename patterns (regular expressions). The
matching files will be excluded from the total size calculation.

Example:

```json
{
  "workspace": {
    "msg": "Workspace too big (allowed size is 256Mb, excluding '.git')",
    "ignoredFiles": [
      ".*/\\.git/.*"
    ],
    "maxSizeInBytes": 268435456
  }
}
```
