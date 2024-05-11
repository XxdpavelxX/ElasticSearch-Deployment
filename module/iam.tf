resource "aws_iam_instance_profile" "ssm-instance-profile" {
  name = "ssm_ec2_profile"
  role = aws_iam_role.ssm-ec2-role.name
}

resource "aws_iam_role" "ssm-ec2-role" {
  name               = "ssm-ec2-role-${var.stage_name}"
  description        = "Role for SSM access to EC2 instances"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2-ssm-policy" {
  role       = aws_iam_role.ssm-ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
