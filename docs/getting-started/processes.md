---
layout: wmt/docs
title:  Processes
side-navigation: wmt/docs-navigation.html
---

# Processes

A process is represents an execution of a Concord project using one of the
defined process definition and additional supplied resources.

  * [Structure of a Process](#structure)
  * [Project file](#project-file)
  * [Request data](#request-data)

<a name="structure"/>
## Structure of a Process

The server expects the following structure of a process working
directory:

- `concord.yml`: the [project file](#project-file) containing the main project
information and declarations;
- `_main.json`: the [data](#request-data) supplied in the request to execute
the process;
- `processes` and/or `flows`: directories containing `.yml` process and form
definitions;
- `profiles`: directory containing profiles;
- `lib`: directory for additional runtime dependencies.

Anything else will be copied as-is and will be available for a process. The
plugins can require other files to be present in a payload.

The same structure should be used when storing your project in a git repository.
Concord simply clones the repository into the process execution space.

<a name="project-file"/>
## Project File

A payload archive can contain the Concord file `concord.yml`. It uses the
[Concord DSL](./concord-dsl.html). This file will be loaded first and can
contain general configuration, process flow definitions, forms, profiles and
more.

<a name="request-data"/>
## Request Data

A payload's `_main.json` file is either supplied by users or created by the
server from a user's request data.

The request's JSON format:

```json
{
  "entryPoint": "...",
  "activeProfiles": ["myProfile", "..."],
  "otherCfgVar": 123,
  "arguments": {
    "myForm": {
      "name": "John"
    }
  }
}
```

Only `entryPoint` parameter is mandatory. The `activeProfiles` parameter is a
list of project file's profiles that will be used to start a process. If not
set, a `default` profile will be used.

