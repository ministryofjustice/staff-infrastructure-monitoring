#!make
include .env
export

fmt:
	terraform fmt --recursive

init:
	aws-vault clear && aws-vault exec $$AWS_VAULT_PROFILE -- terraform init -reconfigure \
	--backend-config="key=terraform.development.state"

validate:
	aws-vault clear && aws-vault exec $$AWS_VAULT_PROFILE -- terraform validate

plan:
	aws-vault clear && aws-vault exec $$AWS_VAULT_PROFILE -- terraform plan

apply:
	aws-vault clear && aws-vault exec $$AWS_VAULT_PROFILE --duration=2h -- terraform apply

destroy:
	aws-vault clear && aws-vault exec $$AWS_VAULT_PROFILE -- terraform destroy

clean:
	rm -rf .terraform/ terraform.tfstate*

test:
	cd test/; docker-compose up -d --remove-orphans; ./run_test.sh

.PHONY: init validate plan apply destroy clean test
