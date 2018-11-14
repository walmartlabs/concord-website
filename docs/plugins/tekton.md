---
layout: wmt/docs
title:  Tekton Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord supports interaction with Tekton with the `tekton` task as part of any
flow. 

- [Usage](#usage)
- [Parameters](#parameters)

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:tekton-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke the task in a flow:

```yaml
flows:
  default:
  - task: tekton
    in:
      TBD
```


## Parameters

All parameter sorted alphabetically. Usage documentation can be found in the
following sections:

- `aparameter`: description