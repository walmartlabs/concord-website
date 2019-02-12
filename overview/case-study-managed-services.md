---
layout: wmt/project
title: Case Study - Managed Services
---

Numerous teams as Walmart use Concord to provide user an easy automated
provisioning for _Managed Services_. These Managed Service typically are a
complex, large scale deployment of a cloud application backing service such as
a relational database cluster, a NoSQL database clusters, file caching systems
and others.

The deployments are provided by expert teams that own the managed service and
take care of the complex management, scaling, HA/DR and other requirements for
the users. Users can simply focus on their application and treat the managed
service as a backing service.

Concord supports the full provisioning and deployment with a simple declaration
to support a number of tasks for the workflow execution:

- User requests managed service with a Concord form allowing for specific
  configuration
- Slack and email notification throughout the process
- JIRA ticket creation and updates
- Cloud application deployment created in OneOps PaaS or K8s deployment
- Application configuration is customized and applied
- Application deployed and started
- Metrics and more is all hooked up automatically by Concord
- Requestor updated with access details in JIRA ticket

The implementation of a Concord-based workflow has tremendously cut down on
error rates of the provisioning, greatly improved the user experience and
created a high demand for further managed services. In turn, this has led
development teams to use more backing services, allowing them to innovate faster
on their core application, leaving the backing service complexities to our
experts. 


