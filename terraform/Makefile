SHELL := /bin/bash

help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'



infrastructure: ## Build the Infrastructure
infrastructure: .build_lambdas
	terraform init
	terraform apply -auto-approve


show-outputs: ## Show the output results of the infrastructure
show-outputs:
	@sh terraform-outputs-to-pretty-json.sh

.build_lambdas:
	$(MAKE) -C ./lambdas/lambda_authorizer