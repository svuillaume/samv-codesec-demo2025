package policies.tf_sg_ssh_strict_ip

input_type := "tf"
resource_type := "aws_security_group"

default deny = false

deny[msg] {
  input.resource_type == resource_type
  input_type == "tf"
  some i
  rule := input.ingress[i]

  not ssh_from_trusted_ip(rule)

  msg := sprintf("Security Group '%s' has non-compliant ingress rule: from_port=%d to_port=%d protocol=%s cidr_blocks=%v",
    [input.name, rule.from_port, rule.to_port, rule.protocol, rule.cidr_blocks])
}

ssh_from_trusted_ip(rule) {
  rule.from_port == 22
  rule.to_port == 22
  rule.protocol == "tcp"
  rule.cidr_blocks == ["192.10.10.100/32"]
}

