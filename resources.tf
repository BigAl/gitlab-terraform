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
  family = "postgres9.6"
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
  vpc_id      = "${var.vpc_id}"

  # HTTP access from ELB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }
  # temporary SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.38.29/32"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
