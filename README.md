<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.ssl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_autoscaling_group.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_launch_configuration.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_lb.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_desired_asg_size"></a> [desired\_asg\_size](#input\_desired\_asg\_size) | Desired size for the Autoscaling group | `number` | `2` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use for the web server. Defaulted to a smaller one for testing. | `string` | `"t2.micro"` | no |
| <a name="input_max_asg_size"></a> [max\_asg\_size](#input\_max\_asg\_size) | Maximum size for the Autoscaling group | `number` | `10` | no |
| <a name="input_min_asg_size"></a> [min\_asg\_size](#input\_min\_asg\_size) | Minimum size for the Autoscaling group | `number` | `1` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | Private subnets for the EC2s | `list` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Name for the project to be deployed | `string` | `"hello-world"` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Public subnets for the LB | `list` | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | VPC to deploy to | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
