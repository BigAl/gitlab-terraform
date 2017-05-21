variable "gitlab_vpc_id" {
  type        = "string"
  default     = "vpc-01537b67"
}

variable "env" {
  type        = "string"
  default     = "Production"
}

variable "lc_name" {
  default = "gtilab-lc"
}
## find the gitlab ami
variable "ami_id" {
  default = "ami-sadfasd"
}
variable "instance_type" {
  default = "t2.medium"
}
variable "iam_instance_profile" {
  default = "gitlab_profile"
}
variable "key_name" {
  default = "Platfrom"
}
variable "security_group_id" {
  default = "sg-abcdef"
}
variable "user_data_file" {
  default = ""
}
variable "asg_name" {
  default = "gtilab-asg"
}
variable "asg_number_of_instances" {
  default = 2
}
variable "asg_minimum_number_of_instances" {
  default = 1
}
variable "elb_names" {
  default = "gitlab-elb"
}
variable "health_check_type" {
  default = "ELB"
}
variable "availability_zones" {
  default = "us-east-1a,us-east-1b"
}
variable "vpc_zone_subnets" {
default = "subnet-4968252c, subnet-26d2d80b"
}
