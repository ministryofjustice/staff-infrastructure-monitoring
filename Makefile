.PHONY: test

test:
	cd test/; docker-compose up -d --remove-orphans; ./run_test.sh
