# Concord Overview

> Orchestrate more. Live better.

- Workflow orchestration      <!-- .element: class="fragment" -->
- Continuous delivery         <!-- .element: class="fragment" -->
- Continuous deployment       <!-- .element: class="fragment" -->
- Process automation          <!-- .element: class="fragment" -->

<!--- vertical -->

## Characteristics

- Flexible architecture for your workflow needs         <!-- .element: class="fragment" -->
- Simple YAML-based DSL for workflow definition         <!-- .element: class="fragment" -->
- Plugin architecture                                   <!-- .element: class="fragment" -->
- Numerous plugins for continuous deployment and more   <!-- .element: class="fragment" -->
- Fully open source                                     <!-- .element: class="fragment" -->

<!--- vertical -->

## Technical Overview

- Java application and runtime                    <!-- .element: class="fragment" -->
- PostgreSQL data storage                         <!-- .element: class="fragment" -->
- Workflow execution as process on agents         <!-- .element: class="fragment" -->
- Agents run JVM process on Docker containers     <!-- .element: class="fragment" -->
- Agents scale horizontally                       <!-- .element: class="fragment" -->
- Overall system has small footprint              <!-- .element: class="fragment" -->

<!--- vertical -->

## Performance and Scalability

- Walmart-scale proven                              <!-- .element: class="fragment" -->
- Over 250.000 endpoints per day regularly          <!-- .element: class="fragment" -->
- Mainframe, VM, container and hardware endpoints   <!-- .element: class="fragment" -->
- Any PaaS, k8s                                     <!-- .element: class="fragment" -->

<!--- vertical -->

## Concord DSL

- Variables               <!-- .element: class="fragment" -->
- Control structures      <!-- .element: class="fragment" -->
- Forms                   <!-- .element: class="fragment" -->
- Profiles                <!-- .element: class="fragment" -->
- Templates               <!-- .element: class="fragment" -->
- JSR scripting           <!-- .element: class="fragment" -->

<!--- vertical -->

# Concord DSL Example

`concord.yml` file in git repository:

```
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins.basic:ansible-tasks:1.4.0
  arguments:
    name: "Example"
flows:
  default:
  - log: "Process ${name} kicked off by ${initiator.displayName}"
  - task: ansible
    in:
      playbook: playbook/hello.yml
  ....
```

Lots more available in examples folder in source.

<!--- vertical -->

## Plugins

<div class="two-columns">
  <div>
    <ul>
      <li>Ansible</li>
      <li>HTTP/REST</li>
      <li>Git/GitHub</li>
      <li>LDAP</li>
      <li>Slack</li>
      <li>Email</li>
    </ul>
  </div>
  <div>
    <ul>
      <li>JIRA</li>
      <li>OneOps</li>
      <li>Looper CI</li>
      <li>Docker</li>
      <li>Kubectl/Helm...</li>
    </ul>
  </div>
</div>

<!--- vertical -->

## Other Features and Characteristics

- Secrets management                                    <!-- .element: class="fragment" -->
- Customizable forms, incl. multi-step and approval     <!-- .element: class="fragment" -->
- Multi-tenant user interface and access control        <!-- .element: class="fragment" -->
- LDAP integration                                      <!-- .element: class="fragment" -->
- PCI certified                                         <!-- .element: class="fragment" -->

<!--- vertical -->

# Supported Workflows

Whatever you define using

- DSL
- Scripting
- Plugins
- Custom plugins

No target restrictions.

<!--- vertical -->

# Example Workflows

- Infrastructure provisioning and management                      <!-- .element: class="fragment" -->
- Application continuous deployment processes                     <!-- .element: class="fragment" -->
- CI/CD pipeline orchestration with build, verify, deploy,..      <!-- .element: class="fragment" -->

<!--- vertical -->

## Use Case: Ansible at Walmart

Multiple large scale success stories:

- Walmart Pharmacy, Optical, and Tire and Lube Express
- Approx. 3000 to over 5000 stores each
- Mixture of Linux, Windows server and Windows workstations
- Each controlled by playbooks
- Runs hit between 5k and 65k endpoints
- Less than 1% failure rate

<!--- vertical -->

## Use Case: Managed Services at Walmart

Full provisioning and deployment of cloud application:

- User requests e.g. managed database via Concord form
- Slack and email notification
- JIRA ticket creation
- Cloud application created in OneOps PaaS
- Application configuration is customized and applied
- Application deployed and started
- Requestor updated with access details in JIRA ticket
- Metrics and more is all hooked up

<!--- vertical -->

## Use Case: Release Management 

Multi-stage zero downtime deployment:

- Looper CI builds new release binary
- Concord flow is kicked off
- Deployment to QA environment
- Run of a number of tests and verifications on QA
- Slack and email notification to release approvers
- Concord form requires sign in and is used as final manual release gate
- Concord manages zero downtime deployment to production
  - Status changes of multiple clouds
  - Controlled release roll out to clouds
  - Automated smoke test verification
- Final success notifications

Numerous projects at Walmart use this with different deployment cloud platforms.

<!--- vertical -->

## Questions?

<em class="yellow">Ask now...</em>
