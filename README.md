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
| [**12. Data Source**](./12-data-source) | `12-data-source` |
| [**13. Graphs**](./13-graphs) | `13-graphs` |
| [**14. Lifecycle Meta Argument**](./14-lifecycle-meta-argument) | `14-lifecycle-meta-argument` |
| [**15. Dependencies Explicit**](./15-dependencies-explicit) | `15-dependencies-explicit` |
| [**16. Dependecies Implicit**](./16-dependecies-implicit) | `16-dependecies-implicit` |
| [**17. Check Block**](./17-check-block) | `17-check-block` |
| [**18. Moved Blocks**](./18-moved-blocks) | `18-moved-blocks` |
<!-- LAB_INDEX_END -->
---

## 🛠️ Architecture & Concepts Demonstrated
<!-- LAB_NOTES_START -->
### [01. Ec2 Provisioning](./01-ec2-provisioning)
* The Terraform configuration establishes a connection with AWS through the `aws` provider, targeting the `us-east-1` region.
* An `aws_instance` resource is created, referencing an `ami` (Amazon Machine Image) ID (`ami-0b245cc5f82576748`) and specifying an instance type (`t2.micro`) for the EC2 instance.
* The `aws_instance` resource depends on the `aws` provider, which enables the creation and management of the underlying AWS infrastructure.









### [02. Github Provider](./02-github-provider)
* The Terraform configuration utilizes the `github` provider version 6.0 or higher, specified using the `~> 6.0` syntax, which enables version locking and dependency management.
* The `github_repository` resource creation depends on the `github` provider, establishing a direct resource dependency between the provider configuration and the resource definition.
* The `github_repository` resource specifies a publicly accessible repository named `example` with a description of "My awesome codebase", relying on the provider's capabilities to interact with the GitHub repository.









### [03. Iam User](./03-iam-user)
* The `aws_iam_user` resource creates an IAM user named "kplabs-demo-user" in the specified region (`us-east-1`). The resource is provisioned through the AWS provider, which is configured to use the specified region.
* The `aws_iam_user` resource has no dependencies on other AWS resources, as it only creates a new IAM user with the specified name.
* The `aws_iam_user` resource is a child resource of the `provider "aws"`, which defines the AWS configuration, including the region, that is applied to all AWS resources created in the configuration.









### [04. Provider Versioning](./04-provider-versioning)
* *aws provider is configured with region "us-east-1", specifying the location for resource creation* 
* The aws provider is versioned to ~> 5.0, utilizing Terraform's version pinning to enforce minimum compatibility* 
* The required_providers block ensures the aws provider is imported before other resources are created, establishing a dependency chain*









### [05. Firewall Provision](./05-firewall-provision)
* The AWS provider is configured to operate within the `us-east-1` region, specifying the target AWS account and geographical location for infrastructure provisioning.
* The `aws_security_group` resource `allow_tls` is dependent on the `aws_vpc_security_group_egress_rule` resource `allow_all_traffic_ipv4`, establishing a security group that allows outbound traffic on all protocols and ports.
* The `aws_vpc_security_group_ingress_rule` resource `allow_tls_ipv4` is dependent on the `data.aws_security_group` resource `default`, referencing the default security group to configure inbound traffic on the `allow_tls` security group.









### [06. Elastic Ip Creation](./06-elastic-ip-creation)
* The Terraform configuration utilizes the AWS provider with a region set to "us-east-1".
* The aws_eip resource is created with an Elastic IP address assigned to a domain of "vpc".
* The creation of the aws_eip resource implicitly depends on the availability of the AWS provider and the region, as well as the existence of a VPC domain.









### [07. Attribute Creation](./07-attribute-creation)
* The `aws_eip` resource depends on the `aws_instance.web_server` resource, establishing a relationship between the Elastic IP and the associated EC2 instance.
* The `aws_instance.web_server` resource depends on the `data.aws_ami.latest_amazon_linux` resource, which provides the ID of the latest Amazon Linux AMI available in the specified region.
* The `data.aws_ami.latest_amazon_linux` resource is configured to fetch the latest AMI by default, with a specific filter for Amazon-provided AMIs that match the specified virtualization type (HVM).









### [08. Cross Reference Attributes](./08-cross-reference-attributes)
* The `aws_vpc_security_group_ingress_rule` resource depends on the `aws_security_group` resource, establishing a bidirectional relationship between the EIP and the security group.
* The `aws_vpc_security_group_ingress_rule` resource references the `public_ip` attribute of the `aws_eip` resource, which is used to define the ingress rule's source IP address.
* The ingress rule's `from_port`, `ip_protocol`, and `to_port` attributes are defined based on the `security_group_id` of the referenced `aws_security_group` resource, establishing a dependency between the security group and the ingress rule.









### [09. Outputs](./09-outputs)
* The Terraform configuration establishes an AWS provider for region "us-east-1" to manage EC2 resources.
* The `aws_eip` resource is created to assign a public IP address to the "lb" instance, which is associated with the "vpc" domain.
* The `output` block exposes the `public_ip` attribute of the `aws_eip` resource as a machine-readable value.









### [10. Variables](./10-variables)
* The AWS Security Group `allow_tls` is the root resource that defines the ingress rules for three separate TCP ports: `app_port`, `ssh_port`, and `ftp_port`, which are controlled by the `aws_vpc_security_group_ingress_rule` resources.
* The `aws_vpc_security_group_ingress_rule` resources are mutually dependent on the `aws_security_group.allow_tls` resource, with the latter's ID being referenced in each rule, and the rules collectively defining the allowed traffic for the security group.
* The variables `vpn_ip`, `app_port`, `ssh_port`, and `ftp_port` are used to parameterize the ingress rules, allowing for fine-grained control over the allowed traffic and enabling efficient management of the infrastructure via Terraform configuration changes.









### [11. Conditional Expression](./11-conditional-expression)
* The `aws_instance` resource utilizes a conditional expression to determine the instance type based on the values of `var.enviroment` and `var.region`. The conditional expression uses logical AND (`&&`) to evaluate the conditions.
* The `aws_instance` resource depends on the values of `var.enviroment` and `var.region`, which are defined as variables that can be overridden during infrastructure provisioning.
* The conditional expression within the `aws_instance` resource's `instance_type` attribute uses the ternary operator (`? :`) to assign different instance types based on the evaluation of the conditions.









### [12. Data Source](./12-data-source)
* The Terraform provider is configured to use AWS, specifying the region as 'us-east-1'.
* The `data "aws_instance" "example"` resource relies on an underlying `aws_instance` resource, which is not explicitly defined in this code snippet.
* The `aws_instance` resource is likely defined elsewhere in the Terraform configuration, potentially in a separate `main.tf` file, due to the use of the `data` block without a local resource definition.









### [13. Graphs](./13-graphs)
* The Terraform `resource` block for `servers` depends on the `count` parameter, which is controlled by the `count` attribute, and is nested within the `terraform_data` resource.
* The `database` resource is an independent, standalone resource that does not depend on any other resource, and has a static `input` attribute set to `"postgresql-v16"`.
* The `server_role_mapping` output utilizes the `zipmap` function to merge the `server_names` and `server_roles` lists into a key-value map, where each key is a server name and the corresponding value is the server's role.









### [14. Lifecycle Meta Argument](./14-lifecycle-meta-argument)
* The `aws_instance` resource is dependent on the `data.aws_ami.amazon_linux` data source, which retrieves the latest Amazon Linux AMI ID based on specified filters.
* The `aws_instance` resource uses the `aws_instance` resource type, but with a custom lifecycle block that ignores changes to the instance during the creation lifecycle.
* The `aws_instance` resource is not provisioned with any specific resource dependencies, relying on the AMI ID and instance type specified in the data source and instance configuration, respectively.









### [15. Dependencies Explicit](./15-dependencies-explicit)
* The Terraform configuration depends on `aws_s3_bucket.mybucket`, indicating a prerequisite for `aws_instance` resources to be created in the same AWS account.
* The `aws_instance` resource is tied to the `aws_ami.amazon_linux` data source, which retrieves the latest Amazon Linux AMI in the specified region.
* The `aws_s3_bucket` resource is used to create a prerequisite resource for `aws_instance`, establishing a dependency between the two Terraform resources.









### [16. Dependecies Implicit](./16-dependecies-implicit)
* The Terraform HCL utilizes the AWS provider to interact with AWS resources, specifying a region of `us-east-1`.
* The `aws_instance` resource depends on the `aws_security_group` resource 'prod', which is referenced in the `vpc_security_group_ids` attribute, establishing a dependency chain.
* The `aws_instance` resource also depends on the `data.aws_ami.amazon_linux` resource, which provides the ID of the Amazon Linux AMI used by the instance, establishing a data source dependency.









### [17. Check Block](./17-check-block)
* The `check` block defines a dependency on the `http` data source, which fetches the status code of the provided URL.
* The `assert` statement within the `check` block depends on the status code returned by the `http` data source, ensuring that the condition is met before the Terraform state is considered valid.
* The `local_file` resource is not dependent on the `check` block and is instead a standalone resource, creating a file with the specified content in the current working directory.









### [18. Moved Blocks](./18-moved-blocks)
* The `aws_security_group` resource is created to apply the "db_firewall" name, which is associated with the security group's identifier (ID).
* The "database_firewall" ID is moved to the "payment_database_firewall" ID, establishing a resource dependency where the latter's existence depends on the former.
* The `aws_security_group` resource is tied to the state of the "payment_database_firewall" resource, with Terraform monitoring any changes to the latter and reapplying its configuration as needed.









<!-- LAB_NOTES_END -->




















