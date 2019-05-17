---
layout: wmt/docs
title:  Taurus Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

[Taurus](https://gettaurus.org) is an automation-friendly framework for
continuous testing. Concord supports executing Taurus tests as a part of any
flow using `taurus` task.

- [Usage](#usage)
- [Running Tests](#running-tests)
- [Configuration Files](#configuration-files)
- [Examples](#examples)

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:taurus-task:{{ site.concord_plugins_version }}
```

## Running Tests

The `taurus` task uses a number of input parameters

- `action`: required, the name of the operation to perform;
- `configs`: required, list of configuration file(s) or configuration objects
  consumed by the `taurus` tool as input. More details in the
  [configuration files](#configuration-files) section;
- `ignoreErrors`: boolean value, if `true` any errors that occur during the
  execution are ignored and stored in the result variable. Defaults to `false`;
- `quiet`: boolean value, if `true` only errors and warnings printed to console.
  Defaults to `false`. Can not be used, if `verbose` set to `true`;
- `verbose`: boolean value, if `true` prints all logging messages to console.
  Defaults to `false`. Cannot be used if `quiet` set to `true`
- `proxy`: string value, used for Taurus-based requests.
- `downloadPlugins`: boolean value, defaults to `false` and completely offline
  work. If `true` tries to download JMeter plugins at runtime.

The following example performs a `run` action with Taurus using the `test.yml`
configuration file:

```yaml
flows:
  default:
  - task: taurus
    in:
      action: run
      configs:
        - test.yml
        
  - log: "Taurus output: ${result.stdout}"
```

The execution status and logs are stored in the `result` variable.

## Configuration Files

The plugins supports mixing and matching configuration files and inline
configuration definitions:

```yaml
configuration:
  arguments:
    someVar: "someValue"

flows:
  default:
  - task: taurus
    in:
      action: run
      configs:
        - a.yml
        - b.yml
        - scenarios:
            myTest:
              variables:
                someVar: ${someVar} # example of using a flow variable
```

The inline configuration definitions will be saved as YAML files in a temporary
directly. Taurus automatically merges all input configurations.

[Expressions](../getting-started/concord-dsl.html#expressions) can be used in
any input parameter including the inline configuration definitions.

## Examples

- [minimal example](https://github.com/walmartlabs/concord-plugins/tree/master/tasks/taurus/examples/simple)
