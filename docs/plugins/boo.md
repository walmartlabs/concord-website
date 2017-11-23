---
layout: wmt/docs
title:  Boo Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord supports creation of new assemblies and environments in
[OneOps](http://oneops.com/) via
[Boo](https://github.com/oneops/boo)
with the `boo` task as part of any flow. These assemblies can be deployed to
specific environments in operation with the task and further interaction can be
performed with the
[OneOps task](./oneops.html).

Modifications via Concord follow the same change process from design to
transition and to operate via commit and deploy operations as any other usage
of OneOps.


<a name="usage"/>

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:boo-task:0.35.0
```

This adds the task to the classpath and allows you to configure the main
parameter in a separate collections e.g. named `booConfig`:

```yaml
configuration:
  arguments:
    booConfig:
      booTemplateLocation: boo.yml
      oneopsApiHost: https://oneops.example.com
      assemblyTags:
        owner: "Jane Doe"
        team: "The Incredibles"
```

- `booTemplateLocation` - path to the Boo YAML file
- `oneopsApiHost` - URL of the OneOps server
- `assemblyTags` - list of key/value pairs to use as tags for the assembly

In addition any other defined parameters are passed into the Boo YAML file for
substitution.

- [Running the Boo task](#run)
- [Delete an Assembly](#delete)
- [Source Reference](#source)


<a name="run"/>

## Running the Boo Task

The main Boo task creates an assembly and any enviroments based on the boo
configuration and the content of the Boo YAML file. Variables from the Concord
configuration are injected into the Boo file.

For example, the Boo YAML file can start with this content:

```yaml
boo:
  oneops_host: "{{oneopsApiHost}}"
  organization: '{{org}}'
  api_key: '{{apiKey}}'
  email: '{{email}}'
  environment_name: '{{env}}'
  ip_output: 'json'

assembly:
  name: "{{asm}}"
```

The variables such as `organization`, `apiKey`, `email` and others can be added to the
`booConfig` and are passed in a substituted for execution of Boo.

```
configuration:
  arguments:
    booConfig:
      booTemplateLocation: boo.yml
      oneopsApiHost: https://oneops.example.com
      organization: myOrganization
      apiKey: ${crypto.decryptString("encryptedApiTokenValue")}
      email: jane.doe@example.com
      asm: myAssembly
      env: myEnv
      ...
```

With the configuration in place, you can call the Boo tasks using the
configuration object with the task syntax:

```yaml
flows:
  default:
  - task: boo
    in:
      booConfig
```

Or using an expression:

```yaml
flows:
  default:
  ${boo.run(context, booConfig, workDir)}
```

The `context` and `workDir` values are automatically provided by Concord.


<a name="delete"/>

## Delete an Assembly

The Boo task can delete an assembly. This includes the deletion of any
environments:

```yaml
- ${boo.deleteAssembly(context, config, workDir)}
```

The `context` and `workDir` values are automatically provided by Concord.


<a name="source"/>

## Source Reference

The [source code of the task implementation](${concord_plugins_source}tree/master/tasks/boo)
can be used as the reference for the available functionality.
