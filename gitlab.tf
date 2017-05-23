# What we need
# Postgress DB (done)
# Redis (done)
# Shared filesystem (done)
# ASG with gitlab image ( need correct AMI for us-east-1)
# ELB (done)
# Security groups ( WPA )
# Created elsewhere VPC and subnets. ( Use demo account for now )

resource "aws_sns_topic" "gitlab_pgsql_threshold" {
  name = "gitlab-pgsql-threshold-topic"
}

module "postgresql_rds" {
  source = "github.com/azavea/terraform-aws-postgresql-rds"
  vpc_id = "${var.vpc_id}"
  allocated_storage = "50"
  engine_version = "9.3.14"
  instance_type = "db.t2.medium"
  storage_type = "gp2"
  database_identifier = "gitlab-pgsql"
  database_name = "gitlab_production"
  database_username = "gtilab"
  database_password = "password"
  database_port = "5432"
  backup_retention_period = "30"
  backup_window = "04:00-04:30"
  maintenance_window = "sun:04:30-sun:05:30"
  auto_minor_version_upgrade = false
  multi_availability_zone = true
  storage_encrypted = false
  subnet_group = "${aws_db_subnet_group.gitlab_pgsql.name}"
  parameter_group = "${aws_db_parameter_group.gitlab_pgsql.name}"

  alarm_cpu_threshold = "75"
  alarm_disk_queue_threshold = "10"
  alarm_free_disk_threshold = "5000000000"
  alarm_free_memory_threshold = "128000000"
  alarm_actions = ["${aws_sns_topic.gitlab_pgsql_threshold.arn}"]

  project = "gitlab"
  environment = "${var.env}"
}

module "efs_mount" {
  source = "github.com/manheim/tf_efs_mount"

  name    = "gitlab-nfs"
  subnets = "${var.data_subnets}"
  vpc_id  = "${var.vpc_id}"

}

module "redis" {
  source         = "github.com/BigAl/tf_aws_elasticache_redis?ref=remove-vpc-tags"
  env            = "${var.env}"
  name           = "${var.project}"
  redis_clusters = "2"
  redis_failover = "true"
  subnets        = "${var.data_subnet_list}"
  vpc_id         = "${var.vpc_id}"
}

module "gitlab_asg" {
  source = "github.com/terraform-community-modules/tf_aws_asg_elb"
  lc_name = "${var.lc_name}"
  ami_id = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.app_profile.id}"
  key_name = "${var.key_name}"
  security_group = "${aws_security_group.instance.id}"
  user_data = "${var.user_data_file}"
  asg_name = "${var.asg_name}"
  asg_number_of_instances = "${var.asg_number_of_instances}"
  asg_minimum_number_of_instances = "${var.asg_minimum_number_of_instances}"
  load_balancer_names = "${var.elb_names}"
  health_check_type = "${var.health_check_type}"
  availability_zones = "${var.availability_zones}"
  vpc_zone_subnets = "${var.private_subnets}"
}

# Add EC2 security group to database_security_group_id
resource "aws_security_group_rule" "PostgresIngress200" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = "${module.postgresql_rds.database_security_group_id}"
  source_security_group_id = "${aws_security_group.instance.id}"
}
