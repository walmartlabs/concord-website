---
layout: wmt/docs
title:  Docker Support
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

## Usage

Concord supports running docker images within a process flow.

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
docker run -i --rm \
-v /path/to/process/workDir:/workspace \
library/alpine \
echo 'Hello, world!'
```

**Note:** the `cmd` parameter is optional. If omitted, the image's `ENTRYPOINT`
is used.

The current process' working directory is mounted as `/workspace`.

**Note:** Your Dockerfile's `WORKDIR` is overwritten to `/workspace`. Depending
on your setup, you may need to change to a different working directory:

```yaml
- docker: library/alpine
  cmd: cd /usr/ && echo "I'm in $PWD"
``` 

The container is automatically removed when the called command is complete.

## Environment Variables

Additional environment variables can be specified using `env` parameter:

```yaml
flows:
  default:
  - docker: library/alpine
    cmd: echo $GREETING
    env:
      GREETING: "Hello, ${name}!"

configuration
  arguments:
    name: "concord"
```

Environment variables can contain expressions: all values will be
converted to strings.

## Docker options

### --add-host option

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

The `stdout` parameter can be used to capture the output of commands running
in the Docker container:

```yaml
- docker: library/alpine
  cmd: echo "Hello, Concord!"
  stdout: myOut

- log: "Got the greeting: ${myOut.contains('Hello')}"
```

In the example above the output (`stdout`) of the command running in the
container is not printed out into the log, but instead saved as `myOut`
variable.

## Capturing the Error

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
