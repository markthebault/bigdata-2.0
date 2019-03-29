SHELL := /bin/bash

help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'


.build_lambdas:
	$(MAKE) -C ./lambdas/lambda_authorizer


infrastructure: ## Infrastructure
infrastructure: .build_lambdas
	terraform init
	terraform apply -auto-approve

