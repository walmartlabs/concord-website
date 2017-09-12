---
layout: wmt/docs
title:  Quickstart
---

# {{ page.title }} 

If you have [installed your own Concord server](./installation.html) or have
access to a server already, you can set up your first simple project.

## Create a Simple Concord Project

Create a zip archive containing a single `.concord.yml` file (starting with a
dot):

```yaml
flows:
  main:
    - log: "Hello, ${name}"
      
variables:
  entryPoint: "main"
  arguments:
    name: "world"
```

The format is described in [Project file](./processes.html#project-file) document.

The resulting archive should look like this:

```
$ unzip -l archive.zip 
Archive:  archive.zip
  Length      Date    Time    Name
---------  ---------- -----   ----
      335  2017-07-04 12:00   .concord.yml
---------                     -------
      335                     1 file
```

### Step 8. Start a New Concord Process

```
curl -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" \
     -H "Content-Type: application/octet-stream" \
     --data-binary @archive.zip http://localhost:8001/api/v1/process
```
  
  The response should look like:
```json
{
  "instanceId" : "a5bcd5ae-c064-4e5e-ac0c-3c3d061e1f97",
  "ok" : true
}
```

### Step 9. Check the Concord Server Logs

If you have started the server with docker you can see the project output with: 

```
docker logs server
```
  
If everything went okay, you should see something like this:

```
15:14:26.009 ... - updateStatus ['1b3dedb2-7336-4f96-9dc1-e18408d6b48e', 'ed097181-44fd-4235-973a-6a9c1d7e4b77', FINISHED] -> done
```

You can also check the log by opening it in 
[the Concord console](http://localhost:8080/).
