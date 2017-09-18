---
layout: wmt/docs
title:  Secret
---

# Secret

## Generate a new SSH key pair

Generates a new SSH key pair. A public key will be returned in the
response.

* **Permissions** `secret:create`
* **URI** `/api/v1/secret/keypair?name=${secretName}&generatePassword=${generatePassword}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: multipart/form-data`
* **Parameters**
    Query parameters:
    - `name` - mandatory, unique name;
    - `generatePassword` - optional, if true and there is no
    `storePassword`, the server will encrypt the new secret with a
    random generated password.
    
    Multipart request:
    - `storePassword` - optional, password, which will be used to
    encrypt the new secret and which can be used to retrieve it back.
* **Body** none
* **Success response**
    ```
    Content-Type: application/json
    ```
    
    ```json
    {
      "name": "secretName",
      "publicKey": "ssh-rsa AAAA... concord-server",
      "ok": true
    }
    ```
* **Example**
    ```
curl -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" -F storePassword=12345678 'http://localhost:8001/api/v1/secret/keypair?name=myKey'
    ```

## Upload an existing SSH key pair

Upload an existing SSH key pair.

* **Permissions** `secret:create`
* **URI** `/api/v1/secret/keypair?name=${secretName}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: multipart/form-data`
* **Body**
    Multipart request:
    - `${storePassword}` - optional, password, which will be used to
    encrypt the new secret and which can be used to retrieve it back.
    - `public` - mandatory, public key, binary data;
    - `private` - mandatory, private key, binary data.
* **Success response**
    ```
    Content-Type: application/json
    ```
    
    ```json
    {
      "ok": true
    }
    ```
* **Example**
    ```
curl -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" -F private=@/path/to/mykey -F public=@/path/to/mykey.pub 'http://localhost:8001/api/v1/secret/keypair?name=myKey'
    ```

## Get an existing public key

Returns a public key from an existing key pair.

* **Permissions** `secret:read:${secretName}`
* **URI** `/api/v1/secret/${secretName}/public`
* **Method** `GET`
* **Headers** `Authorization`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```
    
    ```json
    {
      "name": "secretName",
      "publicKey": "ssh-rsa AAAA... concord-server",
      "ok": true
    }
    ```
    
## Add a username/password secret

Adds a new secret containing username and password.

* **Permissions** `secret:create`
* **URI** `/api/v1/secret/password?name=${secretName}&generatePassword=${generatePassword}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: multipart/form-data`
* **Parameters**
    Query parameters:
    - `name` - mandatory, unique name;
    - `generatePassword` - optional, if true and there is no
    `storePassword`, the server will encrypt the new secret with a
    random generated password.
    
    Multipart request:
    - `storePassword` - optional, password, which will be used to
    encrypt the new secret and which can be used to retrieve it back;
    - `username` - mandatory, username part of the new secret;
    - `password` - mandatory, password part of the new secret.
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```
    
    ```json
    {
      "ok": true
    }
    ```
* **Example**
    ```
curl -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" -F username=myUser -F password=myPassword -F storePassword=12345678 'http://localhost:8001/api/v1/secret/password?name=myCreds'
    ```
    
## Add a plain value secret

Adds a new secret containing a simple value.

* **Permissions** `secret:create`
* **URI** `/api/v1/secret/plain?name=${secretName}&generatePassword=${generatePassword}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: multipart/form-data`
* **Parameters**
    Query parameters:
    - `name` - mandatory, unique name;
    - `generatePassword` - optional, if true and there is no
    `storePassword`, the server will encrypt the new secret with a
    random generated password.
    
    Multipart request:
    - `storePassword` - optional, password, which will be used to
    encrypt the new secret and which can be used to retrieve it back;
    - `secret` - mandatory, value of the new secret. Can be a string
    or a stream of bytes.
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```
    
    ```json
    {
      "ok": true
    }
    ```
* **Example**
    ```
curl -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" -F secret='my horrible secret' -F storePassword=12345678 'http://localhost:8001/api/v1/secret/plain?name=myValue'
    ```

## Delete an existing secret

Removes an existing secret.

* **Permissions** `secret:delete:${secretName}`
* **URI** `/api/v1/secret/keypair?name=${secretName}`
* **Method** `DELETE`
* **Headers** `Authorization`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```
    
    ```json
    {
      "ok": true
    }
    ```

## List secrets

Lists existing secrets.

* **Permissions**
* **URI** `/api/v1/secret?sortBy=${sortBy}&asc=${asc}`
* **Query parameters**
    - `sortBy`: `name`, `type`;
    - `asc`: direction of sorting, `true` - ascending, `false` - descending
* **Method** `GET`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```
    
    ```json
    [
      { "name": "...", "type": "..." },
      { "name": "...", "type": "..." }
    ]
    ```
