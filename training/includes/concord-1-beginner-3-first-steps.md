# First Steps

> Project Creation and Process Execution

<!--- vertical -->

## First Concord Project

- Create git repository
- Clone
- Create `concord.yml` file in root
- Commit and push

```yaml
flows:
  default:
  - log: "Hello Concord"
```

Note:
- Demo it
- Create new git repo - note that you can add Concord to existing projects, but for demo purposes we're starting with a clean slate.
- Clone and open a concord.yml
Define flows again. All flows need to be in top level element called 'flows'
- Make flow named 'default' - otherwise will get error (w/o later config settings)
- Add 'log' step with a message, then push to remote. Open in GHE
- Note that we're just showing a very basic flow and we'll go line by line and explain what we did

<!--- vertical -->

## concord.yml

- Main configuration file
- Defines process flows
- Located with your source code
- Uses YAML syntax

Note:
- We made a simple flow, they can get very complex. Read slide

<!--- vertical -->

## YAML

- Simple, human readable text format
- Specs on [YAML website](http://www.yaml.org/)
- Indentation is significant!
- `#` for comment lines
- `-` for elements in array
- Beware the colon `:` significance
- Some validation in Concord

Note:
- YAML = YAML Ain't a Markup Language
- Can use however many spaces you want for indentation but be consistent
- Spaces only though, no tabs
- Pound sign to explain what a block is doing with a comment - good practice
- Dash marks elements in an array, like our log step we've made
- Colons identify keys:values, so don't use willy-nilly

<!--- vertical -->

## Create and Add Deploy Key

To allow Concord access to the repository:

- Login to Concord Console
- Default organization
- Secrets, Create New Key Pair
  - Visibility public/private
  - No password, server key
- Get public key
- Add to GitHub repository configuration
  - Deploy keys

Note:
- Demo it
- you can also get the key via the REST API
- `curl -u username 'http://concord.prod.walmart.com/api/v1/secret/nameOfKey/public'
- GitHub repo / Settings / Deploy Keys
- Important b/c Concord and git repo need to trust each other
- Log into Concord console - concord.prod.walmart.com
- Briefly go over the Console view, then select 'Default' org, and click 'Secrets' tab
- Note if they want to get a special org created they can fill out a request
- Create New -> Generate a New Key Pair -> encrypt using the server's key
- Name, Visibility, Submit
- Then copy that key, go to GitHub, repo Settings -> Deploy Keys, and put it in

<!--- vertical -->

## Creating a Project

- Login to Concord Console
- Select organization
- New Project
- Add Repository
- Use Secret/Deploy Key

Note:
- Demo it
- GitHub side is good, now to get Concord ready
- In Cocord, click on Projects tab -> Create New
- Name, description, then save
- Go find the project just made, explain it's there, but empty and not pointed to repo yet
- Open it back up, and go to 'Repositories' -> 'New Repo'
- Name, and go get and paste in the git repo ssh clone link
- Credentials, click on custom, and go find the key pair we made earlier
- Test connection and save
- Note we can add multiple repos to a single Concord projcet
- Click on hamburger menu, go over Validate (only validates YAML syntax, not contents)
- Press Run
- Explain this downloaded the repository and started execution - doesn't mean the flow is complete
- Click on 'View Process page'
- Click on log tab and explain what's there (message we made, dependencies loaded, repo cloned)

<!--- vertical -->

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
- Demo it
- Good example is the confirm attendance button - hover over it and show the link is to a Concord flow

<!--- vertical -->

## What Happened

- Concord Server clones/updates project repository
- Prepares for execution
- Runs workflow on Concord Server agent

Note:
- talk a bit about what these steps include such as separate JVM, classpath, ...
- Concord cloned the git repo into the Concord Server, then parsed the yaml, said 'I understand', and started
- YAML syntax errors will return an error before it starts and then not run. Maybe demo by removing a dash

<!--- vertical -->

## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

