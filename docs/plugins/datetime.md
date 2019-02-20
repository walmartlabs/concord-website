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

## Date formats

### The current date as a java.util.Date object ...

```yaml
${datetime.current()} - current date as java.util.Date object
```

### The current date as a formatted string with a pattern ...

```yaml
${datetime.current('pattern')} - current date as formatted String with pattern
```

An example of this is as follows ...

```yaml
${datetime.current('dd.MM.yyy')}
```

### The current date formatted into a date/time string ...

```yaml
${datetime.format(datetime, 'pattern')} - formats a date into a date/time string
```

### Parse dateStr string to java.util.Date object ...

```yaml
${datetime.parse(dateStr, 'pattern')} - parse dateStr string to java.util.Date object
```
