#!make
include .env
export

fmt:
	terraform fmt --recursive

init:
	aws-vault exec $$AWS_VAULT_PROFILE -- terraform init -upgrade -reconfigure \
	--backend-config="key=terraform.development.state"

validate:
	aws-vault exec $$AWS_VAULT_PROFILE -- terraform validate

plan:
	aws-vault exec $$AWS_VAULT_PROFILE -- terraform plan -out terraform.tfplan

apply:
	aws-vault exec $$AWS_VAULT_PROFILE -- terraform apply
	aws-vault exec $$AWS_VAULT_PROFILE -- ./scripts/publish_terraform_outputs.sh

destroy:
	aws-vault exec $$AWS_VAULT_PROFILE -- terraform destroy

test:
	cd test/; docker-compose up -d --remove-orphans; ./run_test.sh

.PHONY: fmt init validate plan apply destroy test
