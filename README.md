# Concord Website

This is the source code of the website for the workflow and integration server
Concord.

## Build

test3

```
gem install bundler
bundle install
./run.sh
```

More information about building and publishing can be found at the
[reference site](http://reference.walmart.com/docs/getting-started/)

## Project Information

- [![Build Status](https://ci.walmart.com/buildStatus/icon?job=SDE-Docs-Training/concord-site)](https://ci.walmart.com/job/SDE-Docs-Training/job/concord-site/)
- [Hygieia Quality Dashboard](https://hygieia.walmart.com/#/dashboard/5ab0594c867b6e4f858f0661)

## Project Quality

[Insights dashboard](http://hygieia.walmart.com/#/dashboard/59a4b22dad53334f88c9989f)

## Contribute

Feel free to submit pull requests at
https://gecgithub01.walmart.com/devtools/concord-website/

## Dashboards and Reference Links

- [Quality metrics on Hygieia](https://hygieia.walmart.com/#/dashboard/5ab0594c867b6e4f858f0661)
- [HTTP Monitors on Medusa](https://medusa.walmart.com/dashboard/db/concord-walmart-com-http-monitors?refresh=1m&orgId=1)
- [System Metrics on Medusa](https://medusa.walmart.com/dashboard/db/concord-walmart-com-system-metrics?orgId=1)
- [LB Metrics for DFW on Medusa](https://medusa.walmart.com/dashboard/db/concord-walmart-com-lb-metrics-dfw?orgId=1)
- [LB Metrics for CDC on Medusa](https://medusa.walmart.com/dashboard/db/concord-walmart-com-lb-metrics-cdc?orgId=1)
- [Resiliency config](http://resiliencydoc.walmart.com/)

## Issue Tracking Tickets

- [Sherpa Production Readiness Review JIRA](https://jira.walmart.com/browse/PLSHERPA-7870)
- [SRCR](https://egrc.wal-mart.com/archer/apps/ArcherApp/Home.aspx#workspace/118) - 41230268
- [Torbit Request](https://jira.walmart.com/browse/STRDTDT-871)

## Operational Support Information

### Escalation Path

1. [SDE open source team](https://sde.walmart.com/docs/open-source/index.html#contact)
2. [SDE docs and training team](https://sde.walmart.com/docs/docs-and-training/index.html)
3. [Sherpa team](https://sherpa.walmart.com/)


### Subject Matter Expert Contact List

1. Manfred Moser
2. Paul Drennan

### Architecture and Design

Static site hosted on OneOps using Apache httpd pack:

- [Devtools org](https://oneops.prod.walmart.com/devtools)
- [website assembly](https://oneops.prod.walmart.com/devtools/assemblies/website)
- [prod-concord environment](https://oneops.prod.walmart.com/devtools/assemblies/223129878/operations/environments/224594666#summary)

### General Troubleshooting

- Run site locally
- Run Looper build with deployment
- Redeploy artifact component
- Restart computes

### Critical Dependencies

None.

### How to do a Deployment

Kick off [Looper build](https://ci.walmart.com/job/SDE-Docs-Training/concord-site).

No roll back. Simply fix and roll forward.

### How to start, stop, and restart

Just restart apache server.

### How to Access Application Logs

See monitoring. Alternatively add ssh config to user component and redeploy and
then check via ssh to compute

### How to Replace Unhealthy Component in Oneops

Just redeploy or replace it.

### How to Take an Instance out of Traffic

Just shut it down and replace it.

### How to Take a Cloud or Data Center out of Traffic

Set cloud to secondary and commit and deploy.

For whole data center .. just do the same for all clouds in same datacenter.

### Switches to Disable or Enable Features

None.
