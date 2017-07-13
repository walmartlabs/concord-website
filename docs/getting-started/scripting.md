---
layout: wmt/docs
title:  Scripting support
---

# Scripting support

## Common features

### Using flow variables

For the most of the supported languages, flows variables can be
accessed directly:
```yaml
# .concord.yml
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

If a flow variable contains an illegal (for a chosen scripting
language) character, it can be accessed using a built-in `execution`
variable:

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

### Using tasks

Scripts can use all tasks available for flows:

```yaml
- script: js
  body: |
    var slack = tasks.get("slack");
    slack.call("C5NUWH9S5", "Hi there!");
```

## JavaScript

JavaScript support is built-in and doesn't require any external
dependencies. It is based on
[Nashorn](https://en.wikipedia.org/wiki/Nashorn_(JavaScript_engine)
engine.

Using an inline script:

```yaml
# .concord.yml
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
# .concord.yml
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

Groovy is another JSR-223 compatible engine that is fully-supported
in Concord. It requires an external dependency and the usage is
similar to [JavaScript](#javascript):

```yaml
# .concord.yml
variables:
  dependencies:
  - "http://nexus.prod.walmart.com/nexus/content/repositories/public/org/codehaus/groovy/groovy-all/2.4.10/groovy-all-2.4.10.jar"

flows:
  main:
  - script: groovy
    body: |
      def x = 2 * 3
      execution.setVariable("result", x)

  - log: ${result}
```

## Python

Python scripts can be executed using [Jython](http://www.jython.org/)
runtime.

```yaml
# .concord.yml
variables:
  dependencies:
  - "http://gec-nexus.prod.glb.prod.walmart.com/nexus/content/repositories/public/org/python/jython-standalone/2.7.0/jython-standalone-2.7.0.jar"

flows:
  main:
  - script: python
    body: |
      x = 2 * 3;
      execution.setVariable("result", x)
      
  - log: ${result}
```