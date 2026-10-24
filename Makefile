commit:
	./auto-commit.sh
	./update-index.sh

plan:
	terraform fmt
	terraform init
	terraform plan