---
layout: wmt/docs
title:  Docker support
---

# Docker support

Concord supports running 3rd-party docker images from flows:
```yaml
main:
 - docker: docker.prod.walmart.com/walmartlabs/concord-ansible
   cmd: ansible-playbook -h
```

Which is equivalent to running
```
docker run -i --rm \
-v /path/to/process/workDir:/workspace \
docker.prod.walmart.com/walmartlabs/concord-ansible \
ansible-playbook -h
```

The current process' working directory is mounted as `/workspace`.

The container is automatically removed when the called command is
complete.