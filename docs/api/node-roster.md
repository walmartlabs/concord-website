---
layout: wmt/docs
title:  Node Roster
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

**Note:** Node Roster is a "beta" feature. API methods and parameters are
subject to change.

[Node Roster](../getting-started/node-roster.html) provides access to data
gathered during [Ansible](../plugins/ansible.html) playbook executions.

- [Hosts](#hosts)
    - [Get All Known Hosts](#get-all-known-hosts)
    - [List Hosts With An Artifact](#list-hosts-with-an-artifact)
    - [List Hosts by a Project](#list-hosts-by-a-project)
    - [Last Deployer](#last-deployer)
- [Facts](#facts)
    - [Latest Host Facts](#latest-host-facts)
- [Artifacts](#artifacts)
    - [Deployed Artifacts](#deployed-artifacts)

## Hosts

### Get All Known Hosts

Returns a (paginated) list of all hosts registered in Node Roster.

* **URI** `/api/v1/noderoster/hosts?offset=${offset}&limit=${limit}`
* **Query parameters**
    - `limit`: maximum number of records to return;
    - `offset`: starting index from which to return.
* **Method** `GET`
* **Headers** `Authorization`
* **Body**
    none
* **Success response**

    ```
    Content-Type: application/json
    ```

    ```json
    [
      { "hostId":  "...", "hostName":  "..." },
      { "hostId":  "...", "hostName":  "..." }
    ]
    ```

### List Hosts With An Artifact

Returns a (paginated) list of all hosts that had the specified artifact
deployed on.

* **URI** `/api/v1/noderoster/deployedArtifact?artifactPattern=${artifactPattern}&offset=${offset}&limit=${limit}`
* **Query parameters**
    - `artifactPattern`: regex, the artifact's URL pattern;
    - `limit`: maximum number of records to return;
    - `offset`: starting index from which to return.
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
      "artifact A": [{ "hostId":  "...", "hostName":  "..." }, { "hostId":  "...", "hostName":  "..." }, ...],
      "artifact B": [{ "hostId":  "...", "hostName":  "..." }, { "hostId":  "...", "hostName":  "..." }, ...],
      ...
    }
    ```
  
    The result is an object where keys are artifact URLs matching the supplied
    `artifactPattern` and values are lists of hosts

### List Hosts by a Project

Returns a (paginated) list of all hosts "touched" (deployed to using one of
[the supported modules](../getting-started/node-roster.html#supported-modules))
by the specified project.

* **URI** `/api/v1/noderoster/hosts/touched?projectId=${projectId}&offset=${offset}&limit=${limit}`
* **Query parameters**
    - `projectId`: ID of the project;
    - `limit`: maximum number of records to return;
    - `offset`: starting index from which to return.
* **Method** `GET`
* **Headers** `Authorization`
* **Body**
    none
* **Success response**

    ```
    Content-Type: application/json
    ```

    ```json
    [
      { "hostId":  "...", "hostName":  "..." },
      { "hostId":  "...", "hostName":  "..." }
    ]
    ```

### Last Deployer

Returns the user who was the last "deployer" (the initiator of a process that
deployed anything) to the specified host.

* **URI** `/api/v1/noderoster/hosts/lastInitiator?hostName=${hostName}&hostId=${hostId}`
* **Query parameters**
    - `hostName`: name of the host;
    - `hostId`: ID of the host.
    
    Either `hostName` or `hostId` must be specified.
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
      "userId": "...",
      "username": "..."
    }
    ```

## Facts

### Latest Host Facts

Returns the latest registered [Ansible facts](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variables-discovered-from-systems-facts)
for the specified host.

* **URI** `/api/v1/noderoster/facts/last?hostName=${hostName}&hostId=${hostId}`
* **Query parameters**
    - `hostName`: name of the host;
    - `hostId`: ID of the host.
    
    Either `hostName` or `hostId` must be specified.
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
      ...
    }
    ```

## Artifacts

### Deployed Artifacts

Returns a (paginated) list of known artifacts deployed to the specified host.

* **URI** `/api/v1/noderoster/hosts/artifacts?hostName=${hostName}&hostId=${hostId}`
* **Query parameters**
    - `hostName`: name of the host;
    - `hostId`: ID of the host.
    
    Either `hostName` or `hostId` must be specified.
* **Method** `GET`
* **Headers** `Authorization`
* **Body**
    none
* **Success response**

    ```
    Content-Type: application/json
    ```

    ```json
    [
      { "url": "..."},
      { "url": "..."},
      ...
    ]
    ```
