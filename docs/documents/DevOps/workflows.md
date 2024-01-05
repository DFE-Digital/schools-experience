---
title: Workflows
nav_order: 20
parent: DevOps
layout: page
---

# Workflows

## Overview
Workflows are orchestrated via [github actions](https://docs.github.com/en/actions) which build, test and deliver our code to AKS.

Guidance about the use of Github Actions can be found on the [DfE Technical Guidance](https://technical-guidance.education.gov.uk/infrastructure/automation/github-actions) page.

Delivery to AKS is via Terraform which delivers containers built by the workflow and stored in [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)(GHCR)

## Workflows

### [Build and Deploy](https://github.com/DFE-Digital/schools-experience/blob/master/.github/workflows/build.yml)

This is the heart of the deployment system, it has a number of phases

1. **Build** - During this phase the docker image built and pushed to the GHCR
2. **Unit Tests** - Lint, Rubocop and Spec tests are executed
3. **Security Tests** - Brakeman and Snyk security tests are executed
4. **Cucumber Tests** - Various application specific [Cucumber](https://cucumber.io/) tests are executed.
5. **Sonar Cloud** - The [Sonarqube](https://www.sonarqube.org/) scanner is executed and the results passed to the [Sonarcloud](https://sonarcloud.io/) quality gateway
6. **Deployments**
	1. **Review** - When a PR is created a review is required, and this deployment brings up the specific version of the application so it can be checked out by the reviewer.
	7. **Development** - When the review is accepted and merged the application is first delivered to the Development area. This is to ensure any code that impacts the delivery workflow does not bring down the system.
	8. **Quality Assurance** - Also known as the staging area, this is a near live test, ensuring all the components hang together, so there is a high degree of confidence the Production deployment will work.
	9. **Production** - The final deployment to the live system

### [Check Service Principal](https://github.com/DFE-Digital/schools-experience/blob/master/.github/workflows/check_sp.yml)
Ran each night this workflow checks that Service Prinicipal has at least 30 days left before its security credentials expire. If due to expire a message is sent to [SLACK](https://slack.com) with instructions on how to reset it.

### [DO NOT MERGE](https://github.com/DFE-Digital/schools-experience/blob/master/.github/workflows/stop_merges.yml)
When a PR is labelled with DO NOT MERGE, this workflow will prevent the system from merging it.

### [Destroy Review Instance](https://github.com/DFE-Digital/schools-experience/blob/master/.github/workflows/destroy.yml)
When a PR is accepted and merged to the master branch, the review application can be destroyed as it is no longer required.

### [Link Trello Card](https://github.com/DFE-Digital/schools-experience/blob/master/.github/workflows/trello.yml)
If a PR references a [Trello](https://trello.com/) card, then when the PR is sent for Review the card is updated.

### [Manual Release](https://github.com/DFE-Digital/schools-experience/blob/master/.github/workflows/manual.yml)
This workflow allows an operator to manually choose a built release from GitHub and deliver it to anyone of the Environments.

### [Pull Request Labeler](https://github.com/DFE-Digital/schools-experience/blob/master/.github/workflows/labeler.yml)
This workflow checks which code has been changed when a PR is created and labels the PR with the appropriate label set.  For example if terraform was changed then this would be labelled as a
