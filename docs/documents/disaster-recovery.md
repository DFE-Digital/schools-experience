---
title: Disaster Recovery Plan
layout: page
---

## Disaster Recovery Plan

Disaster Recover (DR) follows the principles outlined in the [Becoming a Teacher  Disaster recovery plan](https://dfedigital.atlassian.net/wiki/spaces/BaT/pages/2921365676/Disaster+recovery).

## Pre Requisit Installations

[Install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

[Install the Cloud Foundry CLI](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html#pkg)

## Access


### Azure Access

The Department of Education Azure system is known as Cloud Infrastructure Platform (CIP). The user will require access to the School Experience production subscription, and will need to have elevated privilages set via Azure privilaged identity managment, so they can download files in the storage account.

[Access to CIP Guide](https://dfedigital.atlassian.net/wiki/spaces/BaT/pages/1897955586/Azure+CIP)

## Specific to School Experience

The data in Postgres is persistent and regular backups are carried out by Cloud Foundry (AWS).

However, Every night the Azure Pipeline Datase backup  will run, as part of this process it exports the live databases. For restore purposes we are storing this file in an Azure file storage account (Production subscription ).

This file can be used to recover the database in the event of accidental deletion.

### Download Recovery file

The file can be downloaded via the Azure portal or using Azure CLI, in both cases you will need permission to access the Azure Storage Account.

#### Azure CLI get storage keys

Note: you will need to set your AZURE_STORAGE_KEY variable. To get this:

```
az login
az account list --output=table             ### List of accounts you have access to
az account set --subscription <School Experience Production Account Name>
az storage account list --output=table     ### List of Storage accounts you have access to
az storage account keys list --resource-group <Resource Group> --account-name <Storage Account Name>
export AZURE_STORAGE_KEY=<KEY>
```

#### Azure CLI download file

Once your AZURE_STORAGE_KEY is set, you will need to download the backup file, these instructions show how you can do this using the Azure CLI:

```
az login
az account list --output=table      ### List of accounts you have access to
az account set --subscription <School Experience Production Account Name>
az storage account list --output=table                                                              ### Output is a list of storage accounts
az storage container list --account-name <Storage Account Name> --output=table                      ### Output is list of containers
az storage blob list --container-name <Backup Container> --account-name <Storage Account Name> --output=table  ### Output is list of files

## Choose a File and download it.
az storage blob download --container-name <Backup Container> --account-name <Storage Account Name> --name Tuesday.tar.gz --file output.sql
```
