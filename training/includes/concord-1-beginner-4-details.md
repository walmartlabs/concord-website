# Project Details

> Diving Right In

<!--- vertical -->

## Concord DSL

Syntax used in `concord.yml` with top level nodes for:

- `configuration:`
- `flows:`
- `forms:`
- `profiles:`
- `triggers:`

Note:
Explain each a bit .. more is coming below

<!--- vertical -->

## Configuration

Project global settings in `configuration`:

- `entryPoint:`
- `dependencies:`
- `arguments:`
- `template:`
- `processTimeout:`
- `debug:`


Note:
- explain in next slides

<!--- vertical -->

## Entry Point

What flow to start with.

- Optional configuration
- `default` is the default

<!--- vertical -->

## Dependencies

- JAR archives
- Added to execution classpath
- Used for scripting and tasks

```yaml
configuration:
  dependencies:
  - "mvn://org.codehaus.groovy:groovy-all:2.4.14"
  - "mvn://com.walmartlabs.concord.plugins.basic:smtp-tasks:1.6.0"
```

Note:
- Can also use normal hardcoded URL, but please don't!

<!--- vertical -->

## Arguments

Sets global default values for variables

```yaml
configuration:
  arguments:
    name: "Example"
    coordinates:
      x: 10
      y: 5
      z: 0
```

<!--- vertical -->

## Arguments Continued

Variable usage:

```yaml
flows:
  default:
  - log: "Project name: ${name}"
  - log: "Coordinates (x,y,z): ${coordinates.x}, ${coordinates.y}, ${coordinates.z}"
```

<!--- vertical -->

## Template

What other Concord DSL configuration to reuse.

- Advanced usage
- JAR archive of other project
- Powerful for reuse of
  - Complex flows
  - Scripts
  - Forms 
  - Profiles

<!--- vertical -->

## Process Timeout

Set overall allowed time for process execution.

```yaml
configuration:
  processTimeout: PT1H
```

Use [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) duration format.

<!--- vertical -->

## Debug

Logs information about dependency resolution.

```yaml
configuration:
  debug: true
```

<!--- vertical -->

## Flows

Sequence of steps define a workflow.

```yaml
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

<!--- vertical -->

## Steps

- Step type and parameters
- Expression

```yaml
flows:
  default:
  - log: "My first log message"
  - ${1 + 2}
```

Note:
- syntax is `step: parameter`
- ${expression}

<!--- vertical -->

## Expression Language Details

- [Java Expression Language EL 3.0](https://github.com/javaee/el-spec) Syntax
- Within `${ }`
- Use as flow steps
- Define Argument values

<!--- vertical -->

## EL Examples

```yaml
flows:
  default:
  - ${myBean.someMethod()}
  - ${myBean.someMethod(myContextArg)}
  - ${1 + 2}
  - ${[1, 2, 3].stream().map(x -> x + 1).toList()}
  - log: "Process running on ${System.getProperty('os.name')}"
```

<!--- vertical -->

## EL Long Form

Allows output capture and error handling.

```yaml
flows:
  default:
  - expr: ${myBean.someMethod()}
    out: myVar
    error:
      - log: "An error occurred"
```

<!--- vertical -->

## Calling Flows

Just use the flow name or `call`:

```yaml
flows:
  default:
  - log: "Calling test next"
  - test
  - call: anotherFlow
  
  test:
  - log: "Starting test"
```

<!--- vertical -->

## Loops

Use call with items:

```yaml
  default:
  - call: deployToClouds
    withItems:
    - name: cloud1
      fqdn: cloud1.myapp.example.com
    - name: cloud2
      fqdn: cloud2.myapp.example.com

  deployToClouds:
  - log: "Starting deployment to ${item.name}"
  - log: "Using fqdn ${item.fqdn}"
```

<!--- vertical -->

## Variable Changes

- Default values from `configuration - arguments`
- Process invocation parameter
- Values in profile
- `set` step

```yaml
- set:
    foo: 1
- log: "foo is ${foo}"
```

<!--- vertical -->

## If Then Else

```yaml
flows:
  default:
  - if: ${myVar > 0}
    then:
      - log: "it's clearly non-zero"
    else:
      - log: "zero or less"
```

<!--- vertical -->

## Switch Case

```yaml
flows:
  default:
  - switch: ${myVar}
      red:
        - log: "It's red!"
      green:
        - log: "It's definitely green"
      default:
        - log: "I don't know what it is"
```

<!--- vertical -->

## More Flow Control Structures

- `return` statement
- group of steps `::`
- equivalent to `try:`
- `error:` handling with
  - expressions `expr:`
  - flow invocations with `call:`
  - tasks `task:`
  - try blocks `try:`

<!--- vertical -->

## Standard Flows

- `default`
- `onCancel`
- `onFailure`
- `onTimeout`

<!--- vertical -->

## Forms

- Provide web-based user interface for your flows
- User input and guidance
- Served by Concord

<!--- vertical -->

## Forms Definition

```yaml
forms:
  survey:
  - book: { label: "What book are you currently reading?", type: "string" }
```

<!--- vertical -->

## Form Usage

Called in flows and creates variables:

```yaml
flows:
  default:
  - form: survey
  - log: "${initiator.displayName} is currently reading ${survey.book}."
```

- `form` suspends process until data is submitted
- `initiator` is one of default variable values in process

<!--- vertical -->

## More Form Power

- Different data types
- Restrictions on allowed input
- Data lookup from plugins
  - Locale for countries, ...
- Customizable look and feel
- Add JS, HTML, CSS and other resources
- Use as UI entry point for process start from browser link
- Each form is a step, so you can chain them to a wizard-style usage.

<!--- vertical -->

## Scripting

Language needs to implement Java Scripting API, e.g.:

- Groovy
- Jython
- JavaScript
- Ruby

Runs on JVM!

<!--- vertical -->

## Scripting Features

- Inline script
- External script file
- Read and write variable values
- Call tasks

Note:
more about tasks in a sec

<!--- vertical -->

## Scripting Example

```yaml
flows:
  default:
  - script: js
    body: |
      print("Hello world!")
      print("More script..")
```

Note:
- uses JavaScript impl for Java Scripting API which includes extensions like print
- show other examples from concord codebase examples folder
- multi line

<!--- vertical -->

## Groovy Example

Dependency:

```yaml
configuration:
  dependencies:
  - "mvn://org.codehaus.groovy:groovy-all:pom:2.5.2"
```
  
Inline script:

```yaml
- script: groovy
   body: |
     def dateFormat = new java.text.SimpleDateFormat('yyyy-MM-dd')
     execution.setVariable("businessDate", dateFormat.format(new Date()))
- log: "Today is ${businessDate}"
```


<!--- vertical -->

## Triggers

Kick off flow based on events.

- Scheduled
- GitHub
- Generic
- OneOps

<!--- vertical -->

## Trigger Example

```yaml
flows:
  onDeployment:
  - log: "OneOps has completed a deployment: ${event}"
  
triggers:
- oneops:
    org: "myOrganization"
    asm: "myAssembly"
    env: "myEnvironment"
    platform: "myPlatform"
    type: "deployment"
    deploymentState: "complete"
    entryPoint: onDeployment
```

<!--- vertical -->

## Profile Example

```yaml
flows:
  default:
  - log: "${foo}"

configuration
  arguments:
    foo: "bar"

profiles:
  myProfile:
    configuration:
      arguments:
        foo: "bazz"
```

<!--- vertical -->

## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

