---
layout: wmt/docs
title:  Taurus Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord supports creating and executing `jmeter` scripts with the `taurus` task
as part of any flow. More details about `taurus` tool itself can be found
[on the Taurus website](https://gettaurus.org/kb/Basic1/).

- [Usage](#usage)
- [Run](#run)

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:taurus-task:{{ site.concord_plugins_version }}
```

## Run

The `taurus` task uses a number of input parameters

- `action`: Required - The name of the operation to perform.
- `configs`: Required - List of configuration file(s) consumed by the `taurus`
  tool as input.
- `ignoreErrors`:  boolean value, if true any errors that occur during the
  execution are ignored and stored in the result variable. Defaults to `false`.
- `noSysConfig`: boolean value, if true skips `/etc/bzt.d` and `~/.bzt-rc`.
  Defaults to `false`.
- `quiet`: boolean value, if true only errors and warnings printed to console.
  Defaults to `false`. Can not be used, if `verbose` set to `true`.
- `verbose`: boolean value, if true prints all logging messages to console.
  Defaults to `false`. Cannot be used if `quiet` set to `true`
- `proxy`: string value, used for Taurus-based requests. By default uses the
  proxy set in `server` default variables.
- `useFakeHome`: boolean value, sets up a fake `${HOME}` to avoid using the
  system's one. Default set to `true`.

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

The execution logs are stored in the variable `${result}` and these can be used
at later point in flow.
