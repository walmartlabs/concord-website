---
layout: wmt/docs
title: Argo CD Task
side-navigation: wmt/docs-navigation.html
description: Plugin for interacting with Argo CD for application and project management
---

# {{ page.title }}

The `argocd` task allows workflows to interact with various
[Argo CD](https://argo-cd.readthedocs.io/en/stable/) API endpoints to manage applications
and projects on the instance.

- [Usage](#usage)
- [Task Output](#task-output)
- [Authentication](#authentication)
    - [Basic Authentication](#basic-authentication)
    - [LDAP Authentication](#ldap-authentication)
    - [Azure Authentication](#azure-authentication)
- [Application Operations](#application-operations)
    - [Get Application](#get-application)
    - [Create Application](#create-application)
    - [Sync Application](#sync-application)
    - [Patch Application](#patch-application)
    - [Set Application Parameters](#set-application-parameters)
    - [Update Application Spec](#update-application-spec)
    - [Delete Application](#delete-application)
- [Project Operations](#project-operations)
    - [Get Project](#get-project)
    - [Create Project](#create-project)
    - [Delete Project](#delete-project)
- [ApplicationSet Operations](#applicationset-operations)
    - [Get ApplicationSet](#get-applicationset)
    - [Create ApplicationSet](#create-applicationset)
    - [Delete ApplicationSet](#delete-applicationset)

## Usage

To enable the task in a Concord flow, it must be added as a
[dependency](../processes-v2/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:argocd-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke the task in a flow:

```yaml
flows:
  default:
    - task: argocd
      in:
        action: get
        app: "test"
        auth:
          ldap:
            username: user
            password: password
      out: result
```

__Common Parameters__
- `action`: Action to perform. One of:
    - `get` - Get the detailed information about the specified `app`.
    - `create` - Creates an application on the specified Argo CD `baseUrl`.
    - `sync` - Sync an existing application to its desired state.
    - `patch` - patch the source information in an application on the Argo CD instance.
    - `setParams` - Set an application's parameters.
    - `updateSpec` - Update the application manifest with the `spec` provided. 
    - `delete` - Delete an application on the specified Argo CD `baseUrl`.
    - `getProject` - Get the details information about the specified `project`.
    - `createProject` - Creates a project on the specified Argo CD `baseUrl`.
    - `deleteProject` - Delete a project on the specified Argo CD `baseUrl`.
- `baseUrl`: Argo CD instance's base URL
- `debug`: optional `boolean`, enabled extra debug log output for troubleshooting
- `auth`: API authentication info. Used to generate an authentication token.
- `validateCerts`: optional `boolean`, default value `true`, can be overridden for testing.
- `connectTimeout`: optional value specifies the connection timeout while making API requests to Argo CD
- `readTimeout`: optional value specifies the read timeout while making API requests to Argo CD
- `writeTimeout`: optional value specifies the write timeout while making API requests to Argo CD.

## Task Output

In addition to
[common task result fields](../processes-v2/flows.html#task-result-data-structure),
the output of the full `argocd` task call returns the following depending 
on the action performed.

- `application` - manifest of the application on which `action` was performed.

```yaml
flows:
  default:
    - task: argocd
      in:
        action: get
        app: "test"
        baseUrl: https://argo.dev
        auth:
          ldap:
            username: user
            password: password
      out: result
    - if: ${result.ok}
      then:
        - log: "Successfully retrieved application from ArgoCD data"
        # can be accessed in ${result.app}
      else:
        - log: "Error with task: ${result.error}"
```

The output of public method calls may be different depending on the method called.
See the documentation for the specific method for output details.

## Authentication

Authentication with Argo CD can happen in two ways depending on the auth 
configuration on the Argo CD instance. 

### Basic authentication

This type of authentication is used when there are local users setup on the Argo CD 
instance for administrative purposes, for example. 

```yaml
flows:
  default:
    - task: argocd
      in:
        action: get
        app: test
        baseUrl: https://argo.dev
        auth:
          basic:
            username: localUser
            password: password
      out: result
```

### LDAP Authentication

In this case, Argo CD instance delegates authentication to an LDAP directory backed 
authentication mechanism.

```yaml
flows:
  default:
    - task: argocd
      in:
        action: get
        app: test
        baseUrl: https://argo.dev
        auth:
          ldap:
            username: user
            password: password
      out: result
```

### Azure Authentication

In this case, Argo CD instance authentication is done via [Azure AD](https://azure.microsoft.com/en-us/products/active-directory). 
Azure AD App registration and configuration must be in place to work. More details can be found 
[here](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/microsoft/#azure-ad-app-registration-auth-using-oidc).

#### Parameters
  * `clientId` - ClientId of the argocd client app registered in Azure portal.
  * `authority` - Identity of the party who issue token. For example - `https://login.microsoftonline.com/<tenantId>/v2.0`
  * `scope` - Optional, Permissions needed to perform activity. Default - `user.read`
  * `username` - Username used to authenticate in Azure AD
  * `password` - Password for the supplied `username`

```yaml
flows:
  default:
    - task: argocd
      in:
        action: get
        app: test
        baseUrl: https://argo.dev
        auth:
          azure:
            clientId: test-client-110
            authority: https://login.microsoftonline.com/test-tenant-001/v2.0
            scope:
              - user.default
            username: user
            password: password
      out: result
```
> _**Note:**_ _Allow public client flows_ should be enabled in **Authentication > Advanced settings** under Azure App registration.

## Application Operations

### Get Application

Use the `get` action to get the details of an application
present on the Argo CD instance.

__Parameters__

- `app`: Name of the application to be retrieved.
- `refresh`: optional `boolean` forces application reconciliation if set to `true`

```yaml
- task: argocd
  in:
    action: get
    baseUrl: https://argo.dev
    app: test
    auth:
      ldap:
        username: user
        password: password
    refresh: false
  out: result
```

### Create Application

Use the `create` action to create an application with 
the provided details

__Parameters__

- `app`: Name of the application to be created. 
- `cluster`: Name of the Kubernetes cluster on which the application is to be created.
- `namespace`: Namespace in which the application is to be created. 
- `createNamespace`: optional `boolean` when set will force creation of the namespace
specified, if not present. 
- `gitRepo`: optional SCM information to which the application will sync. Not required
if `helmRepo` is specified.
    * `repoURL`: URL of the SCM Repository
    * `targetRevision`: Branchname, tag, or commit hash to sync to.
    * `path`: The path in the SCM repository which contains Helm charts, application 
    manifest, or k8s resource definitions.
- `helmRepo`: optional Helm repo information to which the application will sync. Not 
required if `gitRepo` is specified. 
    * `repoURL`: URL of the Helm Repository
    * `chart`: Name of the Helm Chart
    * `targetRevision`: Version of the Chart to be installed.
- `helm`: optional map of Helm parameters and values
    * `parameters`: optional map specifying parameters to the Helm chart.
    * `values`: values to be provided to the Helm chart, to override default values if any.
- `project`: project in which the application is to be created. Project creates a logical
grouping for several applications. `default` if not specified.
- `annotations`: optional map describing the application.

```yaml
- task: argocd
  in:
    action: create
    baseUrl: https://argo.dev
    auth:
      ldap:
        username: user
        password: password
    app: test-app
    namespace: test-namespace
    cluster: in-cluster
    project: default
    gitRepo:
      repoUrl: https://github.com/testOrg/testRepo.git
      path: test-app-helm
      targetRevision: HEAD
    helm:
      parameters:
        - name: key
          value: value
        - name: key2
          value: value2
      values: |
        ---
        applicationSize: 4
        applicationFile: https://mvnrepository.com/artifact-version.jar
        .... # other values from a values.yml or similar file
  out: result
```

### Sync Application

Use the `sync` action to perform a sync operation 
on an existing application to bring it to the desired state.

__Parameters__
- `app`: name of the app to be synced.
- `revision`: revision of the resource to be synced.
- `resources`: Array of application resources
    * `group`: resource group name
    * `kind`: kind of k8s resource
    * `name`: name of the resource
    * `namespace`: namespace in which the resource is created
- `dryRun`: optional `boolean` specifying if the sync operation to be performed
is on an actual environment or a dry run. Defaults to `false`.
- `prune`: optional `boolean` which enables pruning of resources
as part of the sync operation. Defaults to `false`.
- `retryStrategy`: optional map, specifying custom retry strategies
when sync fails.
- `strategy`: optional map, specifying the strategy to be applied
during the sync.
- `watchHealth`: optional `boolean` to force the sync operation to wait till 
all the components are in healthy state. Defaults to `false`. 
- `syncTimeout`: optional duration parameter to specify the timeout duration 
for the sync operation. 

```yaml
- task: argocd
  in:
    action: sync
    app: "test-app"
    watchHealth: true
    debug: false
    baseUrl: https://argo.dev
    auth:
      ldap:
        username: user
        password: password
    validateCerts: true
    prune: false
    syncTimeout: 300
  out: syncResult
```

### Patch Application

Use the `patch` action to patch source path
on an existing application and bring it to the desired state.

__Parameters__
- `app`: Name of the app to be patched
- `patches`: map of the k8s spec with updated source path
```yaml
- task: argocd
  in:
    action: patch
    app: test-app
    baseUrl: https://argo.dev
    auth:
      ldap:
        username: user
        password: password
    patches:
      spec:
        source:
          targetRevision: releaseBranch
```

### Set Application Parameters

Use the `setParams` action to set the application parameters.

__Parameters__
- `app`: name of the app for which parameters have to be set or updated.
- `helm`: list of name-value pairs of parameters to be set.
    * `name`: name of the parameter
    * `value`: value of the parameter

```yaml
- task: argocd
  in:
    action: setParams
    app: test-app
    baseUrl: https://argo.dev
    auth:
      ldap:
        username: user
        password: password
    helm:
      - name: PARAM1
        value: value1
      - name: PARAM2
        value: value2
        ...
```

### Update Application Spec

Use the `updateSpec` action to update the application resource object. 

__Parameters__
- `app`: name of the app which has to be updated.
- `spec`: map of the application k8s resource to be updated.

```yaml
- task: argocd
  in:
    action: updateSpec
    app: test-app
    baseUrl: https://argo.dev
    auth:
      ldap:
        username: user
        password: password
    spec:
      helm:
        values: |
          ---
          applicationVersion: 1.3.0
          replicas: 4
          ...
```

### Delete Application

Use the `delete` action to delete an application on the Argo CD instance.

__Parameters__
- `app`: name of the app to be deleted.
- `cascade`: optional `boolean` to perform a cascaded deletion of all 
application resources. Defaults to `false`.
- `propogationPolicy`: optional string. Specify propagation policy for deletion of 
application's resources. One of: foreground|background (default "foreground")

```yaml
- task: argocd
  in:
    app: test-app
    cascade: true
    baseUrl: https://argo.dev
    auth:
      ldap:
        username: user
        password: password
```

## Project Operations

### Get Project

Use the `getProject` action to get the details of a project
present on the Argo CD instance.

__Parameters__

- `getProject`: Name of the project to be retrieved.

```yaml
- task: argocd
  in:
    action: getProject
    baseUrl: https://argo.dev
    project: test
    auth:
      ldap:
        username: user
        password: password
  out: result
```

### Create Project

Use the `createProject` action to create a project with the provided details

__Parameters__

- `project`: Name of the project to be created.
- `upsert`: boolean value (default to false)
- `description`: optional project description
- `annotations`: optional map describing the application
- `sourceRepos`: optional sourceRepos contains list of repository 
URLs which can be used for deployment. defaults to '*'
- `destinations`: optional destinations contains list of destinations 
available for deployment. defaults to '*'

```yaml
- task: argocd
  in:
    action: createProject
    baseUrl: https://argo.dev
    auth:
      ldap:
        username: user
        password: password
    project: test-project
    sourceRepos:
      - '*'
    destinations:
      - name: 'all'
        namespace: '*'
        server: '*'
  out: result
```


### Delete Project

Use the `deleteProject` action to delete a project on the Argo CD instance.

__Parameters__
- `project`: name of the project to be deleted.

```yaml
- task: argocd
  in:
    app: test-project
    baseUrl: https://argo.dev
    auth:
      ldap:
        username: user
        password: password
```

## ApplicationSet Operations

### Get ApplicationSet

Use the `getApplicationSet` action to get the details of a applicationSet
present on the Argo CD instance.

__Parameters__

- `applicationSet`: Name of the applicationSet to be retrieved.

```yaml
- task: argocd
  in:
    action: getApplicationSet
    baseUrl: https://argo.dev
    applicationSet: test
    auth:
      ldap:
        username: user
        password: password
  out: result
```

### Create ApplicationSet

Use the `createApplicationSet` action to create a applicationSet with the provided details

__Parameters__

- `generators`: Array of objects defines how the applications should generate. More details can be found [here](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators/)
- `preserveResourcesOnDeletion`: PreserveResourcesOnDeletion will preserve resources on deletion. If PreserveResourcesOnDeletion is set to true, these Applications will not be deleted.
- `strategy`: configures how generated Applications are updated in sequence. More details found [here](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Progressive-Syncs/#strategies)
- `applicationSet`: Name of the applicationset to be created
- `app`: Name of the application to be created in the applicationset. 
- `cluster`: Name of the Kubernetes cluster on which the application is to be created.
- `namespace`: Namespace in which the application is to be created. 
- `createNamespace`: optional `boolean` when set will force creation of the namespace
specified, if not present. 
- `gitRepo`: optional SCM information to which the application will sync. Not required
if `helmRepo` is specified.
    * `repoURL`: URL of the SCM Repository
    * `targetRevision`: Branchname, tag, or commit hash to sync to.
    * `path`: The path in the SCM repository which contains Helm charts, application 
    manifest, or k8s resource definitions.
- `helmRepo`: optional Helm repo information to which the application will sync. Not 
required if `gitRepo` is specified. 
    * `repoURL`: URL of the Helm Repository
    * `chart`: Name of the Helm Chart
    * `targetRevision`: Version of the Chart to be installed.
- `helm`: optional map of Helm parameters and values
    * `parameters`: optional map specifying parameters to the Helm chart.
    * `values`: values to be provided to the Helm chart, to override default values if any.
- `project`: project in which the application is to be created. Project creates a logical
grouping for several applications. `default` if not specified.
- `annotations`: optional map describing the application.

```yaml
  - task: argocd
    in:
      action: CREATEAPPLICATIONSET
      auth:
        ldap:
          username: user
          password: password
      validateCerts: false
      baseUrl:  https://argo.dev
      applicationSet: test
      generators: 
      - list:
          elements:
          - cluster: cluster-1
            name: 'app-1'
          - cluster: cluster-2
            name: 'app-2'
      app: "test-{{name}}"
      namespace: default
      cluster: '{{cluster}}'
      gitRepo:
        repoUrl: https://github.com/testOrg/testRepo.git
        targetRevision: master
        path: testPath
    out: result
```


### Delete ApplicationSet

Use the `deleteApplicationSet` action to delete a ApplicationSet on the Argo CD instance.

__Parameters__
- `applicationSet`: name of the applicationSet to be deleted.

```yaml
- task: argocd
  in:
    applicationSet: test-applicationSet
    baseUrl: https://argo.dev
    auth:
      ldap:
        username: user
        password: password
```
> _**Note:**_ Minimum Argocd version 2.5 is required for applicationset operations.
