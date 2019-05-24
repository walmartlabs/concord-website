---
layout: wmt/docs
title:  Process
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

A process is an execution of a flow in repository of a project.

The REST API provides support for a number of operations:

- [Start a Process](#start)
  - [Form data](#form-data)
  - [ZIP File](#zip-file)
  - [Browser](#browser)
- [Stop a Process](#stop)
- [Getting Status of a Process](#status)
- [Retrieve a Process Log](#log)
- [Download an Attachment](#download-attachment)
- [List Processes](#list)
- [Process Events](#process-events)
  - [List events](#list-events)

<a name="start"/>

## Start a Process

The best approach to start a process is to execute a flow defined in the Concord
file in a repository of an existing project.

Alternatively you can create a [ZIP file with the necessary content](#zip-file)
and submit it for execution.

For simple user interaction with flows that include forms, a process can also be
started [in a browser directly](#browser).

Following is the full information about the API. It allows the user 
to starts a new process using the provided files as request data.
Accepts multiple additional files, which are put into the process'
working directory.

* **URI** `/api/v1/process`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: multipart/form-data`
* **Body**
    Multipart binary data.

    The values will be interpreted depending on their name:
    - `activeProfiles` - a comma-separated list of profiles to use;
    - `archive` - ZIP archive, will be extracted into the process'
    working directory;
    - `request` - JSON file, will be used as the process' parameters;
    - any value of `application/octet-stream` type - will be copied
    as a file into the process' working directory;
    - `orgId` or `org` - ID or name of the organization which
    "owns" the process;
    - `projectId` or `project` - ID or name of the project
    which will be used to run the process;
    - `repoId` or `repo` - ID or name of the repository which
    will be used to run the process;
    - `repoBranchOrTag` - overrides the configured branch or tag name
    of the project's repository;
    - `repoCommitId` - overrides the configured GIT commit ID of the
    project's repository;
    - `entryPoint` - name of the starting flow;
    - `sync` - enables synchronous execution of a process. The
    request will block until the process is complete;
    - `out` - list of comma-separated names of variables that will be
    returned after the process finishes. Works only with `sync`;
    - `startAt` - ISO-8601 date-time value. If specified, the process
    will be scheduled to run on the specified date and time. Can't be
    in the past. Explicitly specifying the timezone is recommended;
    - any other value of `text/plain` type - will be used as a process'
    parameter. Nested values can be specified using `.` as the
    delimiter;
    - any other value will be saved as a file in the process' working
    directory.
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
    -F org=MyOrg \
    -F project=MyProject \
    -F repo=MyRepo \
    -F archive=@src/payload.zip \
    -F myFile.txt=@src/myFile.txt \
    -F entryPoint=main \
    -F activeProfiles=myProfile \
    -F arguments.name=Concord \
    http://concord.example.com:8001/api/v1/process
    ```

An example of a invocation triggers the `default` flow in the `default` repository
of `myproject` in the `myorg` organization without further parameters.

```
curl -F org=myorg -F project=myproject -F repo=default https://concord.example.com/api/v1/process
```


You can specify the flow e.g. `main` to start with a different flow for the same
`default` repository of the `myproject` without further parameters.

```
curl -F org=myorg -F project=myproject -F repo=default -F entryPoint=main https://concord.example.com/api/v1/process
```

Scheduling an execution:

```
curl ... -F startAt='2018-03-15T15:25:00-05:00' https://concord.example.com/api/v1/process
```

<a name="form-data"/>

### Form Data

Concord accepts `multipart/form-data` requests to start a process. 
Special variables such as `arguments`, `sync`, `archive`, `out`, `activeProfiles`, etc
are automatically configured. Other submitted data of format `text/plain` is used
to configure variables. All other information is stored as a file in the
process' working directory.

However, if user tries to upload a `.txt` file

```
curl ... -F myFile.txt=@myFile.txt -F archive=@target/payload.zip \ 
  https://concord.example.com/api/v1/process
```

then curl uses `Content-Type: text/plain` header and Concord stores this as a
configuration variable instead of a file as desired.

As a workaround you can configured the content type of the field explicitly:

```
curl ... -F "myFile.txt=@myFile.txt;type=application/octet-stream" \
  -F archive=@target/payload.zip \
  https://concord.example.com//api/v1/process
```

<a name="zip-file"/>

### ZIP File

If no project exists in Concord, a ZIP file with flow definition and related
resources can be submitted to Concord for execution. Typically this is only
suggested for development processes and testing or one-off process executions.

Follow these steps:

Create a zip archive e.g. named `archive.zip` containing the Concord file - 
a single `concord.yml` file in the root of the archive:

```yaml
flows:
  default:
  - log: "Hello Concord User"
```

The format is described in
[Project file](../getting-started/processes.html#project-file) document.

Now you can submit the archive directly to the Process REST endpoint of Concord
with the admin authorization or your user credentials as described in our
[getting started example](../getting-started/):

```
curl -F archive=@archive.zip http://concord.example.com/api/v1/process
```

The response should look like:

```json
{
  "instanceId" : "a5bcd5ae-c064-4e5e-ac0c-3c3d061e1f97",
  "ok" : true
}
```

<a name="browser"/>

### Browser Link

You can start a new process in Concord via simply accessing a URL in a browser.
This execution starts the process with the specified parameters and potentially
walks a user through all process' forms and intermediate pages.

* **URI** `/api/v1/org/{orgName}/project/{projectName}/repo/{repoName}/start/{entryPoint}`
* **Method** `GET`
* **Headers** none
* **Required Parameters**
    - orgName - name of the organization in Concord
    - projectName - name of the project in Concord
    - repoName - name of the repository in the project
    - entryPoint - name of the entryPoint to use
* **Optional Parameters**
    - activeProfiles - comma separate list of profiles to activate
    - arguments - process arguments can be supplied using the `arguments.` prefix
* **Body**
    none
* **Success response**
    Redirects a user to a form or an intermediate page or a results page that
    allows access to the process log.
* **Examples**
    - Minimal: `/api/v1/org/Default/project/test-project/repo/test-repo/start/default`
    - Different flow _main_: `/api/v1/org/Default/project/test-project/repo/test-repo/start/main`
    - Specific profile: `/api/v1/org/Default/project/test-project/repo/test-repo/start/default?activeProfiles=dev`
    - Passing process arguments: `/api/v1/org/Default/project/test-project/repo/test-repo/start/default?arguments.x=123&arguments.y=boo`


<a name="stop"/>

## Stop a Process

Forcefully stops the process.

* **URI** `/api/v1/process/${instanceId}`
* **Method** `DELETE`
* **Headers** `Authorization`
* **Parameters**
    ID of a process: `${instanceId}`
* **Body**
    none
* **Success response**
    Empty body.

<a name="status"/>

## Getting the Status of a Process

Returns the current status of a process.

**Note**: this is a `v2` endpoint.

* **URI** `/api/v2/process/${instanceId}`
* **Method** `GET`
* **Headers** `Authorization`
* **Parameters**
    ID of a process: `${instanceId}`
* **Query parameters**
    - `include`: additional entries to return (`checkpoints`, `childrenIds`,
      `history`), repeat the parameter to include multiple additional entries;
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "instanceId" : "45beb7c7-6aa2-40e4-ba1d-488f78700ab7",
      "parentInstanceId" : "b82bb6c7-f184-405e-ae08-68b62125c8be",
      "projectName" : "myProject2",
      "createdAt" : "2017-07-19T16:31:39.331+0000",
      "initiator" : "admin",
      "lastUpdatedAt" : "2017-07-19T16:31:40.493+0000",
      "status" : "FAILED",
      "childrenIds":["d4892eab-f75d-43a2-bb26-20903ffa10d8","be79ee81-78db-4afa-b207-d361a417e892","d5a35c8f-faba-4b9d-b957-ca9c31bf2a39"]
    }
    ```

<a name="log"/>

## Retrieve a Process Log

Downloads the log file of a process.

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

<a name="list"/>

## List Processes

Retrieve a list of processes.

**Note**: this is a `v2` endpoint.

* **URI** `/api/v2/process`
* **Query parameters**
    - `orgId`: filter by the organization's ID;
    - `orgName`: filter by the organization's name;
    - `projectId`: filter by the project's ID;
    - `projectName`: filter by the project's name, requires `orgId` or
      `orgName`;
    - `afterCreatedAt`: limit by date, ISO-8601 string;
    - `beforeCreatedAt`: limit by date, ISO-8601 string;
    - `tags`: filter by a tag, repeat the parameter to filter by multiple tags;
    - `status`: filter by the process status;
    - `initiator`: filter by the initiator's username (starts with the
      specified string);
    - `parentInstanceId`: filter by the parent's process ID;
    - `include`: additional entries to return (`checkpoints`, `childrenIds`,
      `history`), repeat the parameter to include multiple additional entries;
    - `limit`: maximum number of records to return;
    - `offset`: starting index from which to return;
    - `meta.[paramName]`: filter by the process metadata's value `paramName`.
* **Method** `GET`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    [
      { "instanceId": "...", "status": "...", ... },
      { "instanceId": "...", ... }
    ]
    ```

## Process Events

### List Events

Retrieve a list of events.

* **URI** `/api/v1/process/${instanceId}/event`
* **Parameters**
    ID of a process: `${instanceId}`
* **Query parameters**
    - `type`: event type;
    - `after`: limit by date, ISO-8601 string;
    - `eventCorrelationId`: correlation ID of the event (e.g. a task call);
    - `eventPhase`: for multi-phase events (e.g. a task call - `PRE` or
      `POST`);
    - `includeAll`: if `true` additional, potentially sensitive, data is
      returned (e.g. task call parameters);
    - `limit`: maximum number of records to return.
* **Method** `GET`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    [
      {
        "id" : "eba7360e-790a-11e9-a33e-fa163e7ef419",
        "eventType" : "PROCESS_STATUS",
        "data" : {"status": "PREPARING"},
        "eventDate" : "2019-05-18T01:19:02.172Z"
      }, {
        "id" : "ebfabd24-790a-11e9-a33e-fa163e7ef419",
        "eventType" : "PROCESS_STATUS",
        "data" : {"status": "ENQUEUED"},
        "eventDate" : "2019-05-18T01:19:02.720Z"
      }
    ]
    ```
