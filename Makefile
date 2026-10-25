commit:
	./update-index.sh
	./auto-commit.sh

plan:
	terraform fmt
	terraform init
	terraform plan