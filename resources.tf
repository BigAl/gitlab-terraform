resource "aws_db_subnet_group" "gitlab_pgsql" {
  name = "gitlab_pgsql"
# Need to change these to ones we have in other subnet
#  subnet_ids = ["${aws_subnet.kops_suba.id}", "${aws_subnet.kops_subb.id}", "${aws_subnet.kops_subc.id}"]
  subnet_ids = ["subnet-4968252c", "subnet-26d2d80b"]
  tags {
    Name = "Gitlab PgSQL"
  }
}
resource "aws_db_parameter_group" "gitlab_pgsql" {
  name   = "gitlab-pg"
  family = "postgres9.3"
}

resource "aws_iam_role" "role" {
  name = "gitlab-role"

  assume_role_policy = "${data.aws_iam_policy_document.ec2-allow-assume-policy.json}"
}

resource "aws_iam_instance_profile" "app_profile" {
  name  = "gitlab-profile"
  role = "${aws_iam_role.role.name}"
}

# security group for EC2 instanace
resource "aws_security_group" "instance" {
  name        = "gitlab_instance_sg"
  description = "gitlab instance security group"
  vpc_id      = "${var.gitlab_vpc_id}"

# review this it should be restrictred to only from elb SG
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
