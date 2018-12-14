---
layout: wmt/docs
title:  Docker Support
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

## Usage

Concord supports running docker images within a process flow.

```yaml
flows:
  default:
  - docker: docker.example.com/walmartlabs/concord-base
    cmd: echo '${greeting}'

configuration:
  arguments:
    greeting: "Hello, world!"
```

The above invocation is equivalent to running

```bash
docker run -i --rm \
-v /path/to/process/workDir:/workspace \
docker.example.com/walmartlabs/concord-base \
echo 'Hello, world!'
```

The current process' working directory is mounted as `/workspace`.

The container is automatically removed when the called command is complete.

## Environment Variables

Additional environment variables can be specified using `env` parameter:

```yaml
flows:
  default:
  - docker: docker.example.com/walmartlabs/concord-base
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
  - docker: docker.example.com/walmartlabs/concord-base
    cmd: echo '${greeting}'
    hosts:
      - foo:10.0.0.3
      - bar:10.7.3.21
      
configuration:
  arguments:
    greeting: "Hello, world!"            
```

## Custom Images

All images must provide a standard POSIX shell as `/bin/sh`.

## Limitations

Running containers as `root` user is not supported - all user containers are
executed using the `concord` user equivalent to a run command like `docker run
-u concord ... myImage`.  The user is created automatically with UID `456`.

As a result any operations in the docker container that require root access,
such as installing packages, is not supported on Concord. If required, ensure
that the relevant package installation and other tasks are performed as part of
your initial container image build and published to the registry from which
Concord retrieves the image.
