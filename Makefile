AWS_REGION ?= eu-central-1
USER_NAME ?= francky
EMAIL ?= changeMe


help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'



infrastructure: ## Build the infrastructure
infrastructure: 
	$(MAKE) -C terraform infrastructure
	@$(MAKE) -C terraform show-outputs > .tmp-terraform-outputs.json


create-user: ## Create a User in the Cognito UserPools to use the platform
create-user: .infrastructure-outputs
	@sh ./tools/create-user.sh $(AWS_REGION) $(COGNITO_USERPOOL_ID) $(USER_NAME) $(COGNITO_GROUP_NAME) $(EMAIL)
	@echo "Save the JWT tocken produced"
	@sh ./tools/change-password.sh $(USER_NAME) $(COGNITO_USERPOOL_ID) $(COGNITO_CLIENT_ID) $(AWS_REGION)


get-user-jwt-token: ## Authentificate the user again
get-user-jwt-token: .infrastructure-outputs
	@sh ./tools/authenticate-user.sh $(USER_NAME) $(COGNITO_USERPOOL_ID) $(COGNITO_CLIENT_ID) $(AWS_REGION)


.infrastructure-outputs-show:
	@$(MAKE) -C terraform show-outputs

.infrastructure-outputs:
	@$(eval COGNITO_USERPOOL_ID := $(shell make .infrastructure-outputs-show | jq '.cognito_user_pool_id'))
	@$(eval COGNITO_CLIENT_ID := $(shell make .infrastructure-outputs-show | jq '.cognito_client'))
	@$(eval COGNITO_GROUP_NAME := $(shell make .infrastructure-outputs-show | jq '.cognito_group_name'))