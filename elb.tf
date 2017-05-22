## re-wtite as a module
resource "aws_elb" "web-elb" {
  name = "${var.project}-elb"

  subnets = "${var.dmz_subnet_list}"
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
# once we have a certificate_domain enable this
#    ssl_certificate_id = "${data.aws_acm_certificate.ssl_certificate_id.arn}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/healthcheck/heartbeat"
    interval            = 5
  }

  tags {
    Name = "${var.project}-elb"
  }
}

resource "aws_security_group" "elb" {
  name        = "${var.project}_elb_sg"
  description = "${var.project} elb security group"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "${var.project}_sg"
  }

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
