---
layout: wmt/docs
title:  Packer Task
side-navigation: wmt/docs-navigation.html
deprecated: true
---

# {{ page.title }}

Concord supports interaction with the infrastructure tool
[Packer](https://www.packer.io/) with the `packer` task as part of any
flow.

- [Usage](#usage)
- [Building images](#building)
- [Input Variables](#variables)
- [Environment Variables](#env)
- [External Variable Files](#var-files)

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../processes-v1/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:packer-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke it in any flow.

The task requires the process to run as a part of a Concord project.

<a name="building"/>

## Building Images

The `build` command executes `packer build` in the process' working directory:

```yaml
- task: packer
  in:
    command: build
    template: packer.json
```

Parameters:

- `version` - string value, version of Packer to use;
- `url` - string value, url of the Packer binary to use;
- `debug` - boolean value, if `true` the plugin logs additional debug
information;
- `force` - boolean value, force a build to continue if artifacts exist,
deletes existing artifacts;
- `except` - string list, run all builds and post-processors other than these;
- `only` - string list; build only the specified builds;
- `onError` - string value, if the build fails do: `cleanup` or `abort`;
- `parallel` - boolean value, if `false` disable parallelization;
- `parallelBuilds` - int value, number of builds to run in parallel. 0 means no
limit (default: 0);
- `varFile` - string value, JSON file containing user variables;
- `template` - string value, Packer template to use for building;
- `extraVars` - key value pairs, [variables](#variables) provided to
the `packer` process.

<a name="variables"/>

## Input Variables

[Input variables](https://www.packer.io/docs/commands/build.html#var-file)
can be specified using the `extraVars` parameter:

```yaml
- task: packer
  in:
    command: build
    extraVars:
      aVar: "someValue"
      nestedVar:
        x: 123
```

The `extraVars` parameter expects regular `java.util.Map<String, Object>`
objects and supports all JSON-compatible data structures (nested objects,
lists, etc).

Specifying `extraVars` is an equivalent of running
`packer build -var-file=/path/to/file.json`.

<a name="env"/>

## Environment Variables

OS-level [environment variables](https://www.packer.io/docs/templates/legacy_json_templates/user-variables)
can be specified using `envars` parameter:

```yaml
- task: packer
  in:
    command: build
    envars:
      VERSION: 1.0
      NAME: Concord
```

<a name="var-files"/>

## External Variable Files

Paths to an external files with variables can be added to `plan` or `apply`
actions using `varFiles` parameter:

```yaml
- task: packer
  in:
    command: build
    varFiles:
      - "path/to/my-vars.json"
      - "another/path/to/other/vars.json"
```

Paths must be relative to the current process' `${workDir}`.
