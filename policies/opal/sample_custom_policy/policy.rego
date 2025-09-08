package policies.tf_deny_unencrypted_ec2

input_type := "tf"
resource_type := "aws_instance"

default deny = false

deny[msg] {
  input.resource_type == resource_type
  input_type == "tf"
  not input.config.root_block_device.encrypted
  msg := sprintf("EC2 instance '%s' does not have an encrypted root block device.", [input.name])
}

deny[msg] {
  input.resource_type == resource_type
  input_type == "tf"
  input.config.root_block_device.encrypted == false
  msg := sprintf("EC2 instance '%s' has root_block_device encryption explicitly disabled.", [input.name])
}

