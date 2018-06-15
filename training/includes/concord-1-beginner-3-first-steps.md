# First Steps

> Project Creation and Process Execution

<!--- vertical -->"

## First Concord Project

- Create git repository
- Clone
- Create `concord.yml` file in root
- Commit and push

```
flows:
  default:
  - log: "Hello Concord"
```

Note:
- Demo it

<!--- vertical -->"

## concord.yml

- Main configuration file
- Defines process flows
- Located with your source code
- Uses YAML syntax

<!--- vertical -->"

## YAML

- Simple, human readable text format
- Specs on [YAML website](http://www.yaml.org/)
- Indentation is significant!
- `#` for comment lines
- `-` for elements in array
- Beware the colon `:` significance
- Some validation in Concord

<!--- vertical -->"

## Create and Add Deploy Key

To allow Concord access to the repository:

- Login to Concord Console
- Secrets, Create New Key Pair
  - Visibility public/private
  - No password
- Get public key
- Add to GitHub repository configuration

Note:
- Demo it
- you can also get the key via the REST API
- `curl -u username 'http://concord.prod.walmart.com/api/v1/secret/nameOfKey/public'
- GitHub repo / Settings / Deploy Keys

<!--- vertical -->"

## Creating a Project

- Login to Concord Console
- New Project
- Add Repository
- Use Secret/Deploy Key

Note:
Demo it

<!--- vertical -->"

## Execute Process

- Start the process in the Concord Console or
- Hit a URL or

```
../api/v1/org/{orgName}/project/{projectName}/repo/{repoName}/start/{entryPoint}`
```

-  Invoke process via REST API:

```
curl -v -u myuser -H "Content-Type: application/json" -d '{}' \
http://concord.example.com:8080/api/v1/process/myproject:myrepository
```

And inspect the log in the Concord Console

Note:
Demo it

<!--- vertical -->"

## What Happened

- Concord Server clones/updates project repository
- Prepares for execution
- Runs workflow on Concord cluster

Note:
talk a bit about what these steps include such as separate JVM, classpath, ...

<!--- vertical -->"

## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

