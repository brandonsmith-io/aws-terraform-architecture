<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.68.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_security_group.allow_tls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_ingress_rule.app_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ftp_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ssh_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_app_port"></a> [app\_port](#input\_app\_port) | Target application listening port | `string` | `"8080"` | no |
| <a name="input_ftp_port"></a> [ftp\_port](#input\_ftp\_port) | File Transfer Protocol listening port | `string` | `"21"` | no |
| <a name="input_ssh_port"></a> [ssh\_port](#input\_ssh\_port) | Secure Shell ingress port for management | `string` | `"22"` | no |
| <a name="input_vpn_ip"></a> [vpn\_ip](#input\_vpn\_ip) | this is a vpn server created in AWS | `string` | `"200.20.30.50/32"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->