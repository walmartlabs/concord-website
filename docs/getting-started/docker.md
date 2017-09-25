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
  - docker: docker.prod.walmart.com/walmartlabs/concord-base
    cmd: echo '${greeting}'

configuration:
  arguments:
    greeting: "Hello, world!"
```

Which is equivalent to running
```
docker run -i --rm \
-v /path/to/process/workDir:/workspace \
docker.prod.walmart.com/walmartlabs/concord-base \
echo 'Hello, world!'
```

The current process' working directory is mounted as `/workspace`.

The container is automatically removed when the called command is complete.

## Environment Variables

Additional environment variables can be specified using `env` parameter:

```yaml
flows:
  default:
  - docker: docker.prod.walmart.com/walmartlabs/concord-base
    cmd: echo $GREETING
    env:
      GREETING: "Hello, ${name}!"

configuration
  arguments:
    name: "concord"
```

Environment variables can contain expressions: all values will be
converted to strings.

## Custom Images

All images must provide a standard POSIX shell as `/bin/sh`.
