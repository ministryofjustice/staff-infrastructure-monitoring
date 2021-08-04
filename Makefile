#!make
include .env
export

fmt:
	terraform fmt --recursive

init:
	aws-vault exec $$AWS_VAULT_PROFILE -- terraform init -reconfigure -upgrade \
	--backend-config="key=terraform.development.state"

validate:
	aws-vault clear $$AWS_VAULT_PROFILE && aws-vault exec $$AWS_VAULT_PROFILE -- terraform validate

plan:
	aws-vault clear $$AWS_VAULT_PROFILE && aws-vault exec $$AWS_VAULT_PROFILE -- terraform plan

apply:
	aws-vault exec $$AWS_VAULT_PROFILE --duration=2h -- terraform apply
	aws-vault exec $$AWS_VAULT_PROFILE -- ./scripts/publish_terraform_outputs.sh

destroy:
	aws-vault clear $$AWS_VAULT_PROFILE && aws-vault exec $$AWS_VAULT_PROFILE -- terraform destroy

test:
	cd test/; docker-compose up -d --remove-orphans; ./run_test.sh

.PHONY: fmt init validate plan apply destroy test
