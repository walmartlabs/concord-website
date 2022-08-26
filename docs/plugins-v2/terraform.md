---
layout: wmt/docs
title:  Terraform Task
side-navigation: wmt/docs-navigation.html
description: Plugin for provisioning IaC with Terraform
---

# {{ page.title }}

Concord supports interaction with the infrastructure provisioning tool
[Terraform](https://www.terraform.io/) with the `terraform` task as part of any
flow.

- [Usage](#usage)
- [Common Parameters](#common-parameters)
- [Planning the Changes](#planning)
- [Applying the Changes](#applying)
- [Destroying Infrastructure](#destroying)
- [Input Variables](#variables)
- [Environment Variables](#env)
- [External Variable Files](#var-files)
- [Output Variables](#output)
- [State Backends](#backends)
- [Terraform Enterprise / Cloud](#remote)
- [GIT modules](#git-modules)
- [Terraform Version](#terraform-version)
- [Executing inside a Docker container](#executing-inside-a-docker-container)
- [Examples](#examples)

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../processes-v2/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:terraform-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke it in any flow.

The task requires the process to run as a part of a Concord project.

<a name="common-parameters"></a>

## Common Parameters

- `action` - (mandatory) action to perform:
  - `plan` - [plan](#planning) the changes
  - `apply` - [apply](#applying) the changes with or without using a previously
    created plan file
  - `destroy` -[destroy](#destroying) an environment
  - `output` - save the [output variables](#output)
- `backend` - type of a [state backend](#backends) to use:
  - `concord` - (default) use the backend provided by Concord
  - `none` - use the default file-based backend or the backend configuration
    provided by the user
  - `remote` - run on on Terraform Cloud or Terraform Enterprise
- `debug` - boolean value, if `true` the plugin logs additional debug information
- `dockerImage` - string value, optional [Docker image](#executing-inside-a-docker-container)
  to use for execution
- `extraEnv` - key-value pairs, extra environment variables provided to
  the `terraform` process
- `extraVars` - [variables](#variables) provided to the `terraform` process
- `ignoreErrors` - boolean value, if `true` any errors that occur during the
  execution will be ignored and stored in the `result` variable
- `ignoreLocalBinary` - boolean value, if `true` the plugin won't use
  a `terraform` binary from `$PATH`. See the [Terraform Version](#terraform-version)
  section for more details
- `pwd` - working directory. See the [Directories](#directories) section for
  more details;
- `stateId` - string value, the name of a state file to use. See
  the [State Backends](#backends) section for more details
- `toolUrl` - URL to a specific terraform bundle or version (.zip format). See
  the [Terraform Version](#terraform-version) section for more details
- `toolVersion` - Terraform version to use, mutually exclusive with `toolUrl`.
  See the [Terraform Version](#terraform-version) section for more details
- `varFiles` - list of files to add as `-var-file`.

<a name="planning"/>

## Planning the Changes

The `plan` action executes `terraform plan` in the process' working directory
or in a directory specified in `dir` parameter:

```yaml
# run `terraform plan` in `${workDir}`
- task: terraform
  in:
    action: plan
  out: result

# run `terraform plan` to generate a destroy plan
- task: terraform
  in:
    action: plan
    destroy: true
  out: result

# run `terraform plan` in a specific directory
- task: terraform
  in:
    action: plan
    dir: "myTFStuff"
  out: result
```

The plugin automatically creates the necessary [backend](#backends)
configuration and runs `terraform init` when necessary.

Parameters:

- `dir` - string value, path to a directory with `*.tf` files. The path must be
  relative to the process' `${workDir}`;
- `plan` - string value, path to a previosly created plan file. The path must
be relative to the process' `${workDir}`;
- `destroy` - boolean value, if true destroy plan is generated. By default,
  apply plan is generated;
- `gitSsh` - see [GIT modules](#git-modules).

In addition to
[common task result fields](../processes-v2/flows.html#task-result-data-structure),
the `terraform` task returns:

- `hasChanges` - boolean value, `true` if `terraform plan` detected any changes
  in the enviroment;
- `output` - string value, output of `terraform plan` (stdout);
- `planPath` - string value, path to the created plan file. The plugin stored
  such files as process attachments so they \"survive\" suspending/resuming the
  process or restoring from a
  [checkpoint](../processes-v2/flows.html#checkpoints). The path is
  relative to the process' `${workDir}`;
- `error` - string value, error of the last `terraform` execution (stderr).

The `output` field returned by the task can be used to output the plan into the
process' log, used in an approval form, Slack notification, etc.

<a name="applying"/>

## Applying the Changes

The `apply` action executes `terraform apply` in the process' working
directory, in a directory specified in `dir` parameter or using a
previously created `plan` file:

Run `terraform apply` in `${workDir}`:

```yaml
- task: terraform
  in:
    action: apply
  out: result
```

Run `terraform apply` in a specific directory

```yaml
- task: terraform
  in:
    action: apply
    dir: "myTFStuff"
  out: result
```

Run `terraform apply` using a plan file

```yaml
- task: terraform
  in:
    action: apply
    dir: "myTFStuff"
    plan: "${result.planPath}" # created by previously executed `plan` action
  out: result
```

As with the `plan` action, the plugin automatically runs `terraform init` when necessary.

Parameters:

- `dir` - string value, path to a directory with `*.tf` files. The path must be
relative to the process' `${workDir}`;
- `plan` - string value, path to a previosly created plan file. The path must
be relative to the process' `${workDir}`. When using `plan`, the original `dir`
must be specified as well;
- `gitSsh` - see [GIT modules](#git-modules).
- `saveOutput` - boolean value, if `true` the `terraform output` command will
be automatically executed after the `apply` is completed and the result will
be saved in the `result` variable.

In addition to
[common task result fields](../processes-v2/flows.html#task-result-data-structure),
the `terraform` task returns:

- `output` - string value, output of `terraform apply` (stdout);
- `data` - map (dict) value, contains the output values. Only if `saveOutput` is `true`.

<a name="destroying"/>

## Destroying Infrastructure

The `destroy` action executes `terraform destroy` in the process' working
directory or in a directory specified in `dir` parameter. This is provided in
addition to applying a plan generated with the `destroy` argument which 
is problematic with some modules and providers. 

When used with the `remote` backend the `CONFIRM_DESTROY` environment 
variable must be created in the relavent Cloud/Enterprise workspace.

Run `terraform destroy` in `${workDir}`:

```yaml
- task: terraform
  in:
    action: destroy
    extraEnv: 
      CONFIRM_DESTROY: 1
```

Run `terraform destroy` in a specific directory

```yaml
- task: terraform
  in:
    action: destroy 
    dir: "myTFStuff"
    extraEnv: 
      CONFIRM_DESTROY: 1
```

To target a specific resource add `target`:

```yaml
- task: terraform
  in:
    action: destroy
    dir: "myTFStuff"
    target: "digital_ocean_droplet.my_server"
```

For more details on the `target` syntax see
[the official documentation](https://www.terraform.io/docs/cli/commands/plan.html#resource-targeting).

## Directories

The plugin provides two input parameters to control where and how Terraform is
executed: `pwd` and `dir`.

Specifying those values is an equivalent of running the following shell command:
```
cd $pwd && terraform ... $dir
```

If not specified, the plugin uses the current process' `workDir` as `pwd` value.

Both `pwd` and `dir` path must be relative to the process' `workDir`.

<a name="variables"/>

## Input Variables

[Input variables](https://www.terraform.io/docs/configuration/variables.html)
can be specified using the `extraVars` parameter:

```yaml
- task: terraform
  in:
    action: plan
    extraVars:
      aVar: "someValue"
      nestedVar:
        x: 123
```

The `extraVars` parameter expects regular `java.util.Map<String, Object>`
objects and supports all JSON-compatible data structures (nested objects,
lists, etc).

Specifying `extraVars` is an equivalent of running `terraform [action] -var-file=/path/to/file.json`.

<a name="env"/>

## Environment Variables

OS-level [environment variables](https://www.terraform.io/docs/commands/environment-variables.html)
can be specified using `extraEnv` parameter:

```yaml
- task: terraform
  in:
    action: plan
    extraEnv:
      HTTPS_PROXY: http://proxy.example.com
      TF_LOG: TRACE
```

<a name="var-files"/>

## External Variable Files

Paths to an external files with variables can be added to `plan` or `apply`
actions using `varFiles` parameter:

```yaml
- task: terraform
  in:
    action: apply
    varFiles:
      - "path/to/my-vars.json"
      - "another/path/to/other/vars.json"
```

Paths must be relative to the current process' `${workDir}`.

<a name="output"/>

## Output Variables

There are two ways show [output](https://www.terraform.io/docs/configuration/outputs.html)
values can be saved - using the `output` action or by adding `saveOutput` to
the `apply` action parameters:

```yaml
- task: terraform
  in:
    action: output
    dir: "myTFStuff" # optional path to *.tf files
  out: result

# all output values will be saved as a ${result.data} variable
- log: "${result.data}" 
```

```yaml
- task: terraform
  in:
    action: apply
    saveOutput: true
    # the rest of the parameters are the same as with the regular `apply`
  out: result

- log: "${result.data}"
```

<a name="backends"/>

## State Backends

Concord uses its own [state
backend](https://www.terraform.io/docs/backends/index.html) by default, but any
of the standard Terraform state backends can be configured for use.

When using the Concord state backend, on by default, the state is stored in
Concord's internal [JSON store](../getting-started/json-store.html) using the
`tfState-${projectName}_${repositoryName}` template for the name. If you want to
use a custom name for storing the state, the name can be overridden using the
`stateId` parameter:

```yaml
- task: terraform
  in:
    action: plan
    stateId: "myInventory"
```

To completely remove the state, you can use the [JSON Store API](../api/json-store.html). 

Concord also supports the use of all [Terraform's backend types](https://www.terraform.io/docs/backends/types/index.html). To instruct the plugin to use the `s3` backend for storing state, use something like the following:

```yaml
- task: terraform
  in:
    backend:
      s3:
        bucket: "tfstate"
        key: "project"
        region: "us-west-2"
        encrypt: true
        dynamodb_table: "project-lock"
```

You can also disable the use of all state backends by specifying a backend of
`none`. This is effectively the same as the default command line behavior that
uses the filesystem to store state in the `terraform.tfstate`. To instruct the
plugin to use no backend for storing state, use something like the following:

```yaml
- task: terraform
  in:
    action: plan
    backend: none
```

<a name="remote"/>

## Terraform Enterprise / Cloud

[Remote](https://www.terraform.io/docs/backends/types/remote.html) is a special backend 
that runs jobs on Terraform Enterprise (TFE) or Terraform Cloud. Concord will 
create `.terraformrc` and `*.override.tfvars.json` configurations to access the 
module registry and trigger execution.

It is preferrable to configure a Terraform Version in the TFE / Cloud workspace
(workspace->settings->general->Terraform Version) and provide a matching `toolUrl` 
so concord and TFE use the same executable and bundled modules.

```yaml
- task: terraform
  in:
    action: apply
    toolUrl: https://releases.hashicorp.com/terraform/tfe-configured-version/terraform_tfe-version_linux_amd64.zip
    backend:
      remote:
        hostname: "app.terraform.io"
        organization:  "ExampleOrg"
        token: "Use_A_Crypto_Task_To_Protect_Token"
        workspaces: 
          name: "ExampleWorkspace"
```

<a name="git-modules"/>

## GIT Modules

Using [Generic GIT
repositories](https://www.terraform.io/docs/modules/sources.html#generic-git-repository)
as modules may require SSH key authentication. The plugin provides a couple ways
to configure the keys.

Using private key files directly:

```yaml
- task: terraform
  in:
    gitSsh:
      privateKeys:
        - "relative/path/to/a/private/key.file"
        - "another/private/key.file"
```

The path must be relative to the process `${workDir}`.

An alternative (and recommended) way is to use Concord [Secrets](../api/secret.html):

```yaml
- task: terraform
  in:
    gitSsh:
      secrets:
        - org: "myOrg" # optional
          secretName: "myKeyPairSecret"
          password: "myS3cr3t" # optional
```

Multiple private key files and Concord Secrets can be used simultaneously.

When running separate `plan` and `apply` actions, only the `plan` part requires
the key configuration.

## Terraform Version

The plugin tries to find a `terraform` binary using the following methods:
- looks for `${workDir}/.terraform/terraform` first;
- next, if `toolUrl` is provided, the plugin downloads the specified URL and
extracts it into `${workDir}/.terraform` directory. The `terraform` binary
should be in the top-level directory of the archive;
- looks for `terraform` in `$PATH` unless `ignoreLocalBinary: true` is
specified;
- downloads the binary's archive from the standard location
([releases.hashicorp.com](https://releases.hashicorp.com)). In this case,
the `toolVersion` parameter can be used.

## Executing inside a Docker container

Use the `dockerImage` option to execute the task's `terraform` CLI commands
within a Docker container. This option is useful for providing dependencies not
available in the default runtime environment such as cloud provider dependency
tools required by some terraform modules.

```yaml
- task: terraform
  in:
    dockerImage: 'my-custom/docker-image:1.2.34'
    # ... other options ...
```

The specified image must be compatible with
[Concord's Docker service](./docker.html#custom-images).

## Examples

- [minimal AWS example](https://github.com/walmartlabs/concord-plugins/tree/master/tasks/terraform/examples/minimal)
- [minimal Azure example](https://github.com/walmartlabs/concord-plugins/tree/master/tasks/terraform/examples/azure-minimal)
- [minimal GCP example](https://github.com/walmartlabs/concord-plugins/tree/master/tasks/terraform/examples/gcp-minimal)
- [approval](https://github.com/walmartlabs/concord-plugins/tree/master/tasks/terraform/examples/approval) - runs `plan`
and `apply` actions separately, uses an approval form to gate the changes;
- [output values](https://github.com/walmartlabs/concord-plugins/tree/master/tasks/terraform/examples/output) - how
to save `output` values and use them in the process.
