---
layout: wmt/docs
title:  Gremlin Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord supports injecting faults into your system using the chaos engineering
tool [Gremlin](https://www.gremlin.com/docs/) with the `gremlin` task as part of
any flow.

The gremlin plugin offers below categories of attacks to inject faults into your
system:

- [Usage](#usage)
- [Resource](#resource)
  - [CPU](#cpu)
  - [Memory](#memory)
  - [Disk](#disk)
  - [IO](#io)
- [State](#state)
  - [Shutdown](#shutdown)
  - [Timetravel](#timeTravel)
  - [Processkiller](#processKiller)
- [Network](#network)
  - [Blackhole](#blackhole)
  - [Latency](#latency)
  - [Packetloss](#packetLoss)
  - [DNS](#dns)
- [Halt](#halt)

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:gremlin-task:{{ site.concord_plugins_version }}
```

## Resource

The attacks under the `Resource` category starve your application of critical
resources like CPU, memory, IO, or disk and reveal how your service behaves.

The `attacks` configuration under this category uses a number of input
parameters that are common for all operations:

- `action`: Required - The name of the operation to perform.
- `apiKey`: Required - Gremlin Api Key
- `length`: Required - The length of the attack (seconds)
- `useProxy`: When set to `true` uses the proxy `host` and `port` set in default vars. By default set to `false`
- `targetType`: Type of clients that should be targeted by the attack. Allowed
  values are `Random` and `Exact`. Default is set to `Exact`
- `targetList`: Required - when `targetType` is `Exact`. Input is a list eg.
  `["client1", "client2"]`
- `targetTags`: Required - when `targetType` is `Random`. Input is a `key/value`
  pair eg. `{ "myTagKey": "myTagValue" }`. More information about client tags
  can be found in the documentation for [advanced gremlin configuration](https://www.gremlin.com/docs/infrastructure-layer/advanced-configuration/)

<a name="cpu"/>

## CPU

The `cpu` action of the `gremlin` task can be used to generate high load for one
or more CPU cores. The following parameter is needed in addition to the general
parameters:

- `cores`: Required - The number of CPU cores to hog

```yaml
- task: gremlin
  in:
    action: cpu
    apiKey: myApiKey
    cores: 1
    length: 15
    targetType: Random
    targetTags: { "myTagKey": "myTagValue" }
```

<a name="memory"/>

## Memory

The `memory` action of the `gremlin` task can be used to allocate a specific
amount of RAM to be consumed. The following parameters are needed in addition to
the general parameters:

- `unitOption`: Required - Allowed values are `GB`, `MB`, `PERCENT`
- `memoryUnits`: Required - When `unitOption` is `GB` or `MB`. The number of MB/GBs to allocate
- `memoryPercent`: Required - When `unitOption` is `PERCENT`, e.g. 10 is 10%

Example with absolute value usage:

```yaml
- task: gremlin
  in:
    action: memory
    apiKey: myApiKey
    unitOption: MB
    memoryUnits: 100
    length: 15
    targetType: Random
    targetTags: { "myTagKey": "myTagValue" }
```

Example with percent usage:

```yaml
- task: gremlin
  in:
    action: memory
    apiKey: myApiKey
    unitOption: PERCENT
    memoryPercent: 10
    length: 15
    targetType: Exact
    targetList: ["client1", "client2"]
```

<a name="disk"/>

## Disk

The `disk` action of the `gremlin` task can be used to write files to disk to
fill it to a specific percentage. The following parameters are needed in
addition to the general parameters:

- `dir`: Required - The root directory to run the disk attack
- `workers`: The number of disk-write workers to execute. Default is 1
- `blockSize`: Number of Kilobytes (KB) that are read/written at a time. Default is 5
- `percent`: Required - Percent of Volume to fill (0-100)

```yaml
- task: gremlin
  in:
    action: disk
    apiKey: myApiKey
    length: 15
    dir: myDir
    workers: 3
    blockSize: 5
    percent: 25
    targetType: Exact
    targetList: ["client1", "client2"]
```

<a name="io"/>

## IO

The `io` action of the `gremlin` task can be used to put read/write pressure on
I/O devices such as hard disks. The following parameters are needed in addition
to the general parameters:

- `dir`: Required - The root directory to run the io attack
- `mode`: Required - The io mode to execute [r,w,rw]
- `workers`: The number of io workers to execute. Default is 1
- `blockSize`: Number of Kilobytes (KB) that are read/written at a time. Default is 5
- `blockCount`: The number of blocks read/written by workers. Default is 5

```yaml
- task: gremlin
  in:
    action: io
    apiKey: myApiKey
    length: 10
    dir: myDir
    workers: 3
    mode: rw
    blockSize: 6
    blockCount: 4
    targetType: Exact
    targetList: ["client1", "client2"]
```

## State

The attacks under the `State` category introduce chaos into your infrastructure,
so that you can observe how well your service handles it or fails.

The `attacks` configurations under this category use a number of input
parameters that are common for all operations:

- `action`: Required - The name of the operation to perform.
- `apiKey`: Required - Gremlin Api Key
- `length`: Required - The length of the attack (seconds)
- `useProxy`: When set to `true` uses the proxy `host` and `port` set in default vars. By default set to `false`
-  `targetType`: Type of clients that should be targeted by the attack. Allowed
   values are `Random` and `Exact`. Default is set to `Exact`
- `targetList`: Required - when `targetType` is `Exact`. Input is a list eg. `["client1", "client2"]`
- `targetTags`: Required - when `targetType` is `Random`. Input is a `key/value` pair eg. `{ "myTagKey": "myTagValue" }`.  More information about target tags
  can be found in the documentation for [advanced gremlin configuration](https://www.gremlin.com/docs/infrastructure-layer/advanced-configuration/)

<a name="shutdown"/>

## Shutdown

The `shutdown` action of the `gremlin` task can be used to reboot or halt the
host operating system to test how your system behaves when losing one or more
cluster machines. The following parameters are needed in addition to the general
parameters:

- `delay`: The number of minutes to delay before shutting down. Default is `1` minute
- `reboot`: Indicates the host should reboot after shutting down. Default `true`

```yaml
- task: gremlin
  in:
    action: shutdown
    apiKey: myApiKey
    delay: 1
    reboot: true
    targetType: Random
    targetTags: { "myTagKey": "myTagValue" }
```

<a name="timeTravel"/>

## Timetravel

The `timeTravel` action of the `gremlin` task can be used to change the host's
system time. This can be used to simulate adjusting to daylight saving time and
other time-related events. The following parameters are needed in addition to
the general parameters:

- `offset`: The offset (+/-) to the current time (seconds). Default `+5` seconds
- `ntp`: Disable NTP from correcting systemtime. Default value is set to `false`

```yaml
- task: gremlin
  in:
    action: timeTravel
    apiKey: myApiKey
    length: 15
    offset: -100
    targetType: Random
    targetTags: { "myTagKey": "myTagValue" }
```

<a name="processKiller"/>

## Processkiller

The `processKiller` action of the `gremlin` task can be used to kill a specified
process. This can be used to simulate application or dependency crashes. The
following parameters are needed in addition to the general parameters:

- `interval`: The number of seconds to delay before kills. Default 5 seconds
- `process`: Required - The process name to match (allows regex) or the process ID
- `group`: The group name or ID to match against (name matches only)
- `user`: The user name or ID to match against (name matches only)
- `newest`: If set the newest matching process will be killed (name matches
  only, cannot be used with -o). Default set to `false`
- `oldest`:If set the oldest matching process will be killed (name matches only,
  cannot be used with -n).  Default set to `false`
- `exact`: If set the match must be exact and not just a substring match (name
  matches only). Default to `false`
- `killChildren`: If set the processes children will also be killed. Default to
  `false`
- `fullMatch`: If set the processes name match will occur against the full
  command line string that the process was launched with. Default to `false`

```yaml
task: gremlin
in:
  action: processKiller
  apiKey: myApiKey
  length: 15
  interval: 10
  process: myProcess
  newest: true
  targetType: Random
  targetTags: { "myTagKey": "myTagValue" }
```

## Network

The attacks under the `Network` category allow you to see the impact of lost or
delayed traffic to your application. You can test how your service behaves when
you are unable to reach one of your dependencies, internal or external. You can
limit the impact to only the traffic you want to test by specifying ports,
hostnames, and IP addresses.

The `attacks` configuration under this category uses a number of input
parameters that are common for all operations:

- `action`: Required - The name of the operation to perform.
- `apiKey`: Required - Gremlin Api Key
- `length`: Required - The length of the attack (seconds)
- `useProxy`: When set to `true` uses the proxy `host` and `port` set in default vars. By default set to `false`
- `targetType`: Type of clients that should be targeted by the attack. Allowed
   values are `Random` and `Exact`. Default is set to `Exact`
- `targetList`: Required - when `targetType` is `Exact`. Input is a list eg.
  `["client1", "client2"]`
- `targetTags`: Required - when `targetType` is `Random`. Input is a `key/value`
  pair eg. `{ "myTagKey": "myTagValue" }`.  More information about client tags
  can be found in the documentation for [advanced gremlin
  configuration](https://www.gremlin.com/docs/infrastructure-layer/advanced-configuration/)

<a name="blackhole"/>

## Blackhole

The `blackhole` action of the `gremlin` task can be used drop all matching
network traffic. The following parameters are needed in addition to the general
parameters:

- `ipAddresses`: Required - Impact traffic to these IP addresses
- `device`: Impact traffic over this network interface
- `hostnames`: Only impact traffic to these hostnames. Whitelist a host with a
  leading `^`
- `egressPorts`: Only impact egress traffic to these destination ports. Ranges
  work too: `8080-8085`
- `ingressPorts`: Only impact ingress traffic on these incoming ports. Ranges
  work too: `8080-8085`
- `protocol`: Only impact traffic using this IP protocol. Allowed values are
  TCP, UDP, ICMP. Defaults to all protocols

```yaml
- task: gremlin
  in:
    action: blackhole
    apiKey: myApiKey
    length: 15
    ipAddresses: "ipAddress1, ipAddress2"
    device: "myDevice"
    hostnames: "host1.com, host2.com"
    egressPorts: "egPort1, egPort2"
    ingressPorts: "ingPort1, ingPort2" 
    protocol: UDP
    targetType: Exact
    targetList: ["client1", "client2"]
```

<a name="latency"/>

## Latency

The `latency` action of the `gremlin` task can be used to inject latency into
all matching egress network traffic. The following parameters are needed in
addition to the general parameters:

- `ipAddresses`: Required - Only impact egress traffic to these IP addresses
- `device`: Impact traffic over this network interface
- `hostnames`: Only impact traffic to these hostnames. Whitelist a host with a
  leading `^`
- `egressPorts`: Only impact egress traffic to these destination ports, ranges
  are supported with `8080-8085`
- `sourcePorts`: Only impact egress traffic from these source ports, ranges are
  suppored with `8080-8085`
- `delay`: How long to delay egress packets `millis`
- `protocol`: Only impact traffic using this IP protocol. Allowed values are
  TCP, UDP, ICMP Defaults to all protocols

```yaml
- task: gremlin
  in:
    action: latency
    apiKey: myApiKey
    length: 15
    ipAddresses: "ipAddress1, ipAddress2"
    device: "myDevice"
    hostnames: "host1.com, host2.com"
    egressPorts: "egPort1, egPort2"
    sourcePorts: "sPort1, sPort2" 
    delay: 100
    protocol: ICMP
    targetType: Exact
    targetList: ["client1", "client2"]
```

<a name="packetLoss"/>

## Packetloss

The `packetLoss` action of the `gremlin` task can be used to induce packet loss
into all matching egress network traffic. The following parameters are needed in
addition to the general parameters:

- `ipAddresses`: Required - Only impact traffic to these IP addresses
- `device`: Impact traffic over this network interface
- `hostnames`: Only impact traffic to these hostnames. Whitelist a host with a
  leading `^`
- `egressPorts`: Only impact egress traffic to these destination ports, ranges
  work too: `8080-8085`
- `sourcePorts`: Only impact egress traffic from these source ports, ranges work
  too: `8080-8085`
- `percent`: Percentage of packets to drop (10 is 10%). Default is set to `1`
- `corrupt`: Corrupt packets instead of simply dropping them. Default is set to
  `false`.
- `protocol`: Only impact traffic using this IP protocol. Allowed values are
  TCP, UDP, ICMP Defaults to all protocols

```yaml
- task: gremlin
  in:
    action: packetLoss
    apiKey: myApiKey
    length: 15
    ipAddresses: "ipAddress1, ipAddress2"
    device: "myDevice"
    hostnames: "host1.com, host2.com"
    egressPorts: "egPort1, egPort2"
    sourcePorts: "sPort1, sPort2" 
    percent: 5
    corrupt: true
    protocol: ICMP
    targetType: Exact
    targetList: ["client1", "client2"]
```

<a name="dns"/>

## DNS

The `dns` action of the `gremlin` task can be used to block access to DNS
servers. The following parameters are needed in addition to the general
parameters:

- `ipAddresses`: Required - Impact traffic to these IP addresses
- `device`: Impact traffic over this network interface
- `protocol`: Only impact traffic using this IP protocol. Allowed values are
  TCP, UDP. Defaults to all protocols

```yaml
- task: gremlin
  in:
    action: dns
    apiKey: myApiKey
    length: 15
    ipAddresses: "ipAddress1, ipAddress2"
    device: "myDevice"
    protocol: UDP
    targetType: Random
    targetTags: { "myTagKey": "myTagValue" }
```

## Halt

The `halt` action of the `gremlin` task can be used to idempotently halt the
specified active attack.

- `action`: Required `halt` - The name of the operation to perform.
- `apiKey`: Required - Gremlin API Key
- `attackGuid`: Required - GUID of the attack.

```yaml
- task: gremlin
  in:
    action: halt
    apiKey: myApiKey
    attackGuid: attackGuid
```

The performed `halt` action is identical to a manual usage of the
[Gremlin app](https://app.gremlin.com) with the `halt` button against the
specified active attack.