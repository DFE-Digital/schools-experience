---
title: Trello
nav_order: 20
parent: Cloud Tools
layout: page
---

# Trello

Trello is a cloud based Kanban tool, used by the project to manage work.

Trello tickets can be attached to GitHub Pull Requests(PR) by putting a link to the Trello ticket in the PR comment.

In School Experience there is a workflow which uses the [Github Action](https://github.com/DFE-Digital/github-actions/tree/master/AddTrelloComment), that will update the Trello ticket when the PR is Opened or Edited.

## Board
[Get School Experience](https://trello.com/b/nS4OTSIl/get-school-experience)

## Change Key
The trello keys are linked to the service account schoolexperience-tech@digital.education.gov.uk. The email is a 365 distribution list and the trello password
is kept in azure key vault s105p01-kv. To generate the API key and token, follow the instructions on [Developer API Keys](https://trello.com/app-key).

Then once you have them, use the command `make development edit-infra-secrets` to edit your secrets and store them in Azure key vault.
