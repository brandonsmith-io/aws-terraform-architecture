# Terraform Associate & Cloud Security Labs

Hands-on infrastructure automation and security labs following HashiCorp Terraform standards and Zero Trust design patterns.

---

## 📂 Lab Index & Navigation
<!-- LAB_INDEX_START -->
| Lab Module | Directory Path |
| :--- | :--- |
| [**01. Ec2 Provisioning**](./01-ec2-provisioning) | `01-ec2-provisioning` |
| [**02. Github Provider**](./02-github-provider) | `02-github-provider` |
| [**03. Iam User**](./03-iam-user) | `03-iam-user` |
| [**04. Provider Versioning**](./04-provider-versioning) | `04-provider-versioning` |
| [**05. Firewall Provision**](./05-firewall-provision) | `05-firewall-provision` |
| [**06. Elastic Ip Creation**](./06-elastic-ip-creation) | `06-elastic-ip-creation` |
| [**07. Attribute Creation**](./07-attribute-creation) | `07-attribute-creation` |
| [**08. Cross Reference Attributes**](./08-cross-reference-attributes) | `08-cross-reference-attributes` |
| [**09. Outputs**](./09-outputs) | `09-outputs` |
| [**10. Variables**](./10-variables) | `10-variables` |
| [**11. Conditional Expression**](./11-conditional-expression) | `11-conditional-expression` |
<!-- LAB_INDEX_END -->
---

## 🛠️ Architecture & Concepts Demonstrated
<!-- LAB_NOTES_START -->
### [01. EC2 Provisioning](./01-ec2-provisioning)
* Configured basic AWS provider authentication.
* Defined and provisioned AWS EC2 compute instances using HCL.
* Validated execution workflow: `terraform init` -> `terraform plan` -> `terraform apply`.
* Enforced clean teardown with `terraform destroy`.

### [02. GitHub Provider](./02-github-provider)
* Configured the `integrations/github` provider from the Terraform Registry.
* Enforced Zero Trust credential hygiene by injecting fine-grained access tokens via process environment variables (`$env:GITHUB_TOKEN`) instead of hardcoding secrets into configuration files.
* Programmatically managed GitHub resources via API using declarative infrastructure code.
* Committed `.terraform.lock.hcl` to ensure dependency pinning and cryptographic checksum validation across environments.

### [03. IAM User](./03-iam-user)
* Programmatically declared and provisioned AWS Identity and Access Management (IAM) user identities via HCL.
* Enforced least-privilege principles and baseline identity governance using declarative infrastructure definitions.
* Validated target resource states and managed teardown via state tracking and clean resource destruction.

### [04. Provider Versioning](./04-provider-versioning)
* Defined explicit version constraints using the pessimistic constraint operator (`~> 5.0`) to prevent breaking API drift across major provider releases.
* Executed dependency upgrades via `terraform init -upgrade` to resolve and bind the latest compliant release (`v5.100.0`).
* Enforced Git tracking of `.terraform.lock.hcl` to validate cryptographic provider hashes and guarantee deterministic execution across CI/CD environments.

### [05. Security Groups & Rule Decoupling](./05-firewall-provision)
Demonstrates provisioning AWS Security Groups and attaching discrete ingress/egress rules using modern standalone rule resources (`aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule`).

* **Rule Decoupling:** Uses standalone rule resources instead of inline security group rule blocks, preventing circular dependencies and state drift when managing complex rule sets across multiple teams.
* **Dynamic Data Source Lookup:** Utilizes `data.aws_security_group.default` to query existing VPC infrastructure at runtime, eliminating brittle hardcoded resource IDs and keeping configurations fully portable across AWS accounts.
* **Resource Referencing (HCL2):** Dynamically binds egress rules directly to the managed security group resource (`aws_security_group.allow_tls.id`) to ensure correct resource graph creation ordering.
* **Verification & State Management:** Verified provider execution in `us-east-1` and validated dynamic security group resolution and lifecycle replacement via `terraform plan` and `terraform apply`.

### [06. Elastic IP Lifecycle & Drift Remediation](./06-elastic-ip-creation)
* Declared and provisioned an AWS Elastic IP (`aws_eip`) allocated for VPC domain scope.
* Managed teardown reconciliation via `terraform destroy` and diagnosed zero-object destruction caused by out-of-band console releases (configuration drift).
* Automated interface documentation generation using `terraform-docs` to track provider bindings and managed resource types.

### [07. Attribute Referencing & Data Sources](./07-attribute-creation)
* Replaced brittle hardcoded AMI IDs with dynamic `data.aws_ami` blocks to continuously query the AWS API for the latest patched Amazon Linux 2023 images.
* Enforced **Implicit Dependencies** within the Terraform dependency graph by passing the EC2 instance ID directly into the Elastic IP allocation block (`instance = aws_instance.web_server.id`).
* Validated execution ordering where Terraform automatically mapped out the required build sequence without relying on explicit `depends_on` flags.

### [08. Cross Reference Attributes](./08-cross-reference-attributes)
* Demonstrated dynamic resource linking by passing an Elastic IP attribute (`public_ip`) directly into a Security Group ingress rule.
* Utilized HCL string interpolation (`"${aws_eip.lb.public_ip}/32"`) to dynamically construct valid CIDR blocks at runtime, preventing the need to hardcode network addresses.
* Reinforced the Terraform dependency graph by mapping implicit dependencies; the security group rule automatically waits for the EIP allocation to complete before provisioning.

### [09. Outputs](./09-outputs)
* Isolated Terraform resource outputs to expose runtime state metadata.
* Extracted scalar IP attributes (`aws_eip.lb.public_ip`) rather than entire raw resource blocks.

### [10. Input Variables](./10-variables)
* Declared reusable input variables with explicit types (`string`, `number`) and defaults.
* Parameterized security group ingress port mappings for dynamic configuration.
* Automated input schema documentation via `terraform-docs`.

### [11. Conditional Expressions](./11-conditional-expression)
* **Ternary Conditional Expressions**: Implemented ternary logic (`condition ? true_val : false_val`) to dynamically toggle instance sizing between `t2.micro` and `m5.large`.
* **Multi-Variable Evaluation**: Chained boolean expressions combining `var.environment == "production"` and `var.region == "us-east-1"` to enforce regional sizing constraints.
* **Declarative Control Flow**: Handled environment branching natively within resource configuration without requiring duplicate resource declarations or external wrapper scripts.
  <!-- LAB_NOTES_END -->
<!-- LAB_NOTES_END -->