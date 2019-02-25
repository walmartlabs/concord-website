---
layout: wmt/docs
title:  Datetime Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `datetime` task provides methods to populate the current date at the 
time the flow runs.


The task is provided automatically by Concord and does not require any
external dependencies.

## Usage

The current date as a `java.util.Date` object:

```yaml
${datetime.current()} 
```

The current date as a formatted string with a pattern: 

```yaml
${datetime.current('pattern')} 
```

An example of this is as follows. Pattern syntax should follow [standard java date patterns](https://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html).

```yaml
${datetime.current('dd.MM.yyy')}
```

The current date formatted into a date/time string:

```yaml
${datetime.format(datetime, 'pattern')} 
```

Parse dateStr string to `java.util.Date` object:

```yaml
${datetime.parse(dateStr, 'pattern')} 
```
