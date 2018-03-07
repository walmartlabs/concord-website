---
layout: wmt/docs
title:  HTTP Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `http` task provides a basic HTTP/RESTful client that allows you to call
RESTful endpoints. It is provided automatically by Concord, and does not require
any external dependencies.

RESTful endpoints are very commonly used and often expose an API to work with 
an application. The http task allows you to therefore invoke any exposed
functionality  in third party applications in your Concord project and therefore
automate the interaction  with these applications. This makes the http task a
very powerful tool to integrate Concord with applications that do not have a
custom integration with Concord via a specific task.

The `http` task executes RESTful requests using a HTTP `GET` or `POST` method
and returns [HTTP response](#http-task-response) objects. The response object
can be stored in an `out` parameter for later usage.

- [Usage](#usage)
- [Parameters](#parameters)
- [Samples](#samples)

## Usage 

For requests, you have the following options:

- inline syntax.
- full formatting using mapping that the `http` task interprets.

The simple inline syntax uses an expression with the http task and the 
`asString` method. It uses a HTTP `GET` as a default request method and returns
the response as string.

```yaml
- log: "${http.asString('http://host:post/path/test.txt')}"
```

The full syntax is preferred since it allows access to all features of the HTTP
task:

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
- `body`: only used for __POST__ method. It can be string or complex
  object(map). See [Body](#body);
- `method`: HTTP request method either 'post'(e.g. **POST**, **GET**)
- `out`: to store the [HTTP response](#http-task-response) object
- `request`: type of request data [Request type](#request-type);
- `response`: type of response data from endpoint [Response type]
(#response-type);
- `url`: complete url in string for http request

### Basic Authentication

The `auth` parameter is optional. When used, it must contain the `basic` nested
element which contains either the `token` element, or the `username` and
`password` elements.

Basic auth using `token` syntax:

```yaml
  auth:
    basic:
      token: base64_encoded_auth_token
```

Basic auth using `username` and `password` syntax:

```yaml
  auth:
    basic:
      username: any_username
      password: any_password
```

Use valid values for basic authentication parameters. Authentication failure
causes an `UnauthorizedException` error.

### Body

The HTTP method type _POST_ requires a `body` parameter that contains a complex
object (map), json sourced from a file, or raw string.


Body for request type `json`:

```yaml
  request: json
  body:
    myObject:
      nestedVar: 123
```

The `http` task converts complex objects like the above into string and passes
it into the body of post request. The converted string for the above example is
`{ "myObject": { "nestedVar": 123 } }`.

The `http` task accepts raw json string, and throws an `incompatible request
type` error when it detects improper formatting.

Body for Request Type `file`:

```yaml
  request: file
  body: "relative_path/file.bin"
```

Failure to find file of the name given in the referenced location results in
a`FileNotFoundException` error.

Body for Request Type `string`:

```yaml
  request: string
  body: "sample string for body of post request"
```

### Request Type

A specific request type in `request` is optional for `GET` method usage, but
mandatory for `POST`. It maps over to the `CONTENT-TYPE` header of the HTTP
request.

Types supported currently:

- string (converted into `text/plain`)
- json (converted into `application/json`)
- file (converted into `application/octet-stream`)

### Response Type

`response` is mandatory parameter and maps to the `ACCEPT` header of the HTTP
request.

Types supported currently:

- string (converted into `text/plain`)
- json (converted into `application/json`)
- file (converted into `application/octet-stream`)

### HTTP Task Response

Objects returned by the HTTP task contain the following fields:

- `success`: true if status code belongs to success family
- `content`: json/string response or relative path (for response type `file`)
- `statusCode`: http status codes
- `errorString`: Descriptive error message from endpoint

## Examples

Following are examples that illustrate syntax use for `http` task.

### Full Syntax for 'GET' Request

```yaml
- task: http
  in:
    method: GET
    url: "http://host:post/path/endpoint"
    response: json
    out: jsonResponse
- if: ${jsonResponse.success}
  then:
   - log: "Response received: ${jsonResponse.content}"
```

### Full Syntax for 'POST' Request

Using map for the body:

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
- if: ${jsonResponse.success}
  then:
   - log: "Response received: ${jsonResponse.content}"
```

Using raw json for the body:

```yaml
- task: http
  in:
    request: json
    method: POST
    url: "http://host:post/path/post_endpoint"
    body: "{ 
             \"myObject\": 
               { \"nestedVar\": 123 
               } 
           }"
    response: json
    out: jsonResponse
- if: ${jsonResponse.success}
  then:
   - log: "Response received: ${jsonResponse.content}"
```

### Full Syntax for Secure Request

Using a basic auth token:

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
- if: ${jsonResponse.success}
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
- if: ${jsonResponse.success}
  then:
   - log: "Response received: ${jsonResponse.content}"
```
