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
The trello keys are kept in azure secrets and will need to be changed when they expire, to do this follow the instructions on [Developer API Keys](https://trello.com/app-key) to generate your KEY and TOKEN.

Then once you have them use the command ```make development edit-infra-secrets``` to edit your secrets. Documentation about this command can be found in the [Technical Guidance]( make development edit-infra-secrets) 
