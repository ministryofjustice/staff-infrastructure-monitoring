.PHONY: test

test:
	cd test/; docker-compose up -d --remove-orphans; ./run_test.sh

fmt: 
	terraform fmt --recursive

apply:
	aws-vault exec moj-pttp-shared-services -- terraform apply
