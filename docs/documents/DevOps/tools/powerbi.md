---
title: Azure DevOps Power BI Database Replica
nav_order: 20
parent: Cloud Tools
layout: page
---

# Azure DevOps Power BI Database Replica

There is a data copy operation which runs in Azure DevOps that creates a replica of the production database that is then made available in Power BI.

The Azure DevOps Release [S105 PaaS to Azure Data Copy](https://dev.azure.com/dfe-ssp/S105-School-Experience/_release?_a=releases&view=mine&definitionId=64) contains the tasks required to complete the process.

Some of the tasks connect to the Azure platform using a Service Connection which authenticates using a Service Principal. The secret for this will expire periodically and therefore needs renewing. Documentation on how to manage a Service Principal is available [here](https://technical-guidance.education.gov.uk/infrastructure/hosting/azure-cip/#service-principal). Be aware that the GitHub actions also uses the same Service Principal too, so the [JSON secret value](https://technical-guidance.education.gov.uk/infrastructure/hosting/azure-cip/#use-the-service-principal-in-external-systems) will need updating at the same time in the secrets section of GitHub Actions.
