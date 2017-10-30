# Project Details

> Diving Right In


## Concord DSL

Syntax used in `concord.yml` with top level nodes for:

- `configuration`:
- `flows:`
- `profiles:`
- `forms:`

Note:
Explain each a bit .. more is coming below


## Configuration

Project global settings in `configuration`:

- `entryPoint:`
- `template:`
- `dependencies:`
- `arguments:`

Note:
- explain each a bit


## Entry Point

What flow to start with.

- Optional configuration
- `default` is the default


## Template

What other Concord DSL configuration to reuse.

- Advanced usage
- JAR archive of other project
- Powerful for reuse of
  - Complex flows
  - Scripts
  - Forms 
  - Profiles


## Dependencies

- JAR archives
- Added to execution classpath
- Used for scripting and tasks

```
configuration:
  dependencies:
    - "mvn://org.codehaus.groovy:groovy-all:2.4.12"
```

Note:
- Can also use normal hardcoded URL, but please don't!


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
```


## Arguments Continued

Variable usage:

```
flows:
  default:
    - log: "Project name: ${name}"
    - log: "Coordinates (x,y,z): ${coordinates.x}, ${coordinates.y}, ${coordinates.z}
```


## Flows

Sequence of steps define a workflow.

```
flows:
  default:
    - log: "foo"
    - log: "bar"
  test:
    - ...
```

Multiple named flows!

Note:
- `default` used unless otherwise specified in invocation


## Steps

- Step type and parameters
- Expression

```
flows:
  default:
    - log: "My first log message"
    - ${1 + 2}
```

Note:
- syntax is `step: parameter`
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
    - log: "Process running on ${System.getProperty("os.name")}"
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
    - test
    - log: "test done, what next?"
  test:
    - log" "Starting test"
    - ...
```


## Variable Changes

- Default values from `configuration - arguments`
- Process invocation parameter
- Values in profile
- `set` step


## Forms

- Provide web-based user interface for your flows
- User input and guidance
- Served by Concord


## Forms Definition

```
forms:
  userInformation:
  - firstName: { label: "First name:", type: "string" }
  - lastName: { label: "Last name:", type: "string" }
```


## Form Usage

Called in flows and create variables:

```
flows:
  default:
  - form: userInformation
  - log: "Hello, ${userInformation.firstName} ${userInformation.lastName}"
```


## More Form Power

- Different data types
- Restrictions on allowed input
- Data lookup from plugins
  - Locale for countries, ...
- Customizable look and feel
- Add JS, HTML, CSS and other resources
- Use as entry point for process start


## Scripting

Language needs to implement Java Scripting API, e.g.:

- Groovy
- Jython
- JavaScript


## Scripting Features

- Inline script
- External script file
- Read and write variable values
- Call tasks

Note:
more about tasks in a sec


## Scripting Example

```
flows:
  default:
  - script: js
    body: |
      print("Hello world!")
```


## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

