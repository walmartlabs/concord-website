---
layout: wmt/docs
title:  Tasks
side-navigation: wmt/docs-navigation.html
description: Concord Tasks overview
---

# {{ page.title }}

Tasks are used to call Java code that implements functionality that is
too complex to express with the Concord DSL and EL in YAML directly.
Processes can include external tasks as dependencies, extending
the functionality available for Concord flows.

For example, the [Ansible](../plugins-v2/ansible.html) plugin provides
a way to execute an Ansible playbook as a flow step,
the [Docker](../plugins-v2/docker.html) plugin allows users to execute any
Docker image, etc.

In addition to the standard plugins, users can create their own tasks
leveraging (almost) any 3rd-party Java library or even wrapping existing
non-Java tools (e.g. Ansible).

Currently, Concord supports two different runtimes. The task usage and
development is different depending on the chosen runtime. See the runtime
specific pages for more details:

- [Runtime v1 tasks](../processes-v1/tasks.html)
- [Runtime v2 tasks](../processes-v2/tasks.html)
