---
layout: wmt/docs
title:  Development
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }} 

The following instructions are needed for developing Concord itself.

## Database

A locally-running instance of PostgreSQL is required. By default, the server
will try to connect to `localhost:5432` using username `postgres`, password
`q1` and database name `postgres`.

The easiest way to get the database up and running is to use an official
Docker image:
```
docker run -d -p 5432:5432 --name db -e 'POSTGRES_PASSWORD=q1' library/postgres
```

## Running from an IDE

It is possible to start the server and an agent directly from an IDE using the
following main classes:
- concord-server: `com.walmartlabs.concord.server.Main`
- concord-agent: `com.walmartlabs.concord.agent.Main`

To use predefined project templates, the server must be started with `DEPS_STORE_DIR`
environment variable pointing to the `server/impl/target/deps` directory.

To use LDAP authentication set `LDAP_CFG` environment variable pointing to a [LDAP
configuration file](./configuration.html#ldap).

To start the UI, please refer to the console's readme file.

## Debugging

The `concord-server` and `concord-agent` processes can be started in debug mode as
normal Java applications.

However, as the agent processes its payload in a separate JVM, it must be
configured to start those processes with the remote debugging enabled.

## Building

To skip NPM-related tasks when building the project:
```
./mvnw clean install -DskipTests -DskipNpmInstall -DskipNpmBuild
```

## Making a Release

All JAR files are signed using a GPG key. Pass phrase for a key must be configured in
`~/.m2/settings.xml`:
```xml
<profiles>
  <profile>
    <id>development</id>
    <properties>
      <gpg.passphrase>MY_PASS_PHASE</gpg.passphrase>
    </properties>
  </profile>
</profiles>
```

1. use `maven-release-plugin` as usual:
   ```
   ./mvnw release:prepare release:perform
   ```
2. push docker images;
3. don't forget to push new tags and the release commit:
   ```
   git push origin master --tags
   ```

## Pull Requests

- squash and rebase your commits;
- wait for CI checks to pass.

## Using OpenLDAP for Authentication

1. start the OpenLDAP sever. The easiest way is to use Docker:
   ```
   $ docker run --rm --name oldap -p 1389:389 osixia/openldap
   ...
   5a709dd5 slapd starting
   ...
   ```

   Note: if you want your data to persist, you need to start the server
   as a daemon (using `-d` option).

2. create a user's LDIF file:
   ```
   $ cat /tmp/new-user.ldif
   dn: cn=myuser,dc=example,dc=org
   cn: myuser
   objectClass: top
   objectClass: organizationalRole
   objectClass: simpleSecurityObject
   objectClass: mailAccount
   userPassword: {SSHA}FNvyYavb8XMKC0s2HdCJFZqDY1IzMHqy
   mail: myuser@example.org
   ```

   This creates a new user `myuser` with the password `q1`.

3. import the LDIF file:
   ```
   $ cat /tmp/new-user.ldif | docker exec -i oldap ldapadd -x -D "cn=admin,dc=example,dc=org" -w admin
   
   adding new entry "cn=myuser,dc=example,dc=org"
   ```

4. create the Concord's LDAP configuration file:
   ```
   $ cat /opt/concord/conf/oldap.properties
   url=ldap://127.0.0.1:1389
   searchBase=dc=example,dc=org
   principalSuffix=,dc=example,dc=org
   principalSearchFilter=({0})
   systemUsername=cn=admin,dc=example,dc=org
   systemPassword=admin
   ```

5. start the Concord's server using the created LDAP configuration
file:

   ```
   LDAP_CFG=/opt/concord/conf/oldap.properties
   ...
   11:21:36.873 [main] [INFO ] c.w.c.server.cfg.LdapConfiguration - init -> using external LDAP configuration: /opt/concord/conf/oldap.properties
   ```

6. use `cn=myuser` and `q1` to authenticate in the Console:

   ![Login](/assets/img/screenshots/oldap-login.png)
  
7. after successful authentication, you should see the UI similar to this: 

   ![Success](/assets/img/screenshots/oldap-success.png)
