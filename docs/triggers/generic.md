---
layout: wmt/docs
title:  Generic Triggers
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

You can configure generic triggers to respond to events that are configured to
submit data to the Concord REST API.

For example, if you submit a JSON document to the API at `/api/v1/events/example`,
an `example` event is triggered. You can capture this event and trigger a flow by
creating a trigger configuration using the same `example` name:

```yaml
triggers:
- example:
    project: "myProject"
    repository: "myRepository"
    entryPoint: exampleFLow
```

Every incoming `example` event kicks of a process of the `exampleFlow` from
`myRepository` in `myProject`.

The generic event end-point provides a simple way of integrating third-party 
systems with Concord. Simply modify or extend the external system to send
events to the Concord API and define the flow in Concord to proceed with the
next steps.

Check out the
[full example](
{{site.concord_source}}tree/master/examples/generic_triggers)
for more details.
