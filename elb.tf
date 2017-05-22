## re-wtite as a module
resource "aws_elb" "web-elb" {
  name = "${var.project}-elb"

  subnets = "${var.private_subnets}"
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
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

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
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
