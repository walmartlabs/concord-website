---
layout: wmt/docs
title:  Automaton Plugin
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Automaton Performance Tests can be triggered to run through Concord

## Pre-requsite

The project should be already on-boarded on Automaton.  Please refer to the [Howto](http://testing.walmart.com/performance/backend/backend_howto) for more information

## Usage

1) On the git hub create a repo.  On it, create a ```concord.yml``` file: [https://gecgithub01.walmart.com/pkumaar/Concord_Automaton_Demo/blob/master/concord.yml](https://gecgithub01.walmart.com/pkumaar/Concord_Automaton_Demo/blob/master/concord.yml)

 ```
 flows:
   default:
     - task: automaton
       in:
         projectName: Automaton_Demo_Json
         gitUrl: https://gecgithub01.walmart.com/pkumaar/Automaton_Demo_Json.git
         emailId: pkumaar@walmart.com
         tenant: concord

 configuration:
   dependencies:
   - "mvn://com.walmartlabs.concord.plugins:automaton-task:0.40.0"
 ```

 **Note:** Instructions on how to complete the next steps can be found in the Concord Quickstart page [Quickstart page](http://concord.walmart.com/docs/getting-started/quickstart.html)

2) Add a Deploy Key: In order to grant Concord access to the Git repository via SSH, you need to create a new key on the Concord server

3) Create Project in Concord

4) Execute a Process



**Note:**
Don't use Automaton's **backend services** for running any Production Stress Test
It's for server side Performance/Load/Stress Testing tool so it won't download/make any client side calls, like Images, JS, and 3rd Party calls

<a href="http://automaton.walmart.com"><img src="/assets/img/automaton.png" class="img-responsive center" height="42" width="200" align="right"/></a>
