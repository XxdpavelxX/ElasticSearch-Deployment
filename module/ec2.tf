data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_security_group" "elasticsearch_ec2_secgrp" {
  vpc_id = aws_vpc.elasticsearch_vpc.id
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.instance_sg_ssh_cidr]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 9200
    to_port     = 9200
    cidr_blocks = [var.instance_sg_tcp_cidr]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "elasticsearch-ec2-secgrp"
  }
}

data "template_file" "elasticsearch_ec2_startup" {
  template = file("start-elasticsearch.sh")
}


resource "aws_instance" "elasticsearch_ec2" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.elasticsearch_public_subnet.id
  vpc_security_group_ids = [aws_security_group.elasticsearch_ec2_secgrp.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm-instance-profile.name // Extra for Session Manager access

  user_data = data.template_file.elasticsearch_ec2_startup.rendered

  tags = {
    Name = var.instance_name
  }
}

output "elasticsearch_url" {
  value = "http://${aws_instance.elasticsearch_ec2.public_ip}:9200"
}
