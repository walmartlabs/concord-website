---
layout: wmt/docs
title:  Tasks
---

# Tasks

Tasks are used to call 3rd-party code or to perform something that
is too complex to express it with YAML directly. They are "plugins"
of Concord.

## Creating a new task

Tasks must implement `com.walmartlabs.concord.sdk.Task` Java
interface. It is provided by `concord-sdk` module: 
```xml
<dependency>
  <groupId>com.walmartlabs.concord</groupId>
  <artifactId>concord-sdk</artifactId>
  <version>${concord.version}</version>
</dependency>
```

It is recommended to distribute tasks as "fat" JARs, e.g. to include
all necessary dependencies in a single archive.

## Using expressions

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

See also [the description of expressions](./yaml.html#expressions).

## Using full form

If a task implements the `JavaDelegate` interface, it can be called
using `task` command:
```java
import com.walmartlabs.concord.sdk.Task;
import io.takari.bpm.api.JavaDelegate;
import javax.inject.Named;

@Named("myTask")
public class MyDelegateTask implements JavaDelegate, Task {
   
    @Override
    public void execute(ExecutionContext ctx) throws Exception {
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

## Using short form

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

## Injecting variables

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
