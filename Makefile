#!make
include .env
export

fmt:
	terraform fmt --recursive

init:
	aws-vault clear $$AWS_VAULT_PROFILE && aws-vault exec $$AWS_VAULT_PROFILE -- terraform init -reconfigure \
	--backend-config="key=terraform.development.state"

validate:
	aws-vault clear $$AWS_VAULT_PROFILE && aws-vault exec $$AWS_VAULT_PROFILE -- terraform validate

plan:
	aws-vault clear $$AWS_VAULT_PROFILE && aws-vault exec $$AWS_VAULT_PROFILE -- terraform plan

apply:
	aws-vault clear $$AWS_VAULT_PROFILE && aws-vault exec $$AWS_VAULT_PROFILE --duration=2h -- terraform apply

destroy:
	aws-vault clear $$AWS_VAULT_PROFILE && aws-vault exec $$AWS_VAULT_PROFILE -- terraform destroy

deploy-kubernetes: 
	aws-vault clear $$AWS_VAULT_PROFILE && TF_VAR_thanos_image_repository_url=.dkr.ecr.eu-west-2.amazonaws.com/thanos aws-vault exec $$AWS_VAULT_PROFILE --no-session -- ./scripts/deploy_kubernetes.sh

test:
	cd test/; docker-compose up -d --remove-orphans; ./run_test.sh

.PHONY: init validate plan apply destroy deploy-kubernetes test
