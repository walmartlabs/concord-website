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
parameters in a separate collection e.g. named `booConfig`:

```yaml
configuration:
  arguments:
    booConfig:
      booTemplateLocation: boo.yml
```

- `tbd` - tbd

With the configuration in place, you can call use the boo tasks using the
configuration object.

```yaml
flows:
  default:
  - task: boo
    in:
      booTemplateLocation: boo.yml
```

The following sections describe the available functions in more detail:

- [Running the Boo task](#run)
- [Delete an Assembly](#delete)
- [Source Reference](#source)


<a name="run"/>

## Running the Boo Task

The main Boo task creates an assembly and any enviroments based on the boo
configuration and the content of the Boo YAML file. Variables from the Concord
configuration are injected into the Boo file.


```yaml
flows:
  default:
  - task: boo
    in: 
      tbd: tbd
```

<a name="delete"/>

## Delete an Assembly

The Boo task can delete an assembly. This includes the deletion of any
environments:

```yaml
- ${boo.deleteAssembly(tbd)
 - expr: ${boo.deleteAssembly(execution, config, __attr_localPath)}
```


<a name="source"/>

## Source Reference

The [source code of the task implementation](${concord_plugins_source}tree/master/tasks/boo)
can be used as the reference for the available functionality.
