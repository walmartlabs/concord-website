---
layout: wmt/docs
title:  Quickstart
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

If you have [installed your own Concord server](./installation.html) or have
access to a server already, you can set up your first simple Concord process
execution with a few simple steps:

- [Create Git Repository](#create-repository)
- [Add the Concord File](#add-concord-file)
- [Add a Deploy Key](#add-deploy-key)
- [Create Project in Concord](#create-project)
- [Execute Process](#execute-process)
- [Next Steps](#next-steps)

<a name="create-repository"/>
## Create Git Repository

Concord process definitions and their resources are best managed and source
controlled in a Git repository. Concord can automatically retrieve the contents
of the repository and create necessary resources and executions as defined in
the content.

Start with the following steps:

- Create the repository in your Git management sytem such as GitHub using the
  user interface
- Clone the repository to your local workstation

<a name="add-concord-file"/>
## Add the Concord File

As a next step, add the Concord file `concord.yml` in the root of the
repository. A minimalistic example file uses the automatically used `default` 
flow:

```yaml
flows:
  default:
    - log: "Hello Concord User"
```

The `default` flow in the example simply outputs a message to the process log.

<a name="add-deploy-key"/>
## Add a Deploy Key

In order to grant Concord access to the Git repository, you need to request a new
key from the Concord server using the
[REST API for secrets](../api/secret.html).

On a default installation you can perform this step with the default `admin`
user and it's authorization token:

```
curl -X POST -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" 'https://concord.example.com/api/v1/secret/keypair?name=exampleSecretKey'
```

On a typical production installation you can pass your username and be quoted for the password

```
curl -u username -X POST  'https://concord.example.com/api/v1/secret/keypair?name=exampleSecretKey'
```

Or supply the password as well:

```
curl -u username:password ...

The server provides a JSON-formatted response similar to:
 
```json
{
  "name" : "exampleSecretKey",
  "publicKey" : "ssh-rsa ABCXYZ... concord-server",
  "ok" : true
}
```

The value of the `publicKey` attribute has to be added as an authorized deploy
key for the git repository. In GitHub, for example, this can be done in the 
_Settings - Deploy keys_ section of the repository.

The value of the `name` attribute e.g. `exampleSecretKey` identifies the key for
usage in Concord.


<a name="create-project"/>
## Create Project in Concord

Now you can create a new project in the Concord Console.

- Log into the Concord Console user interface
- Select _Create new_ under _Projects_ in the navigation panel
- Provide a _Name_ for the project e.g. 'myproject'
- Press _Add repository_
- Provide a _Name_ for the repository e.g. 'myrepository'
- Use the SSH URL for the repository in the _URL_ field
- Select the _Secret_ created earlier using the name e.g. `exampleSecretKey`

Alternatively you can
[create a project with the REST API](../api/project.html#createproject).


<a name="execute-process"/>
## Execute a Process

Everything is ready to kick off an execution of a flow - a process. This is done
via the [Process REST API](../api/process.html) e.g. with

```
curl -H "Content-Type: application/json" -d '{}' \
     http://concord.example.com/api/v1/process/myproject:myrepository
```

The `instanceId` for the process is returned:

```json
{
  "instanceId" : "5b38d33a-463e-4598-97ca-913924343150",
  "ok" : true
}
```

The process can be inspected in the user interface:

- Click on _Queue_ under _Processess_ in the navigation
- Click on the _Instance ID_ value to see further details
- Press on the _View Log_ button to inspect the log
- Note how the log message `Hello Concord User` is visible

<a name="next-steps"/>
## Next Steps

Congratulations, your first process flow execution completed successfully!

You can now learn more about flows and perform tasks such as

- Add a forms to capture user input
- Use variables
- Group steps
- Add conditional expressions
- Call others flow
- Work with Ansible, Boo and other tasks
- Maybe even implement tasks

And much more. Have a look at all the documentation about the
[Concord DSL](./concord-dsl.html), [forms](./forms.html),
[scripting](./scripting.html) and other aspects to find out more!
