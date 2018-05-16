---
layout: wmt/docs
title:  Automaton Plugin
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The plugin allows Concord to trigger Performance Tests to run on Automaton

## Pre-requsite

The project should be already on-boarded on Automaton.
Please refer to the Automaton Howto for more information

## Usage

1) On git hub, create a repo.  In the repo, create a `concord.yml` file:

 ```
 flows:
   default:
     - task: automaton
       in:
         projectName: Automaton_Demo_Json
         gitUrl: https://github.sample.com/Automaton_Demo_Json.git
         emailId: email@sample.com
         tenant: concord

 configuration:
   dependencies:
   - "mvn://com.walmartlabs.concord.plugins:automaton-task:0.40.0"
 ```

2) Add a Deploy Key: In order to grant Concord access to the Git repository via SSH, you need to create a new key in the Concord server

3) Create the Project in Concord

4) Execute a Process
