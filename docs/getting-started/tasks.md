---
layout: wmt/docs
title:  Tasks
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Tasks are used to call external Java code that implments functionality that is
too complex to express with the Concord DSL and EL in YAML directly. They are
_plugins_ of Concord.

- [Creating a New Task](#create-task)
- [Adding a Task](#add-task)
- [Using Expressions](#expressions)
- [Using Full Form](#full-form)
- [Using Short Form](#short-form)
- [Injecting Variables](#injecting-variables)

<a name="create-task"/>
## Creating a Task

Tasks must implement `com.walmartlabs.concord.sdk.Task` Java
interface. It is provided by the `concord-sdk` module:

```xml
<dependency>
  <groupId>com.walmartlabs.concord</groupId>
  <artifactId>concord-sdk</artifactId>
  <version>0.36.0</version>
  <scope>provided</scope>
</dependency>
```

It is recommended to distribute tasks as _fat_ JARs, i.e. to include
all necessary dependencies in a single archive. However, some
dependencies should be excluded from the final JAR or marked as
`provided` in the POM file:
- `com.fasterxml.jackson.core/*`
- `javax.inject/javax.inject`
- `org.slf4j/slf4j-api`

<a name="add-task"/>
## Adding a Task

In order to be able to use a task a URL to the JAR containing the implementation
has to be added as a [dependency](./processes.html#dependencies). Typically the
JAR is published to a repository manager.

<a name="expressions"/>
## Using Expressions

Here's an example of a simple task:
```java
import com.walmartlabs.concord.sdk.Task;
import javax.inject.Named;

@Named("myTask")
public class MyTask implements Task {

    public void sayHello(String name) {
        System.out.println("Hello, " + name + "!");
    }

    public int sum(int a, int b) {
        return a + b;
    }
}
```

This task can be called using an expression:

```yaml
flows:
  main:
  - ${myTask.sayHello("world")}         # short form

  - expr: ${myTask.sum(1, 2)}           # full form
    out: mySum
    error:
    - log: "Wham! ${lastError.message}"
```

See also [the description of expressions](./concord-dsl.html#expressions).

<a name="full-form"/>
## Using Full Form

If a task implements `Task#execute` method, it can be started using
`task` command:
```java
import com.walmartlabs.concord.sdk.Task;
import com.walmartlabs.concord.sdk.Context;
import javax.inject.Named;

@Named("myTask")
public class MyTask implements Task {

    @Override
    public void execute(Context ctx) throws Exception {
        System.out.println("Hello, " + ctx.getVariable("name"));
        ctx.setVariable("success", true);
    }
}
```

```yaml
flows:
  main:
  - task: myTask
    in:
      name: world
    out:
      success: callSuccess
    error:
      - log: "Something bad happened: ${lastError}"
```

This form allows use of IN and OUT variables and error-handling
blocks.

<a name="short-form"/>
## Using Short Form

If a task contains method `call` with one or more arguments, it can
be called using the "short" form:
```java
import com.walmartlabs.concord.common.Task;
import javax.inject.Named;

@Named("myTask")
public class MyTask implements Task {

    public void call(String name, String place) {
        System.out.println("Hello, " + name + ". Welcome to " + place);
    }
}
```

```yaml
flows:
  main:
  - myTask: ["user", "Concord"]   # using an inline YAML array

  - myTask:                       # using a regular YAML array
    - "user"
    - "Concord"
```

<a name="injecting-variables"/>
## Injecting Variables

Context variables can be automatically injected into task fields or
method arguments:

```java
import com.walmartlabs.concord.common.Task;
import com.walmartlabs.concord.common.InjectVariable;
import io.takari.bpm.api.ExecutionContext;
import javax.inject.Named;

@Named("myTask")
public class MyTask implements Task {

    @InjectVariable("execution")
    private ExecutionContext ctx;

    public void sayHello(@InjectVariable("greeting") String greeting, String name) {
        String s = String.format(greeting, name);
        System.out.println(s);

        ctx.setVariable("success", true);
    }
}
```

```yaml
flows:
  main:
  - ${myTask.sayHello("Concord")}

variables:
  arguments:
    greeting: "Hello, %s!"
```
