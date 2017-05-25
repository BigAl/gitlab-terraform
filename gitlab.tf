# What we need
# Postgress DB (done)
# Redis (done)
# Shared filesystem (done)
# ASG with gitlab image ( need correct AMI for us-east-1)
# ELB (done) Needs to be changed to https
# Security groups ( done )
#  EC2 can talk to REDIS
#  EC2 can talk to postgres
#  ELB can to to EC2
# Created elsewhere VPC and subnets. ( Use demo account for now )
# EFS working and mount via userdata (done)
# Need to do gtilab configuration steps


data "template_file" "userdata" {
  template = "${file("${path.module}/templates/userdata.tpl")}"

  vars {
    fs_id = "${module.efs_mount.file_system_id}"
    region = "${data.aws_region.current.name}"
    db_database = "${var.db_database}"
    db_username = "${var.db_username}"
    db_password = "${var.db_password}"
    db_host = "${module.postgresql_rds.endpoint}"
    db_port = "${var.db_port}"
    redis_host = "${module.redis.endpoint}"
    redis_port = "${var.redis_port}"
    mount_point = "${var.mount_point}"
  }
}

data "aws_region" "current" {
  current = true
}

resource "aws_sns_topic" "gitlab_pgsql_threshold" {
  name = "gitlab-pgsql-threshold-topic"
}

module "postgresql_rds" {
  source = "github.com/azavea/terraform-aws-postgresql-rds"
  vpc_id = "${var.vpc_id}"
  allocated_storage = "50"
  engine_version = "9.5.6"
  instance_type = "db.t2.medium"
  storage_type = "gp2"
  database_identifier = "${var.project}-pgsql"
  database_name = "${var.db_database}"
  database_username = "${var.db_username}"
  database_password = "${var.db_password}"
  database_port = "${var.db_port}"
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

  project = "${var.project}"
  environment = "${var.env}"
}

module "efs_mount" {
  source = "github.com/BigAl/tf_efs_mount"

  name    = "gitlab-nfs"
  subnets = "${var.data_subnets}"
  vpc_id  = "${var.vpc_id}"

}

module "redis" {
  source         = "github.com/BigAl/tf_aws_elasticache_redis?ref=aviod_count_compute"
  env            = "${var.env}"
  name           = "${var.project}"
  redis_clusters = "2"
  redis_failover = "true"
  subnets        = "${var.data_subnet_list}"
  vpc_id         = "${var.vpc_id}"
  allowed_security_groups = ["${aws_security_group.instance.id}"]
}

module "gitlab_asg" {
  source = "github.com/BigAl/tf_aws_asg_elb"
  lc_name = "${var.lc_name}"
  ami_id = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.app_profile.id}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.instance.id}", "${module.efs_mount.ec2_security_group_id}"]
  user_data = "${data.template_file.userdata.rendered}"
  asg_name = "${var.asg_name}"
  asg_number_of_instances = "${var.asg_number_of_instances}"
  asg_minimum_number_of_instances = "${var.asg_minimum_number_of_instances}"
  load_balancer_names = "${aws_elb.gtilab.name}"
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
