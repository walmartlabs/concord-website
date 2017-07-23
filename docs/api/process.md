---
layout: wmt/docs
title:  Process
---

# Process

## Start a process

### By uploading a ZIP archive

Starts a new process using the uploaded ZIP archive containing all
necessary files.

* **Permissions** none
* **URI** `/api/v1/process?sync=${sync}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/octet-stream`
* **Parameters**
    The `${sync}` (`true/false`, default is `false`) parameter enables
    synchronous execution of a process. The request will block until
    the process is complete.
* **Body**
    Binary data. 
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

### With a JSON request

Starts a new process using the parameters specified in the request body.

* **Permissions** none
* **URI** `/api/v1/process/${entryPoint}?sync=${sync}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Parameters**
    The `${entryPoint}` parameter should be one the following formats:
    - `projectName:repositoryName:flowName`
    - `projectName:flowName`

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
    
### By uploading file(s)

Starts a new process using the provided JSON file as request data.
Accepts multiple additional files, which are put into the process'
working directory.

* **Permissions** none
* **URI** `/api/v1/process?sync=${sync}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: multipart/form-data`
* **Parameters**
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
    http://localhost:8001/api/v1/process
    ```

### From a browser

Starts a new process and walks a user through all process' forms and
intermediate "pages".

* **Permissions** none
* **URI** `/api/service/process_portal/start?entryPoint=${entryPoint}&myParam=myVal...`
* **Method** `GET`
* **Headers** none
* **Parameters**
    The `${entryPoint}` parameter should be one the following formats:
    - `projectName:repositoryName:flowName`
    - `projectName:flowName`

    For example:`myProject:default:main`
    
    The `flowName` part can be ommitted if the project has the
    entry flow name set in the main project file or in a project
    template.
   
    Rest of the query parameters are used as process arguments.
* **Body**
    none
* **Success response**
    Redirects a user to a form or an intermediate page.

## Stopping a process

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

## Waiting for completion of a process

TBD.

## Getting status of a process

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

## Retrieving a process log

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


## Downloading an attachment

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
