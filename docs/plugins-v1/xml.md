---
layout: wmt/docs
title:  XML Task
side-navigation: wmt/docs-navigation.html
deprecated: true
description: Plugin for parsing XML data
---

# {{ page.title }}

The `xmlUtils` task provides methods to work with XML files.

- [Usage](#usage)
- [Provided Methods](#provided-methods)
    - [Read a String Value](#read-a-string-value)
    - [Read a List of String Values](#read-a-list-of-string-values)
    - [Read a Maven GAV](#read-a-maven-gav)

## Usage

To be able to use the `xmlUtils` task in a Concord flow, it must be added as a
[dependency](../processes-v1/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
    - "mvn://com.walmartlabs.concord.plugins:xml-tasks:{{ site.concord_plugins_version }}"
```

This adds the task to the classpath and allows you to invoke the task using
expression.

## Provided Methods

### Read a String Value

Assuming an XML file `data.xml` with the following content:

```xml
<books>
  <book id="0">
    <title>Don Quixote</title>
    <author>Miguel de Cervantes</author>
  </book>
</books>
```

To get the string value of the book's `<title>` tag:

```yaml
- log: ${xmlUtils.xpathString('data.xml', '/books/book[@id="0"]/title/text()')}
```

Prints out `Don Quixote`.

The expression must be a valid [XPath](https://en.wikipedia.org/wiki/XPath) and
return a DOM text node.

## Read a List of String Values

Assuming an XML file `data.xml` with the following content:

```xml
<books>
  <book id="0">
    <title>Don Quixote</title>
    <author>Miguel de Cervantes</author>
  </book>
  <book id="1">
    <title>To Kill a Mockingbird</title>
    <author>Harper Lee</author>
  </book>
</books>
```

To get a list of values for all book `<title>` tags:

```yaml
- log: ${xmlUtils.xpathListOfStrings('data.xml', '/books/book/title/text()')}
```

The expression must be a valid [XPath](https://en.wikipedia.org/wiki/XPath) and
return a set of DOM text node.

## Read a Maven GAV

To read Maven GAV (groupId/artifactId/version attributes) from a `pom.xml`
file:

```xml
<!-- simplified example POM -->
<project>
  <parent>
    <groupId>com.walmartlabs.concord.plugins</groupId>
    <artifactId>concord-plugins-parent</artifactId>
    <version>1.27.1-SNAPSHOT</version>
  </parent>

  <artifactId>xml-tasks</artifactId>
</project>
```

```yaml
# concord.yml
- expr: "${xmlUtils.mavenGav('pom.xml')}"
  out: gav

- log: "groupId: ${gav.groupId}" # "com.walmartlabs.concord.plugins"
- log: "artifactId: ${gav.artifactId}" # "xml-tasks"
- log: "version: ${gav.version}" # "1.27.1-SNAPSHOT"
```
