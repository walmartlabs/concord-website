---
layout: wmt/docs
title:  Scripting Support
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord flows can include scripting language snippets for execution. The
scripts run within the same JVM that is running Concord, and hence need to
implement the Java Scripting API as defined by JSR-223. Language examples with a
compliant runtimes are
[JavaScript](#javascript), [Groovy](#groovy), [Python](#python), JRuby and many
others.

Script languages have to be identified by setting the language explicitly or can be
automatically identified based on the file extension used. They can be stored
as external files and invoked from the Concord YAML file or they can be inline
in the file.

[Flow variables](#variables), [Concord tasks](#tasks) and other Java methods can
be accessed from the scripts due to the usage of the Java Scripting API. The
script and your Concord processes essentially run within the same context on the
JVM.

- [Using Flow Variables](#variables)
- [Using Concord Tasks](#tasks)
- [Javascript](#javascript)
- [Groovy](#groovy)
- [Python](#python)
- [Ruby](#ruby)

<a name="variables">

## Using Flow Variables

For most of the supported languages, flows variables can be accessed
directly:

```yaml
configuration:
  arguments:
    myVar: "world"

flows:
  default:
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

> Note that not every data structure of supported scripting languages is
> directly compatible with the Concord runtime. The values exposed to the flow
> via `execution.setVariable` must be serializable in order to work correctly
> with forms or when the process suspends. Refer to the specific language
> section for more details.

<a name="tasks">

## Using Concord Tasks

Scripts can retrieve and invoke all tasks available for flows by name:

```yaml
- script: js
  body: |
    var slack = tasks.get("slack");
    slack.call("C5NUWH9S5", "Hi there!");
```

<a name="external-scripts">

## External scripts

Scripts can be automatically retrieved from an external server:

```yaml
- script: "http://localhost:8000/myScript.groovy"
```

The file extension in the URL must match the script engine's
supported extensions -- e.g. `.groovy` for the Groovy language, `.js`
for JavaScript, etc.

## JavaScript

JavaScript support is built-in and doesn't require any external
dependencies. It is based on the
[Nashorn](https://en.wikipedia.org/wiki/Nashorn_(JavaScript_engine))
engine and requires the identifier `js`.
[Nashorn](https://wiki.openjdk.java.net/display/Nashorn/Main) is based on
ECMAScript, adds
[numerous extensions](https://wiki.openjdk.java.net/display/Nashorn/Nashorn+extensions).
including e.g. a `print` command.

Using an inline script:

```yaml
flows:
  default:
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
  default:
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

### Compatibility

JavaScript objects must be converted to regular Java `Map` instances to be
compatible with the Concord runtime:

```yaml
flows:
  default:
    - script: js
      body: |
        var x = {a: 1};
        var HashMap = Java.type('java.util.HashMap');
        execution.setVariable('x', new HashMap(x));
    - log: "${x.a}"
```

Alternatively, a `HashMap` instance can be used directly in the JavaScript code.

## Groovy

Groovy is another compatible engine that is fully-supported in Concord. It
requires the addition of a dependency to
[groovy-all](http://repo1.maven.org/maven2/org/codehaus/groovy/groovy-all/) and
the identifier `groovy`. For versions 2.4.* and lower jar packaging is used in
projects, so the correct dependency is
e.g. `mvn://org.codehaus.groovy:groovy-all:2.4.12`. Versions 2.5.0 and higher
use pom packaging, which has to be added to the dependency declaration before
the version `mvn://org.codehaus.groovy:groovy-all:pom:2.5.2`.

```yaml
configuration:
  dependencies:
  - "mvn://org.codehaus.groovy:groovy-all:pom:2.5.2"
flows:
  default:
  - script: groovy
    body: |
      def x = 2 * 3
      execution.setVariable("result", x)
  - log: ${result}
```

The following example uses some standard Java APIs to create a date value in the
desired format.

```yaml
- script: groovy
   body: |
     def dateFormat = new java.text.SimpleDateFormat('yyyy-MM-dd')
     execution.setVariable("businessDate", dateFormat.format(new Date()))
- log: "Today is ${businessDate}"
```

### Compatibility

Groovy's `LazyMap` are not serializable and must be converted to regular Java
Maps:

```yaml
configuration:
  dependencies:
    - "mvn://org.codehaus.groovy:groovy-all:pom:2.5.2"

flows:
  default:
    - script: groovy
      body: |
        def x = new groovy.json.JsonSlurper().parseText('{"a": 123}') // produces a LazyMap instance
        execution.setVariable('x', new java.util.HashMap(x))
    - log: "${x.a}"
```

## Python

Python scripts can be executed using the [Jython](http://www.jython.org/)
runtime. It requires the addition of a dependency to
[jython-standalone](https://repo1.maven.org/maven2/org/python/jython-standalone)
located in the Central Repository or on another server and the identifier
`python`.

```yaml
configuration:
  dependencies:
  - "mvn://org.python:jython-standalone:2.7.1"

flows:
  default:
  - script: python
    body: |
      x = 2 * 3;
      execution.setVariable("result", x)

  - log: ${result}
```

Note that `pip` and 3rd-party modules with native dependencies are not
supported.

## Ruby

Ruby scripts can be executed using the [JRuby](http://jruby.org/)
runtime. It requires the addition of a dependency to
[jruby](https://repo1.maven.org/maven2/org/jruby/jruby)
located in the Central Repository or on another server and the identifier
`ruby`.

```yaml
configuration:
  dependencies:
  - "mvn://org.jruby:jruby:9.1.13.0"

flows:
  default:
  - script: ruby
    body: |
      puts "Hello!"
```
