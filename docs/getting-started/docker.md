---
layout: wmt/docs
title:  Docker support
---

# Docker support

Concord supports running 3rd-party docker images:
```yaml
flows:
  main:
  - docker: docker.prod.walmart.com/walmartlabs/concord-base
    cmd: echo '${greeting}'
    
variables:
  entryPoint: main
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

The container is automatically removed when the called command is
complete.