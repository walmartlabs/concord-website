---
layout: wmt/docs
title:  Repository
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

A repository is defined within a [project](./project.html) and defines a
connection to a git repository. The git repository contains the Concord file
that defines the workflows and more configuration using the
[Concord DSL](../processes-v1/index.html#dsl)

Repositories are configured within a project in the Concord Console and listed
in the _Repositories_ tab.

__Status__

A repository  can be enabled or disabled and this staus is displayed as an icon.

__Name__

The name of the repository in Concord.

__Repository URL__

The git URL to he repository.	

__Branch/Commit ID__

The branch name or he commit identifier of the git repository, defaults to
`master`.

__Path__

The relative path in the repository to the Concord YML file and other resources,
defaults to `/`. 

__Secret__

The secret used to access the repository.

__Actions__

The right side of the list displays an action button, which can be used to start
various operations.

- _Run_: Start [a process](../getting-started/processes.html) with a dedicated
  dialog to provide further details.
- _Validate_: Load and validate the `concord.yml` and related Concord files.
- _Triggers_: Show a list of configured [triggers](../triggers/index.html)
- _Refresh_: Reload the content of the repository.
- _Delete_: Delete the Concord repository definition.
