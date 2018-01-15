---
layout: wmt/docs
title:  Blue/green deployment
side-navigation: wmt/docs-navigation.html
---

# Blue/green deployment

Work in progress.

TODO:
- notifications;
- shared flows for Netscaler LB/Octavia SLB/HAProxy.

## Description

The template provides a flow to perform application deployment using
so called "blue/green" deployment scheme.

The flow assumes that:
- the environment split into two parts: "primary" and "secondary";
- there is a way to remove one of the environment parts from rotation
and bring it back;
- there is a smoke test to determine the status of a deployment and
it can be used for the part removed from rotation.

## Usage

Reference the template in a Concord file using the alias:
```yaml
configuration:
  template: "concord/bluegreen"
```
or directly:
```yaml
configuration:
  template: "https://repository.walmart.com/content/repositories/devtools/com/walmartlabs/concord/templates/concord-template-bluegreen/0.0.3/concord-template-bluegreen-0.0.3.jar"
```

Set the necessary process arguments:
```yaml
configuration:
  arguments:
    landscape:
      nextVersion: "b"
      prevVersion: "a"
      primary: ...
      secondary: ...
      all: ...
```

The `nextVersion` parameter is the version which is expected to be
deployed. The `prevVersion` parameter is the version which will be
used in the rollback procedure.

The `primary`, `secondary` and `all` keys must contain the
information necessary to provision the respected parts of the
environment.

Define the environment-specific flows:
```yaml
flows:
  deployApp:
  - log: "Using ${target}/${version}"

  updateLB:
  - log: "Using ${target}"

  smokeTest:
  - log: "Testing ${target}"
```

Those flows will be used to perform environment-specific actions:
- `deployApp` - deploy version `${version}` to `${target}` servers;
- `updateLB` - enable `${target}` servers the environment;
- `smokeTest` - perform a smoke test of `${target}` servers.

Use the `bluegreen` flow as an entry point:
```yaml
variables:
  entryPoint: "bluegreen"
```

Alternatively, it is possible to call the `bluegreen` flow from
another flow. Additional variables for the environment specific
flows can be provided this way:

```yaml
flows:
  default:
  - call: bluegreen
    in:
      myAdditionalDeployVar: "..."
```
