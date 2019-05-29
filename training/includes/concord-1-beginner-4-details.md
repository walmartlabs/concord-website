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
- Explain each a bit .. more is coming below
- BRIEFLY give a one-liner
- Flows we've already worked on a bit
- Configuration is, well, configurations
- Forms provide a UI form for users to fill out information
- Profiles define configuration sets (dev profiles can run with <x> configs, qa profiles run with <y>, etc)
- Triggers are reactions Concord takes when certain things happen (in Github, OneOps, or other places)

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
- Just read through these - don't explain them here, we go in depth next slides

<!--- vertical -->

## Entry Point

What flow to start with.

- Optional configuration
- `default` is the default

Note:
- Open concord.yml, add `configuration:` as a top-level element
- Note location doesn't matter, but keep it clean - you don't know who will have to troubleshoot later
- Indent `entryPoint: main` in the line below configuration. 
- main is a flow
- Make a `main` flow with a log step (different message than default flow's log step)
- Commit and push
- Open in console, run, and look at the new message in the log.
- Note that the other flow didn't run; when we define an entryPoint, that flow runs, not default unless it's explicitly called

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
- This element adds java files - jar archives - to the execution classpath.
- Classpath means available in the runtime.
- It's typical to add scripting language support or tasks available via plugins.
- Open up concord console, to a log and show concord loads some by default
- Copy the groovy dependency from the slide and add to the concord.yml file
- Note; this link isn't a jar... the way Maven works, this is a set of coordinates
that identify groovy-all jar in v. 2.14.
- Syntax is `mvn://<org>:<name>:<version>`
- Go to repository.walmart.com -> repositories -> click on a 'public' link,
then type '/org/codehaus/groovy' in the address bar, and dotwalk to the jar file,
drawing parallels to link in yml.
- Note other dependencies for concord can be found in https://repository.walmart.com/content/groups/public/com/walmartlabs/concord/plugins/
- Go find the smtp jar (in basic/smtp-tasks/1.6.0/jar), and compare that link to the one in slide
- Update the concord.yml to include the smtp dependency, git add, commit, push, and run in concord console.

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

Note:
- Explain variables can be explicitly defined as key value pairs or can be calculated.
- Copy arguments from slide and put in concord.yml
- Note this just DEFINES the variables - we're not using them yet.

<!--- vertical -->

## Arguments Continued

Variable usage:

```yaml
flows:
  default:
  - log: "Project name: ${name}"
  - log: "Coordinates (x,y,z): ${coordinates.x}, ${coordinates.y}, ${coordinates.z}"
```

Note:
- Dollar/brace syntax. If you have to step into the properties of a defined object,
use 'dot' syntax/
- Add to DEFAULT flow. Leave off last double-quote as a syntax demonstration
- Run in console, and note it doesn't show in the log. 
- This is because it's in the default flow, and we have an entryPoint set to main.
- Comment out entryPoint line in concord.yml, save, add, commit, and demo in the console.

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

Note:
- This is an advanced topic - just want to say this is an option.
- "Steal shamelessly" applies to Concord, too.

<!--- vertical -->

## Process Timeout

Set overall allowed time for process execution.

```yaml
configuration:
  processTimeout: PT1H
```

Use [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) duration format.

Note:
- This sets how long something should try to run before timing out.
- The example is short for 'period of time of 1 hour'

<!--- vertical -->

## Debug

Logs information about dependency resolution.

```yaml
configuration:
  debug: true
```

Note:
- This ONLY logs additional info about dependency resolutions.
- Good for classpath and old version errors.

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
- Can have multiple - this is like a checklist for Concord to follow

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
- Usually either a step-type + parameters (log = step type, msg = parameters), or an expression,
like ${1 + 2}
- vi concord.yml, add expression from slide, save, push, demo.
- It won't do anything - we didn't tell Concord to do anything with it, just calculate it.
- Concord displays (or doesn't display) 'garbage in, garbage out' very efficiently

<!--- vertical -->

## Expression Language Details

- [Java Expression Language EL 3.0](https://github.com/javaee/el-spec) Syntax
- Within `${ }`
- Use as flow steps
- Define Argument values

Note:
- vi concord.yml, replace the x coord with an expression, add and demo

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

Note:
- Allows you to invoke w/e is in your classpath

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

Note: 
- Adds another level of power. Not only can you invoke something, but also you can
capture what it produces.
- expr step says 'do this thing'
- out step says 'put the output here' - in this case, myVar
- error step says 'if there's an error, do these things'

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

Note:
- You can call flows from other flows by just adding the name as a step
OR with `- call: <step>` syntax. Show an example, don't demo
- (https://gecgithub01.walmart.com/strati/training-admin/blob/master/concord.yml)
- Huge selling points here: cleanliness and reusability

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

Note:
- Slide is a great example of how to use a loop,
- call the flow 'deployToClouds' for the items in withItems.
- Reverse syntax from shell-scripting, where it's 'for i in <list>, do <action>'

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

Note:
- Can define in arguments, can pass parameters in at process evocation.
- Can set them in a profile, so when that profile is used, specific vars are
set appropriately, or can set using a `set` step in a nested form - key, and value

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

Note:
- When you need to introduce logic, add `if` step with expression.
- Whichever one is executed - 'if' or 'then', you follow the steps in that
step. 
- Can be used to call different flows if something fails or succeeds!

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

Note:
- Good practical example; dropdown that you select your environment you're deploying to.
- if it's env A, deploy with OneOps.
- if it's env B, deploy with Ansible, etc

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

Note:
- LOTS of options
- return exists out of where you're at
- `::` groups sections like `try`, but without error handling.
- `error` is supported by: expressions, calls to call other flows,
- tasks (which we'll go over later), and `try` blocks.
- Can take these errors and log them or share in slack or w/e

<!--- vertical -->

## Standard Flows

- `default`
- `onCancel`
- `onFailure`
- `onTimeout`

Note:
- We've seen default - required unless you have a specified entryPoint configured
- onCancel - runs if a process is cancelled
- onFailure - runs if a failure occurs
- onTimeout - runs if process times out (after setting configuration processTimeout)

<!--- vertical -->

## Forms

- Provide web-based user interface for your flows
- User input and guidance
- Served by Concord

Note:
- Forms provide a UI for users to provide input you can use. You don't have
to host the form or anything - Concord does it for you.

<!--- vertical -->

## Forms Definition

```yaml
forms:
  survey:
  - book: { label: "What book are you currently reading?", type: "string" }
```

Note:
- Copy block, paste as a top level element (at the end to demo location
doesn't matter)
- Explain the form name, then indentation after contains the variable the input will
be stored as, the label, and then what type of variable)

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

Note:
- We made it, now we need to use it, and that's done with the form sttep.
- Once data from the form is captured and can be used as an expression - <form>.<field>
- Copy form and log steps from slide, put into default, commit and demo
- Open process log and show suspension
- Go back to process page, show suspension
- Can open the form by clicking on form name in 'Required Actions' section or click on 'Wizard' button.
- Open form, fill out, view log, and talk about run/suspend (flow will pause/be suspended until form is completed)

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

Note:
- Just read the points on the slide. 
- Good example of more complex form is https://gecgithub01.walmart.com/strati/training-admin/blob/master/concord.yml

<!--- vertical -->

## Scripting

Language needs to implement Java Scripting API, e.g.:

- Groovy
- Jython
- JavaScript
- Ruby

Runs on JVM!

Note:
- Scripts need to implement Java Scripting API. Read points

<!--- vertical -->

## Scripting Features

- Inline script
- External script file
- Read and write variable values
- Call tasks

Note:
- more about tasks in a sec, otherwise just read

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
- Copy script block from slide, comment out the form, add in `default` flow
- Note: specify language. Concord won't guess.
- '|' (pipe) after 'body' denotes a multi-line segment
- Save and demo - note it's a system write, not a log
- Show where to find examples in GitHub (https://gecgithub01.walmart.com/devtools/concord/tree/master/examples)

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

Note:
- In https://gecgithub01.walmart.com/devtools/concord/tree/master/examples:
- groovy is a good basic example
- groovy_rest adds dependencies and imports
- python_script demos an external script file
- Also good to review concord.walmart.com/docs/getting-started/scripting.html

<!--- vertical -->

## Triggers

Kick off flow based on events.

- Scheduled
- GitHub
- Generic
- OneOps

Note:
- Kick off events from external flows.
- Concord watches for <x> to happen in GitHub, then when it does, Concord will do <y>
- These are reactions

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

Note:
- Go through line by line, pointing out each line narrows down what we're looking for
- GitHub triggers only for org repos, not personal repos
- For OneOps triggers, open a support ticket

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

Note:
- Important to note profile settings will override global settings.
- Common for different deployment environments

<!--- vertical -->

## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

