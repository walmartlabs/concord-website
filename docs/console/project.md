---
layout: wmt/docs
title:  Project
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }} 

A project allows you define an entity within an
[organization](./organization.html) with access rights, description,
[secrets](./secret.html) and numerous [repositories](./repository.html).

Projects are created with the Concord Console or by using the REST API.

### Move Project to a Different Organization

A project after it is created in an organization can be moved to a different
organization to which the user must have access to (WRITER or above).

This can be done with the Concord Console or by using the REST API.

1. Login to the Console of your Concord instance

    ![Homepage](/assets/img/screenshots/initial-view.png)

2. Navigate to the settings tab of the project to be moved.

    _Organizations -> Select Organization -> Select Project -> Settings_

    ![ProjectSettings](/assets/img/screenshots/project-view.png)

3. Scroll down to **`Danger Zone`** and enter the Organization name to which
   the project has to be moved to, and select it.

    _current organization_

    ![DangerZoneInitial](/assets/img/screenshots/project-danger-zone-initial.png)

    _changed organization_

    ![DangerZoneChangedOrg](/assets/img/screenshots/project-danger-zone-org-change.png)

    Click on *`Move`*.

4. A Pop-up appears for confirmation. Enter the current project name in
   the text box and click on `Yes`.

   ![OrgChangePopUp](/assets/img/screenshots/move-project-popup.png)

   Read the message in the Pop-up carefully before clicking on `Yes`.

Following these steps will move the selected project to another organization
and redirect to the changed project URL path.

> **NOTE:**
> * Any secret used by repositories in this project will not be available for
> use under the new Organization, unless is the secret is also moved to that
> organization and mapped to the repositories again (refer
> [here](./secret.html#move-secret-to-a-different-organization) for more
> details).
> * For any secret in the current organization scoped to this project,
> the scope mapping will be removed.
