---
layout: wmt/docs
title:  Automaton Plugin
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `automaton` task allows Concord to start performance test runs on Automaton.

## Usage

To be able to use the `automaton` task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:automaton-task:{{ site.concord_plugins_walmart_version }}
```

Once your project is configured on Automaton, you can trigger
a test run with the task in any flow.

```yaml
flows:
   default:
   - task: automaton
     in:
       projectName: myDemoProject
       gitUrl: https://github.example.com/automaton_demo.git
       emailId: email@example.com
       tenant: myAutomatonTenant
```

The task starts the performance run on Automaton asynchronously and proceeds
with the next flow steps immediately.

Available parameters are:

- `projectName`: name of the project on the Automaton server
- `gitUrl`: HTTPS git URL for the repository containing the performance test
definition
- `emailId`: email address to receive the performance test results
- `tenant`: the tenant organization of the project on the Automaton server

The Automaton server connections is configured globally.