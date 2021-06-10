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

.PHONY: development
development:
	$(eval export KEY_VAULT=s105d01-kv)
	$(eval export AZ_SUBSCRIPTION=s105-schoolexperience-development)

.PHONY: review
review:
	$(eval export KEY_VAULT=s105d01-kv)
	$(eval export AZ_SUBSCRIPTION=s105-schoolexperience-development)

.PHONY: test
test:
	$(eval export KEY_VAULT=s105t01-kv)
	$(eval export AZ_SUBSCRIPTION=s105-schoolexperience-test)

.PHONY: production
production:
	$(eval export KEY_VAULT=s105p01-kv)
	$(eval export AZ_SUBSCRIPTION=s105-schoolexperience-production)

set-azure-account: ${environment}
	echo "Logging on to ${AZ_SUBSCRIPTION}"
	az account set -s ${AZ_SUBSCRIPTION}

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


