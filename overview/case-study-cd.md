---
layout: wmt/project
title: Case Study - Continuous Deployment
---

Concord is the tool of choice for most continuous deployment needs at Walmart.
Rich, powerful pipelines with numerous features are implemented by DevOps teams
across the organization.

A simple example flow could be a multi-stage zero downtime deployment of
a cloud application:

- Looper CI builds new release binary
- Concord flow is kicked off
- Deployment to QA environment
- Run of a number of tests and verifications on QA
- Slack and email notification to release approvers
- Concord form requires sign in and is used as final manual release gate
- Concord manages zero downtime deployment to production
  - Status changes of multiple clouds
  - Controlled release roll out to clouds
  - Automated smoke test verification
- Final success notifications

Numerous projects at Walmart use this with different deployment cloud platforms
including usage of OneOps, Ansible and k8s.
