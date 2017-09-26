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
- on execution classpath
- scripting and tasks

```
configuration:
  dependencies:
    - "https://repo1.maven.org/maven2/org/codehaus/groovy/groovy-all/2.4.11/groovy-all-2.4.11.jar"
    - "https://repo1.maven.org/maven2/org/apache/commons/commons-lang3/3.6/commons-lang3-3.6.jar"
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
- default used unless otherwise specified in invocation


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

Using [Java Expression Language EL 3.0](https://github.com/javaee/el-spec):

- tbd




## Variable Changes

- Process invocation parameter
- Values in profile
- `set` step


## Forms

tbd 


## ??

not sure


## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

