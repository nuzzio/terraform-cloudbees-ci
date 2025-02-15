resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.nat.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = merge({Name = "${var.resource_prefix}-bastion"}, var.extra_tags)
}

data "aws_ami" "nat" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat*"]
  }
}

resource "aws_security_group" "bastion" {
  description = "Security group for the bastion server"
  name        = "${var.resource_prefix}-bastion"
  vpc_id      = var.vpc_id

  tags = var.extra_tags
}

resource "aws_security_group_rule" "bastion_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  to_port           = 65535
  type              = "egress"
}

resource "aws_security_group_rule" "bastion_ingress" {
  cidr_blocks       = var.ssh_cidr_blocks
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "node_bastion" {
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = var.source_security_group_id
  source_security_group_id = aws_security_group.bastion.id
  to_port                  = 22
  type                     = "ingress"
}
