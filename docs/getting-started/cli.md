---
layout: wmt/docs
title:  CLI
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord provides a command-line tool to simplify some of the common operations.

- [Installation](#installation)
- [Linting](#linting)

## Installation

Concord CLI requires Java 1.8+ available in `$PATH`. Installation is merely
a download-and-copy process:

```bash
curl -o ~/bin/concord http://central.maven.org/maven2/com/walmartlabs/concord/concord-cli/{{ site.concord_core_version }}/concord-cli-{{ site.concord_core_version }}-executable.jar
chmod +x ~/bin/concord
```

## Linting

```bash
concord lint [-v] [target dir]
```

The `lint` command parses and validates Concord YAML files located in the
current directory or directory specified as an argument. It allows to quickly
verify if the [DSL](./concord-dsl.html) syntax and the syntax of expressions are
correct.

Currently, it is not possible to verify whether the tasks are correctly called
and/or their parameter types are correct. It is also does not take dynamically
[imported resources](./concord-dsl.html#imports) into account.

For example, the following `concord.yml`is missing a closing bracket in the
playbook expression.

```yaml
flows:
  default:
    - task: ansible
      in:
        playbook: "${myPlaybookName"    # forgot to close the bracket
```

Running `concord lint` produces:

```bash
$ concord lint
ERROR: @ [/home/ibodrov/tmp/lint/test/concord.yml] line: 3, col: 13
        Invalid expression in task arguments: "${myPlaybookName" in IN VariableMapping [source=null, sourceExpression=null, sourceValue=${myPlaybookName, target=playbook, interpolateValue=true] Encountered "<EOF>" at line 1, column 16.Was expecting one of: "}" ... "." ... "[" ... ";" ... ">" ... "gt" ... "<" ... "lt" ... ">=" ... "ge" ... "<=" ... "le" ... "==" ... "eq" ... "!=" ... "ne" ... "&&" ... "and" ... "||" ... "or" ... "*" ... "+" ... "-" ... "?" ... "/" ... "div" ... "%" ... "mod" ... "+=" ... "=" ... 
------------------------------------------------------------

Found:
  profiles: 0
  flows: 1
  forms: 0
  triggers: 0
  (not counting dynamically imported resources)

Result: 1 error(s), 0 warning(s)

INVALID
```

The linting feature is in very early development, more validation rules are
added in future releases.
