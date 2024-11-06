---
layout: wmt/docs
title:  Docker Support
side-navigation: wmt/docs-navigation.html
deprecated: true
description: Plugin for running Docker containers in a flow
---

# {{ page.title }}

Concord supports running [Docker](https://hub.docker.com/) images within a process flow.

- [Usage](#usage)
- [Environment Variables](#environment-variables)
- [Docker Options](#docker-options)
    - [Add Host Option](#add-host-option)
- [Capturing the Output](#capturing-the-output)
- [Custom Images](#custom-images)
- [Limitations](#limitations)

## Usage

Short syntax:

```yaml
flows:
  default:
    - docker: library/alpine
      cmd: echo '${greeting}'

configuration:
  arguments:
    greeting: "Hello, world!"
```

Using the `task` syntax:

```yaml
flows:
  default:
    - task: docker
      in:
        image: library/alpine
        cmd: echo '${greeting}'

configuration:
  arguments:
    greeting: "Hello, world!"
```

The above invocations are equivalent to running

```bash
docker pull library/alpine && \
docker run -i --rm \
-v /path/to/process/workDir:/workspace \
library/alpine \
echo 'Hello, world!'
```

Parameters:
- `image` - mandatory, string. Docker image to use;
- `cmd` - optional, string. Command to run. If not specified, the image's
`ENTRYPOINT` is used;
- `env` - optional, [environment variables](#environment-variables);
- `envFile` - optional. Path to the file containing
[environment variables](#environment-variables);
- `hosts` - optional. Additional [/etc/host entries](#add-host-option);
- `forcePull` - optional, boolean. If `true` Concord runs
`docker pull ${image}` before starting the container. Default is `true`;
- `debug` - optional, boolean. If `true` Concord prints out additional
information into the log (the command line, parameters, etc);
- `stdout` and `stderr` - optional, string. Name of variables to
[save the stdout and stderr](#capturing-the-output) of the container;
- `pullRetryCount` - optional, number. Number of retries if `docker pull`
fails. Default is `3`;
- `pullRetryInterval` - optional, number. Delay in milliseconds between
`docker pull` retries. Default is `10000`.

**Note:** The current process' working directory is mounted as `/workspace`.
Concord replaces the container's `WORKDIR` with `/workspace`. Depending
on your setup, you may need to change to a different working directory:

```yaml
- docker: library/alpine
  cmd: cd /usr/ && echo "I'm in $PWD"
``` 

To run multiple commands multiline YAML strings can be used:

```yaml
- docker: library/alpine
  cmd: |
    echo "First command"
    echo "Second command"
    echo "Third command"
```

Concord automatically removes the container when the command is complete.

## Environment Variables

Additional environment variables can be specified using `env` parameter:

```yaml
flows:
  default:
    - docker: library/alpine
      cmd: echo $GREETING
      env:
        GREETING: "Hello, ${name}!"

configuration:
  arguments:
    name: "concord"
```

Environment variables can contain expressions: all values will be
converted to strings.

A file containing environment variables can be used by specifying
the `envFile` parameter:

```yaml
flows:
  default:
    - docker: library/alpine
      cmd: echo $GREETING
      envFile: "myEnvFile"
```

The path must be relative to the process' working directory `${workDir}`.

It is an equivalent of running `docker run --env-file=myEnvFile`.

## Docker options

### Add Host Option

Additional `/etc/hosts` lines can be specified using `hosts` parameter:

```yaml
flows:
  default:
  - docker: library/alpine
    cmd: echo '${greeting}'
    hosts:
      - foo:10.0.0.3
      - bar:10.7.3.21

configuration:
  arguments:
    greeting: "Hello, world!"
```

## Capturing the Output

The `stdout` and `stderr` parameters can be used to capture the output of
commands running in the Docker container:

```yaml
- docker: library/alpine
  cmd: echo "Hello, Concord!"
  stdout: myOut

- log: "Got the greeting: ${myOut.contains('Hello')}"
```

In the example above the output (`stdout`) of the command running in the
container is not printed out into the log, but instead saved as `myOut`
variable.

The `stderr` parameter can be used to capture the errors of commands running
in the Docker container:

```yaml
- docker: library/alpine
  cmd: echo "Hello, ${name}" && (>&2 echo "STDERR WORKS")
  stderr: myErr

- log: "Errors: ${myErr}"
```

In the example above the errors (`stderr`) of the command running in the
container is not printed out into the log, but instead saved as `myErr`
variable.

## Custom Images

Currently there's only one requirement for custom Docker images: all images
must provide a standard POSIX shell as `/bin/sh`.

## Limitations

Running containers as `root` user is not supported - all user containers are
executed using the `concord` user equivalent to a run command like `docker run
-u concord ... myImage`.  The user is created automatically with UID `456`.

As a result any operations in the docker container that require root access,
such as installing packages, are not supported on Concord. If required, ensure
that the relevant package installation and other tasks are performed as part of
your initial container image build and published to the registry from which
Concord retrieves the image.
