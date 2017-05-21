# What we need
# Postgress DB
# Redis
# Shared filesystem
# ASG with gitlab image
# ELB
# Security groups
# Created elsewhere VPC and subnets.

module "postgresql_rds" {
  source = "github.com/azavea/terraform-aws-postgresql-rds"
  vpc_id = "${var.gitlab_vpc_id}"
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
  alarm_actions = ["arn:aws:sns..."]

  project = "gitlab"
  environment = "${var.env}"
}

module "efs_mount" {
  source = "github.com/manheim/tf_efs_mount"

  name    = "gitlab-nfs"
  subnets = "subnet-4968252c, subnet-26d2d80b"
  vpc_id  = "${var.gitlab_vpc_id}"

}

module "redis" {
  source         = "github.com/FitnessKeeper/terraform-redis-elasticache?ref=1.0.0"
  env            = "${var.env}"
  name           = "gitlab"
  redis_clusters = "2"
  redis_failover = "true"
  subnets        = ["subnet-4968252c", "subnet-26d2d80b"]
  vpc_id         = "${var.gitlab_vpc_id}"
}

module "gitlab_asg" {
  source = "github.com/terraform-community-modules/tf_aws_asg_elb"
  lc_name = "${var.lc_name}"
  ami_id = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  key_name = "${var.key_name}"
  security_group = "${var.security_group_id}"
  user_data = "${var.user_data_file}"
  asg_name = "${var.asg_name}"
  asg_number_of_instances = "${var.asg_number_of_instances}"
  asg_minimum_number_of_instances = "${var.asg_minimum_number_of_instances}"
  load_balancer_names = "${var.elb_names}"
  health_check_type = "${var.health_check_type}"
  availability_zones = "${var.availability_zones}"
  vpc_zone_subnets = "${var.vpc_zone_subnets}"
}
