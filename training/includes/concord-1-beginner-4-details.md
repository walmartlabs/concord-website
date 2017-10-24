# Project Details

> Diving Right In


## Concord DSL

Syntax used in `concord.yml` with top level nodes for:

- `configuration`:
- `flows:`
- `profiles:`
- `forms:`


## Configuration

Project global settings in `configuration`:

- `entryPoint:`
- `template:`
- `dependencies:`
- `arguments:`

Note:
- explain each a bit


## Dependencies

- JAR archives
- Added to execution classpath
- Used for scripting and tasks

```
configuration:
  dependencies:
    - "mvn://org.codehaus.groovy:groovy-all:2.4.12"
    - "https://repo1.maven.org/maven2/org/codehaus/groovy/groovy-all/2.4.11/groovy-all-2.4.11.jar"
```


## Arguments

Sets global default values for variables

```
configuration:
  arguments:
    name: "Example"
    coordinates:
      x: 10
      y: 5
      z: 0
flows:
  default:
    log: "Project name: ${name}"
    log: "Coordinats (x,y,z): ${coordinates.x}, ${coordinates.y}, ${coordinates.z}
```


## Flows

Defintion of steps of a workflow.

```
flows:
  default:
    - log: "foo"
    - log: "bar"
  test:
    - ...
```

Mutliple named flows!

Note:
- `default` used unless otherwise specified in invocation


## Steps

- Step type and parameters
- Expresssion

```
flows:
  default:
    - log: "My first log message"
    - ${1 + 2}
```

Note:
- syntax is step: parameter
- ${expression}


## Expression Language Details

- [Java Expression Language EL 3.0](https://github.com/javaee/el-spec):
- Within `${ }`
- Flow steps
- Argument values


## EL Examples

```yaml
flows:
  default:
    - ${myBean.someMethod()}
    - ${myBean.someMethod(myContextArg)}
    - ${1 + 2}
    - ${[1, 2, 3].stream().map(x -> x + 1).toList()}
```


## EL Long Form

Allows output capture and error handling.

```yaml
flows:
  default:
    - expr: ${myBean.someMethod()}
      out: myVar
      error:
        - log: "An error occured"
        - ...
```


## Calling Flows

Just use the flow name:

```
flows:
  default:
    - log: "Calling test next"
    - call: test
    - log: "test done, what next?"
  test:
    - log" "Starting test"
    - ...
```


## Variable Changes

- Process invocation parameter
- Values in profile
- `set` step


## Forms

- Provide web-based user interface for your flows.
- User input and guidance
- Served by Concord


## Forms Example

TBD


## Scripting

Any scripting languages supported by JSR-310?? 

- Groovy
- Jython
- JavaScript


## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

