---
layout: wmt/docs
title:  CLI
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord provides a command-line tool to simplify some of the common operations.

- [Installation](#installation)
- [Linting](./linting.html)
- [Running Flows Locally](./running-flows.html)

## Installation

Concord CLI requires Java 1.8+ available in `$PATH`. Installation is merely
a download-and-copy process:

```bash
curl -o ~/bin/concord https://repo.maven.apache.org/maven2/com/walmartlabs/concord/concord-cli/{{ site.concord_core_version }}/concord-cli-{{ site.concord_core_version }}-executable.jar
chmod +x ~/bin/concord
```
