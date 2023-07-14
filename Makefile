TERRAFILE_VERSION=0.8
ARM_TEMPLATE_TAG=1.1.6
RG_TAGS={"Product" : "Get Schools Experience"}
REGION=UK South
SERVICE_NAME=get-schools-experience
SERVICE_SHORT=gse
DOCKER_REPOSITORY=ghcr.io/dfe-digital/schools-experience

ifndef VERBOSE
.SILENT:
endif

help:
	echo "Secrets:"
	echo "  This makefile gives the user the ability to safely display and edit azure secrets which are used by this project. "
	echo ""
	echo "Commands:"
	echo "  edit-app-secrets  - Edit Application specific Secrets."
	echo "  print-app-secrets - Display Application specific Secrets."
	echo ""
	echo "Parameters:"
	echo "All commands take the parameter development|review|test|production"
	echo ""
	echo "Examples:"
	echo ""
	echo "To edit the Application secrets for Development"
	echo "        make  development edit-app-secrets"
	echo ""

APPLICATION_SECRETS=SE-SECRETS
INFRA_SECRETS=SE-INFRA-SECRETS

.PHONY: development
development:
	$(eval export DEPLOY_ENV=dev)
	$(eval export KEY_VAULT=s105d01-kv)
	$(eval export AZURE_SUBSCRIPTION=s105-schoolexperience-development)

.PHONY: development_aks
development_aks:
	$(eval include global_config/development.sh)

.PHONY: set-key-vault-names
set-key-vault-names:
	$(eval KEY_VAULT_APPLICATION_NAME=$(AZURE_RESOURCE_PREFIX)-$(SERVICE_SHORT)-$(CONFIG_SHORT)-app-kv)
	$(eval KEY_VAULT_INFRASTRUCTURE_NAME=$(AZURE_RESOURCE_PREFIX)-$(SERVICE_SHORT)-$(CONFIG_SHORT)-inf-kv)

.PHONY: review
review:
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a pr number for your review app))
	$(eval export PR_NAME=review-school-experience-${PR_NUMBER})
	$(eval export DEPLOY_ENV=review)
	$(eval export SPACE_NAME=get-into-teaching)
	$(eval export KEY_VAULT=s105d01-kv)
	$(eval export AZURE_SUBSCRIPTION=s105-schoolexperience-development)
	$(eval export TF_VAR_paas_application_name=${PR_NAME})
	cf target -s ${SPACE_NAME}
	cf delete-orphaned-routes -f
	$(eval export TF_VAR_static_route=$(shell script/get_next_mapping.sh ${PR_NAME}))
	$(eval BACKEND_KEY=-backend-config=key=${PR_NAME}.tfstate)

.PHONY: staging
staging:
	$(eval export DEPLOY_ENV=staging)
	$(eval export KEY_VAULT=s105t01-kv)
	$(eval export AZURE_SUBSCRIPTION=s105-schoolexperience-test)

.PHONY: production
production:
	$(eval export DEPLOY_ENV=production)
	$(eval export KEY_VAULT=s105p01-kv)
	$(eval export AZURE_SUBSCRIPTION=s105-schoolexperience-production)

.PHONY: ci
ci:
	$(eval AUTO_APPROVE=-auto-approve)

set-azure-account:
	[ "${SKIP_AZURE_LOGIN}" != "true" ] && az account set -s ${AZURE_SUBSCRIPTION} || true

clean:
	[ ! -f fetch_config.rb ]  \
	    rm -f fetch_config.rb \
	    || true

install-fetch-config:
	[ ! -f fetch_config.rb ]  \
	    && echo "Installing fetch_config.rb" \
	    && curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o fetch_config.rb \
	    && chmod +x fetch_config.rb \
	    || true

edit-app-secrets: install-fetch-config set-azure-account
	./fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT}/${APPLICATION_SECRETS} -e -d azure-key-vault-secret:${KEY_VAULT}/${APPLICATION_SECRETS} -f yaml -c

print-app-secrets: install-fetch-config set-azure-account
	./fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT}/${APPLICATION_SECRETS}  -f yaml

edit-infra-secrets: install-fetch-config set-azure-account
	./fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT}/${INFRA_SECRETS} -e -d azure-key-vault-secret:${KEY_VAULT}/${INFRA_SECRETS} -f yaml -c

print-infra-secrets: install-fetch-config set-azure-account
	./fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT}/${INFRA_SECRETS}  -f yaml

composed-variables:
	$(eval RESOURCE_GROUP_NAME=${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-rg)
	$(eval KEYVAULT_NAMES='("${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-app-kv", "${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-inf-kv")')
	$(eval STORAGE_ACCOUNT_NAME=${AZURE_RESOURCE_PREFIX}${SERVICE_SHORT}tfstate${CONFIG_SHORT}sa)

bin/terrafile: ## Install terrafile to manage terraform modules
	curl -sL https://github.com/coretech/terrafile/releases/download/v${TERRAFILE_VERSION}/terrafile_${TERRAFILE_VERSION}_$$(uname)_x86_64.tar.gz \
		| tar xz -C ./bin terrafile

terraform-init-aks: composed-variables bin/terrafile set-azure-account
	$(if ${IMAGE_TAG}, , $(eval IMAGE_TAG=master))

	./bin/terrafile -p terraform/aks/vendor/modules -f terraform/aks/config/$(CONFIG)_Terrafile
	terraform -chdir=terraform/aks init -upgrade -reconfigure \
		-backend-config=resource_group_name=${RESOURCE_GROUP_NAME} \
		-backend-config=storage_account_name=${STORAGE_ACCOUNT_NAME} \
		-backend-config=key=${ENVIRONMENT}_kubernetes.tfstate

	$(eval export TF_VAR_azure_resource_prefix=${AZURE_RESOURCE_PREFIX})
	$(eval export TF_VAR_config_short=${CONFIG_SHORT})
	$(eval export TF_VAR_service_name=${SERVICE_NAME})
	$(eval export TF_VAR_service_short=${SERVICE_SHORT})
	$(eval export TF_VAR_docker_image=${DOCKER_REPOSITORY}:${IMAGE_TAG})

terraform-init: set-azure-account
	$(if $(or $(IMAGE_TAG), $(NO_IMAGE_TAG_DEFAULT)), , $(eval export IMAGE_TAG=master))
	$(if $(IMAGE_TAG), , $(error Missing environment variable "IMAGE_TAG"))
	$(eval export TF_VAR_paas_docker_image=ghcr.io/dfe-digital/schools-experience:$(IMAGE_TAG))

	terraform -chdir=terraform/paas init -reconfigure -upgrade -backend-config=${DEPLOY_ENV}.bk.vars ${BACKEND_KEY}

terraform-plan: terraform-init
	terraform -chdir=terraform/paas plan -var-file=${DEPLOY_ENV}.env.tfvars

terraform-plan-aks: terraform-init-aks
	terraform -chdir=terraform/aks plan -var-file "config/${CONFIG}.tfvars.json"

terraform-apply: terraform-init
	terraform -chdir=terraform/paas apply -var-file=${DEPLOY_ENV}.env.tfvars ${AUTO_APPROVE}

terraform-apply-aks: terraform-init-aks
	terraform -chdir=terraform/aks apply -var-file "config/${CONFIG}.tfvars.json" ${AUTO_APPROVE}

terraform-destroy: terraform-init
	terraform -chdir=terraform/paas destroy -var-file=${DEPLOY_ENV}.env.tfvars ${AUTO_APPROVE}

terraform-destroy-aks: terraform-init-aks
	terraform -chdir=terraform/aks destroy -var-file=config/${CONFIG}.tfvars.json ${AUTO_APPROVE}

delete-state-file:
	az storage blob delete --container-name pass-tfstate --delete-snapshots include --account-name s105d01devstorage -n ${PR_NAME}.tfstate

set-what-if:
	$(eval WHAT_IF=--what-if)

arm-deployment: composed-variables set-azure-account
	$(if ${KEYVAULT_NAMES}, $(eval KV_ARG=keyVaultNames=${KEYVAULT_NAMES}),)

	az deployment sub create --name "resourcedeploy-tsc-$(shell date +%Y%m%d%H%M%S)" \
		-l "${REGION}" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_GROUP_NAME}" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${STORAGE_ACCOUNT_NAME}" "tfStorageContainerName=terraform-state" \
			${KV_ARG} \
			"enableKVPurgeProtection=${KV_PURGE_PROTECTION}" \
			${WHAT_IF}

deploy-arm-resources: arm-deployment

validate-arm-resources: set-what-if arm-deployment
