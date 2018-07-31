---
layout: wmt/docs
title:  Tasks
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Tasks are used to call Java code that implments functionality that is
too complex to express with the Concord DSL and EL in YAML directly. They are
_plugins_ of Concord.

- [Using Tasks](#use-task)
- [Creating Tasks](#create-task)
- [Retry Tasks](#retry-task)

<a name="use-task"/>
## Using Tasks

Tasks allow you to call Java methods implemented in one of the of the project.
In order to be able to use a task a URL to the JAR containing the implementation
has to be added as a [dependency](./concord-dsl.html#dependencies). Typically
the JAR is published to a repository manager and a URL pointing to a the JAR in
a repository is used.

You can invoke a task via an expression or with the `task` step type.

Following are a number of examples:

```yaml
configuration:
  dependencies:
    - "http://repo.example.com/myConcordTask.jar"
flows:
  default:
    # invoking via usage of an expression and the call method
    - ${myTask.call("hello")}

    # calling a method with a single argument
    - myTask: hello

    # calling a method with a single argument
    # the value will be a result of expression evaluation
    - myTask: ${myMessage}

    # calling a method with two arguments
    # same as ${myTask.call("warn", "hello")}
    - myTask: ["warn", "hello"]

    # calling a method with a single argument
    # the value will be converted into Map<String, Object>
    - myTask: { "urgency": "high", message: "hello" }

    # multiline strings and string interpolation is also supported
    - myTask: |
        those line breaks will be
        preserved. Here will be a ${result} of EL evaluation.
```

If a task implements the `#execute(Context)` method, some additional
features like in/out variables mapping can be used:

```yaml
flows:
  default:
    # calling a task with in/out variables mapping
    - task: myTask
      in:
        taskVar: ${processVar}
        anotherTaskVar: "a literal value"
      out:
        processVar: ${taskVar}
      error:
        - log: something bad happened
```

<a name="create-task"/>
## Creating Tasks

Tasks must implement `com.walmartlabs.concord.sdk.Task` Java interface and
provides a `call(...)` method сan be called in a Concord flow.

It Task interface is provided by the `concord-sdk` module:

```xml
<dependency>
  <groupId>com.walmartlabs.concord</groupId>
  <artifactId>concord-sdk</artifactId>
  <version>0.50.0</version>
  <scope>provided</scope>
</dependency>
```

It is recommended to distribute tasks as _fat_ JARs, i.e. to include all
necessary dependencies in a single archive. However, some dependencies should be
excluded from the final JAR or marked as `provided` in the POM file:

- `com.fasterxml.jackson.core/*`
- `javax.inject/javax.inject`
- `org.slf4j/slf4j-api`

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

This task can be called using an [expression](./concord-dsl.html#expressions)
in short or long form:

```yaml
flows:
  default:
  - ${myTask.sayHello("world")}         # short form

  - expr: ${myTask.sum(1, 2)}           # full form
    out: mySum
    error:
    - log: "Wham! ${lastError.message}"
```

If a task implements `Task#execute` method, it can be started using
`task` step type:

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
  default:
  - task: myTask
    in:
      name: world
    out:
      success: callSuccess
    error:
      - log: "Something bad happened: ${lastError}"
```

This form allows use of `in` and `out` variables and error-handling blocks.

If a task contains method `call` with one or more arguments, it can
be called using the _short_ form:

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
  default:
  - myTask: ["user", "Concord"]   # using an inline YAML array

  - myTask:                       # using a regular YAML array
    - "user"
    - "Concord"
```

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
  default:
  - ${myTask.sayHello("Concord")}

configuration:
  arguments:
    greeting: "Hello, %s!"
```
<a name="retry-task"/>
## Retry Tasks

The `retry` attribute inside a task is use to restart the task automatically
in case of errors or failures. Users can define the number of times the task can
be re-tried and a delay for each `retry`. If not specified, the default value
for the delay is 5000 milliseconds .

Time parameter defines the number of times a task can be `retry` and delay is the
time span after which it `retry` in case of error.The delay time is always in
milliseconds.

For example the below section execute `myTask` using the provided `in` parameters.
In case of errors, the task `retry` 1 time with 1000 milliseconds delay and can
go up to 3 times with 3000 milliseconds delay. Additional parameters supplied
in the `in` block.

```yaml
- task: myTask
  in:
    ...
  retry:
    in:                                         
      ...additional parameters...
    times: 3
    delay: 3000                          
```

Original `in` and `retry` variables with the same values are overwritten.

In the example below the value of `someVar` is overwritten to 321 in the
`retry` block..


```yaml
- task: myTask
  in:
    someVar:
      nestedValue: 123
  retry:
    in:
      someVar:
        nestedValue: 321
        newValue: "hello"
    ...

  ```
