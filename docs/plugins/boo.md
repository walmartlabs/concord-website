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
  - mvn://com.walmartlabs.concord.plugins:boo-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you use the Boo task.

- [Using the Boo Task](#using)
- [Delete an Assembly](#delete)
- [Source Reference](#source)


<a name="using"/>

## Using the Boo Task

The main Boo task creates an assembly and any enviroments based on the boo
configuration and the content of the Boo YAML file. Variables from the Concord
configuration are injected into the Boo file.

The main configuration parameters for boo are:

```yaml
booTemplateLocation: boo.yml
oneopsApiHost: https://oneops.example.com
assemblyTags:
  owner: "Jane Doe"
  team: "The Incredibles"
```

- `booTemplateLocation` - path to the Boo YAML file
- `oneopsApiHost` - URL of the OneOps server
- `assemblyTags` - list of key/value pairs to use as tags for the assembly

These can be set in a separate argument configuration object e.g. called
`booConfig`.


```yaml
configuration:
  arguments:
    booConfig:
      booTemplateLocation: boo.yml
      ...
```

This is mainly suitable for invocation of the Boo task via an
expression.

```yaml
flows:
  default:
  - ${boo.run(context, config, workDir)}
```

The `context` and `workDir` values are automatically provided by Concord.

Alternatively the configuration can be provided directly as input parameters of
a Boo task invocation.

```yaml
flows:
  default:
  - task: boo
    in:
      booTemplateLocation: boo.yml
      oneopsApiHost: https://oneops.example.com
      ...
````

Any other defined parameters are passed into the Boo YAML file for
substitution.

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

The variables such as `organization`, `apiKey`, `email` and others can be added to
the `booConfig` or the 'in` parameters and are passed in a substituted for
execution of Boo.

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

The
[source code of the task implementation]({{site.concord_plugins_source}}tree/master/tasks/boo)
can be used as the reference for the available functionality.
