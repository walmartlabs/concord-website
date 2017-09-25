# First Steps

> Project Creation and Process Execution


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

## concord.yml

- Main configuration file
- Defines process flows
- Located with your source code
- Uses YAML syntax


## YAML

- Simple, human readable text format
- Specs on [YAML website](http://www.yaml.org/)
- Indendation is significant!
- `#` for comment lines
- Beware the colon `:` significance
- Some validation in Concord

Note:
- uses jackson

## Add Deploy Key

To allow Concord access to the repository:

- request key from Concord
- add to GitHub configuration


## Creating a Project

- Login to Concord Console
- New Project
- Add Repository
- Use Secret/Deploy Key

Note:
Demo it


## Execute Process

Hit it with curl

```
curl -v -u myuser -H "Content-Type: application/json" -d '{}' \
http://concord.example.com:8080/api/v1/process/myproject:myrepository
```

> Inspect the log in the Concord Console

Note:
Demo it


## What Happened

- Concord Server clones/updates project repository
- Prepares for exeuction
- Runs workflow on Concord Agent


## Questions?

<em class="yellow">Ask now, before we jump to the next section.</em>

