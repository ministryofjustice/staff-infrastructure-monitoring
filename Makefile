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

plan:
	 aws-vault exec $$AWS_VAULT_PROFILE -- terraform plan

apply:
	 aws-vault exec $$AWS_VAULT_PROFILE --duration=2h -- terraform apply

destroy:
	 aws-vault exec $$AWS_VAULT_PROFILE -- terraform destroy

deploy-kubernetes: 
	 aws-vault exec $$AWS_VAULT_PROFILE --no-session -- ./scripts/deploy_kubernetes.sh

test:
	cd test/; docker-compose up -d --remove-orphans; ./run_test.sh

.PHONY: init validate plan apply destroy deploy-kubernetes test
