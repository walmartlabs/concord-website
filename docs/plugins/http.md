---
layout: wmt/docs
title:  Http Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `http` task provide a basic HTTP/REST client as a task so the users won't have to use a script or resort to running 
curl from a docker container.

`http` task execute the request and return the [Http response](#http-task-response) object which can be store in the 
output variable by providing the `out` parameter. 

The task is provided automatically by the Concord and does not require any external dependencies.

- [Usage](#usage)
- [Parameters](#parameters)
- [Samples](#samples)
- [Limitation](#limitation)

## Usage 
### inline syntax
`asString` method will return the response as string
```yaml
- log: "${http.asString('http://host:post/path/test.txt')}"
```
### full syntax
```yaml
- task: http
  in:
    method: GET
    url: "http://host:post/path/endpoint"
    response: string
    out: response
- if: ${response.success}
  then:
   - log: "Response received: ${response.content}"
```
A full list of available parameters is described [below](#parameters).

## Parameters
All parameters sorted in alphabetical order.
- `auth`: used for secure endpoints. See [Basic auth](#basic-authentication);
- `body`: only used for __POST__ method. It can be string or complex object(map). See [Body](#body);
- `method`: http request method (e.g. **POST**, **GET**)
- `out`: to store the [Http response](#http-task-response) object
- `request`: type of request data [Request type](#request-type);
- `response`: type of response data from endpoint [Response type](#response-type);
- `url`: complete url in string for http request

## Basic authentication
`auth` is an optional parameter. It must contain the `basic` nested element which either contains 
`token` or `username` and `password` element.
- basic auth using token syntax
```yaml
  auth:
    basic:
      token: base64_encoded_auth_token
```
- basic auth using username and password syntax
```yaml
  auth:
    basic:
      username: any_username
      password: any_password
```
Provided credentials or token must be valid otherwise `http` task will throw `UnauthorizedException` exception.

## Body
`body` is mandatory parameter for `method` type __POST__. It can contain complex object (map), json or raw string.
### Body for request type 'json'
```yaml
  request: json
  body:
    myObject:
      nestedVar: 123
```
`http` task will convert the above into `{ "myObject": { "nestedVar": 123 } }` string and pass it into the body of post request.

   You can also give the raw json string but it must be valid otherwise `http` task will throw incompatible request type 
exception.
### Body for request type 'file'
```yaml
  request: file
  body: "relative_path/file.bin"
```
If file does not exist in the mentioned location then `http` task will throw `FileNotFoundException` exception.
### Body for request type 'string'
```yaml
  request: string
  body: "sample string that will pass into the body of post request"
```

## Request type
`request` is optional for `GET` but mandatory for `POST` method. It will map over to the `CONTENT-TYPE` header.

Currently supported types:
- string (converted into `text/plain`)
- json (converted into `application/json`)
- file (converted into `application/octet-stream`)

## Response type
`response` is mandatory parameter and it will map over to the `ACCEPT` header.

Currently supported types:
- string (converted into `text/plain`)
- json (converted into `application/json`)
- file (converted into `application/octet-stream`)

## Http task response
Object return by `http` task. It will contains the following fields:
- `success`: true if status code belongs to success family
- `content`: json/string response or relative path(for response type `file`)
- `statusCode`: http status codes
- `errorString`: Descriptive error message from endpoint

## Samples
Below is the samples for `http` task.
### inline syntax(only for GET request)
```yaml
- log: "${http.asString('http://host:post/path/test.txt')}"
```
### Full syntax for 'GET' request
```yaml
- task: http
  in:
    method: GET
    url: "http://host:post/path/endpoint"
    response: json
    out: jsonResponse
- if: ${jsonResponse.success} # HttpTaskResponse object
  then:
   - log: "Response received: ${jsonResponse.content}"
```
### Full syntax for secure 'GET' request
Using auth token:
```yaml
- task: http
  in:
    auth:
      basic:
        token: base64_encoded_token
    method: GET
    url: "http://host:post/path/endpoint"
    response: json
    out: jsonResponse
- if: ${jsonResponse.success} # HttpTaskResponse object
  then:
   - log: "Response received: ${jsonResponse.content}"
```
Using username and password: 
```yaml
- task: http
  in:
    auth:
      basic:
        username: username
        password: password
    method: GET
    url: "http://host:post/path/endpoint"
    response: json
    out: jsonResponse
- if: ${jsonResponse.success} # HttpTaskResponse object
  then:
   - log: "Response received: ${jsonResponse.content}"
```
### Full syntax for 'POST' request
Using map as a body:
```yaml
- task: http
  in:
    request: json
    method: POST
    url: "http://host:post/path/post_endpoint"
    body: 
      userObj:
        name: concord
    response: json
    out: jsonResponse
- if: ${jsonResponse.success} # HttpTaskResponse object
  then:
   - log: "Response received: ${jsonResponse.content}"
```
Using raw json as a body:
```yaml
- task: http
  in:
    request: json
    method: POST
    url: "http://host:post/path/post_endpoint"
    body: "{ \"myObject\": { \"nestedVar\": 123 } }"
    response: json
    out: jsonResponse
- if: ${jsonResponse.success} # HttpTaskResponse object
  then:
   - log: "Response received: ${jsonResponse.content}"
```
### Full syntax for secure 'POST' request
```yaml
- task: http
  in:
    auth:
      basic:
        username: myusername
        password: mypassword
    request: file
    method: POST
    url: "http://host:post/path/post_endpoint"
    body: "file.bin"
    response: json
    out: jsonResponse
- if: ${jsonResponse.success} # HttpTaskResponse object
  then:
   - log: "Response received: ${jsonResponse.content}"
```

## Limitation
`http` task only support `GET` and `POST` methods. We will add more http methods in future. 