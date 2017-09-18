---
layout: wmt/docs
title:  Scripting Support
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord flows can include scripting language snippets for execution. The
scripts run within the same JVM that is running Concord, and hence need to be
JSR-232 compliant scripting languages with a compliant runtime such as
[JavaScript](#javascript), [Groovy](#groovy) or [Python](#python).

Scripts have to be identified by language. They can be stored as external files
and invoked from the Concord YAML file or they can be inline in the file.
[Flow variables](#variables) and [Concord tasks](#tasks) can be accessed
from the scripts.

<a name="variables">
## Using Flow Variables

For most of the supported languages, flows variables can be accessed
directly:

```yaml
variables:
  entryPoint: main
  arguments:
    myVar: "world"

flows:
  main:
    - script: js
      body: |
        print("Hello, ", myVar)
```

If a flow variable contains an illegal character for a chosen scripting
language, it can be accessed using a built-in `execution` variable:

```yaml
- script: js
  body: |
    var x = execution.getVariable("an-illegal-name");
    print("We got", x);
```

To set a variable, you need to use `execution#setVariable` method:

```yaml
- script: js
  body: |
    execution.setVariable("myVar", "Hello!");
```

<a name="tasks">
## Using Concord Tasks

Scripts can retrieve and invoke all tasks available for flows by name:

```yaml
- script: js
  body: |
    var slack = tasks.get("slack");
    slack.call("C5NUWH9S5", "Hi there!");
```

## JavaScript

JavaScript support is built-in and doesn't require any external
dependencies. It is based on the
[Nashorn](https://en.wikipedia.org/wiki/Nashorn_(JavaScript_engine))
engine and requires the identifier `js`.

Using an inline script:

```yaml
flows:
  main:
  - script: js
    body: |
      function doSomething(i) {
        return i * 2;
      }

      execution.setVariable("result", doSomething(2));

  - log: ${result} # will output "4"
```

Using an external script file:

```yaml
flows:
  main:
  - script: test.js
  - log: ${result}
```

```javascript
// test.js
function doSomething(i) {
  return i * 2;
}

execution.setVariable("result", doSomething(2));
```

## Groovy

Groovy is another JSR-223 compatible engine that is fully-supported in
Concord. It requires the addition of a dependency to
[groovy-all](http://repo1.maven.org/maven2/org/codehaus/groovy/groovy-all/) and
the identifier `groovy`.


```yaml
variables:
  dependencies:
  - "https://repo1.maven.org/maven2/org/codehaus/groovy/groovy-all/2.4.12/groovy-all-2.4.12.jar"

flows:
  main:
  - script: groovy
    body: |
      def x = 2 * 3
      execution.setVariable("result", x)

  - log: ${result}
```

## Python

Python scripts can be executed using the [Jython](http://www.jython.org/)
runtime. It requires the addition of a dependency to
[jython-standalone](https://repo1.maven.org/maven2/org/python/jython-standalone)
located in the Central Repository or on another server and the identifier
`python`.


```yaml
variables:
  dependencies:
  - "https://repo1.maven.org/maven2/org/python/jython-standalone/2.7.1/jython-standalone-2.7.1.jar"

flows:
  main:
  - script: python
    body: |
      x = 2 * 3;
      execution.setVariable("result", x)

  - log: ${result}
```
