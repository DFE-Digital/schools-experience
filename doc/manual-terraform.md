# Manual Deployment

These are instructions on how to manually deploy a Cloud Foundry application to **Development** using the terraform cli.

Log into Azure and make sure you have access to the right account, setting your default subscription

```
az login
az account list --output table
az account set --subscription <SUBSCRIPTION>

```

We need to set the ```ARM_ACCESS_KEY```, you will find the ```storage_account_name``` used to store the terraform state. 
Then list the storage accounts in your subscription 

```
az storage account  list --output table
az storage account keys list --resource-group  <ResourceGroup> --account-name <Name> 
export ARM_ACCESS_KEY=<value>
```
	
  	
Log into to cloud foundry CLI and get the deployed  version of the docker image for the application you are interested in `

```
❯ cf app school-experience-app-dev
Showing health and status for app school-experience-app-dev in org dfe / space get-into-teaching as 112871240885355412226...

name:              school-experience-app-dev
requested state:   started
routes:            school-experience-app-dev.london.cloudapps.digital, school-experience-app-dev-internal.apps.internal
last uploaded:     Mon 07 Feb 15:53:49 GMT 2022
stack:
docker image:      ghcr.io/dfe-digital/schools-experience:sha-1d5aaa8

type:           web
sidecars:
instances:      1/1
memory usage:   1024M
     state     since                  cpu    memory         disk         details
#0   running   2022-02-07T15:55:50Z   0.1%   149.4M of 1G   1G of 1.5G
```

Now this bit is a little tricky and depends on your variable name, so you in the case of School Experience the variable is called ```paas_docker_image``` but it may vary and you will need to find it usually in your variables.tf file.

set this to the current image, but as it is used in terraform it needs to be preceeded with TF_VAR_ so

```export TF_VAR_paas_docker_image=ghcr.io/dfe-digital/schools-experience:sha-1d5aaa8```

now we are ready to run terraform.

```
rm -rf .terraform
terraform init -backend-config=dev.bk.vars
terraform plan --var-file=dev.env.tfvars
```
The plan should show nothing has changed, if all is good you can now change what you like and run tests.

