---
layout: wmt/docs
title:  Generic Triggers
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

- [Version 1](#generic-v1)
- [Version 2](#generic-v2)
- [Migration](#generic-migration)

You can configure generic triggers to respond to events that are configured to
submit data to the Concord REST API.

Currently Concord supports two different implementations of generic triggers:
`version: 1` and `version: 2`.

<a name="generic-v2"/>

## Version 2

For example, if you submit a JSON document to the API at `/api/v1/events/example`,
an `example` event is triggered. You can capture this event and trigger a flow by
creating a trigger configuration using the same `example` name:

```yaml
triggers:
- example:
    version: 2
    entryPoint: exampleFLow
    conditions:
      aField: "aValue"
```

Every incoming `example` event with a JSON field `aField` containing `aValue` kicks
of a process of the `exampleFlow`.

The generic event end-point provides a simple way of integrating third-party 
systems with Concord. Simply modify or extend the external system to send
events to the Concord API and define the flow in Concord to proceed with the
next steps.

**Note:** standard [limitations](./index.html#limitations) apply.

<a name="generic-v1"/>

## Version 1

```yaml
- example:
    version: 1 # optional, depends on the environment's defaults 
    aField: "aValue"
    entryPoint: exampleFLow
```

Check out the [full example]({{site.concord_source}}tree/master/examples/generic_triggers)
for more details.

**Note:** standard [limitations](./index.html#limitations) apply.

<a name="generic-migration"/>

## Migrating Generic trigger from v1 to v2

In `version: 2`, the trigger conditions are moved into a `conditions` field:

```yaml
# v1
- example:    
    aField: "aValue"
    entryPoint: exampleFLow

# v2
- example:
    version: 2
    conditions:
      aField: "aValue"
    entryPoint: exampleFLow
```
