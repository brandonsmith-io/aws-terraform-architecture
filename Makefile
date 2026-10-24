commit:
	git add .
	git commit -m "$(m)"
	git push -u origin main

plan:
	terraform fmt
	terraform init
	terraform plan