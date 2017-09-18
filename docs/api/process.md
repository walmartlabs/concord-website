---
layout: wmt/docs
title:  Process
side-navigation: wmt/docs-navigation.html
---

# Process

A process is an execution of a flow in repository of a project.

The REST API provides support for a number of operations:

- [Start a Process](#start-process)
  - [Existing Project](#existing-project)
  - [ZIP File](#zip-file)
  - [Browser](#browser)
- [Stop a Process](#stop-process)
- [Getting Status of a Process](#get-status-process)
- [Retrieve a Process Log](#retrieve-log)
- [Download an Attachment](#download-attachment)


<a name="start-process"/>
## Start a Process

The best approach to start a process is to execute a flow defined in the Concord
file in a repository of an [existing project](#existing-project).

Alternatively you can create a [ZIP file with the necessary content](#zip-file)
and submit it for execution.

For simple user interaction with flows that include forms, a process can also be
started [in a browser directly](#browser).

<a name="existing-project"/>
### Existing Project

* **Permissions** none
* **URI** `/api/v1/process/${entryPoint}?sync=${sync}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Parameters**
    The `${entryPoint}` parameter should be one the following formats:
    - `projectName:repositoryName`
    - `projectName:repositoryName:flowName`

    For example:`myProject:default:main`

    The `flowName` part can be ommitted if the project has the
    entry flow name set in the main project file or in a project
    template.

    The `${sync}` (`true/false`, default is `false`) parameter enables
    synchronous execution of a process. The request will block until
    the process is complete.
* **Body**
    ```json
    {
      "arguments": {
        "myVar": "..."
      }
    }
    ```
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "instanceId" : "0c8fdeca-5158-4781-ac58-97e34b9a70ee",
      "ok" : true
    }
    ```
    
An example of a invocation triggers the `main` flow in the `default` repository
of `myproject` without further parameters.

```
curl -H "Content-Type: application/json" -d '{}' https://concord.example.com/api/v1/process/myproject:default:main
```


<a name="zip-file"/>
### ZIP File

If no project exists in Concord, a ZIP file with flow definition and related
resources can be submitted to Concord for execution. Typically this is only
suggested for development processes and testing or one-off process executions.

Follow these steps:

Create a zip archive e.g. named `archive.zip` containing a single `.concord.yml`
file in the root of the archive. Specifically note that the file name starts
with a dot - `.concord.yml`:

```yaml
flows:
  main:
    - log: "Hello Concord User"
variables:
  entryPoint: "main"
```

The format is described in [Project file](./processes.html#project-file) document.

Now you can submit the archive directly to the Process REST endpoint of Concord
with the admin authorization or your user credentials as described in our
[getting started example](../getting-started/):

```
curl -H "Content-Type: application/octet-stream" \
     --data-binary @archive.zip http://concord.example.com/api/v1/process
```

The response should look like:

```json
{
  "instanceId" : "a5bcd5ae-c064-4e5e-ac0c-3c3d061e1f97",
  "ok" : true
}
```

Following is the full information about the API. It allows the user 
to starts a new process using the provided files as request data.
Accepts multiple additional files, which are put into the process'
working directory.

* **Permissions** none
* **URI** `/api/v1/process/${entryPoint}?sync=${sync}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: multipart/form-data`
* **Parameters**
    The `${entryPoint}` parameter should be one the following formats:
    - `projectName:repositoryName`
    - `projectName:repositoryName:flowName`

    The `${sync}` (`true/false`, default is `false`) parameter enables
    synchronous execution of a process. The request will block until
    the process is complete.
* **Body**
    Multipart binary data.

    The values will be interpreted depending on their name:
    - `archive` - ZIP archive, will be extracted into the process'
    working directory;
    - `request` - JSON file, will be used as the process' parameters;
    - any value of `application/octet-stream` type - will be copied
    as a file into the process' working directory;
    - any value of `text/plain` type - will be used as a process'
    parameter. Nested values can be specified using `.` as the
    delimiter.
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "instanceId" : "0c8fdeca-5158-4781-ac58-97e34b9a70ee",
      "ok" : true
    }
    ```
* **Example**
    ```
    curl -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" \
    -F archive=@src/payload.zip \
    -F myFile.txt=@src/myFile.txt \
    -F entryPoint=main \
    -F arguments.name=Concord \
    http://concord.example.com:8001/api/v1/process
    ```
<a name="browser"/>
### Browser

You can start a new process in Concord. This execution walks a user through all
process' forms and intermediate "pages".

* **Permissions** none
* **URI** `/api/service/process_portal/start?entryPoint=${entryPoint}&myParam=myVal...`
* **Method** `GET`
* **Headers** none
* **Parameters**
    The `${entryPoint}` parameter should be one the following formats:
    - `projectName:repositoryName`
    - `projectName:repositoryName:flowName`

    For example:`myProject:default:main`

    The `flowName` part can be ommitted if the project has the
    entry flow name set in the main project file or in a project
    template.

    Rest of the query parameters are used as process arguments.
* **Body**
    none
* **Success response**
    Redirects a user to a form or an intermediate page.


<a name="stop-process"/>
## Stop a Process

Forcefully stops the process.

* **Permissions** none
* **URI** `/api/v1/process/${instanceId}`
* **Method** `DELETE`
* **Headers** `Authorization`
* **Parameters**
    ID of a process: `${instanceId}`
* **Body**
    none
* **Success response**
    Empty body.

<a name="get-process-status"/>
## Getting the Status of a Process

Returns the current status of a process.

* **Permissions** none
* **URI** `/api/v1/process/${instanceId}`
* **Method** `GET`
* **Headers** `Authorization`
* **Parameters**
    ID of a process: `${instanceId}`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
    "instanceId" : "45beb7c7-6aa2-40e4-ba1d-488f78700ab7",
    "projectName" : "myProject2",
    "createdAt" : "2017-07-19T16:31:39.331+0000",
    "initiator" : "admin",
    "lastUpdatedAt" : "2017-07-19T16:31:40.493+0000",
    "status" : "FAILED"
    }
    ```

<a name="retrieve-log"/>
## Retrieve a Process Log

Downloads the log file of a process.

* **Permissions** none
* **URI** `/api/v1/process/${instanceId}/log`
* **Method** `GET`
* **Headers** `Authorization`, `Range`
* **Parameters**
    ID of a process: `${instanceId}`
* **Body**
    ```
    Content-Type: text/plain
    ```

    The log file.
* **Success response**
    Redirects a user to a form or an intermediate page.


<a name="download-attachment"/>
## Downloading an Attachment

Downloads a process' attachment.

* **Permissions** none
* **URI** `/api/v1/process/${instanceId}/attachment/${attachmentName}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/octet-stream`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/octet-stream
    ```

    ```
    ...data...
    ```
