#!make
include .env
export

fmt:
	terraform fmt --recursive

init:
	aws-vault exec $$AWS_VAULT_PROFILE -- terraform init -reconfigure \
	--backend-config="key=terraform.development.state"

validate:
	aws-vault exec $$AWS_VAULT_PROFILE -- terraform validate

apply:
	aws-vault exec $$AWS_VAULT_PROFILE -- terraform apply

destroy:
	aws-vault exec $$AWS_VAULT_PROFILE -- terraform destroy

clean:
	rm -rf .terraform/ terraform.tfstate*

test:
	cd test/; docker-compose up -d --remove-orphans; ./run_test.sh

.PHONY: init validate apply destroy clean test
