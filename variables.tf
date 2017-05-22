variable "project" {
  type        = "string"
  default     = "gitlab"
}

variable "vpc_id" {
  type        = "string"
  default     = "vpc-01537b67"
}

variable "private_subnets" {
  type        = "list"
  default = ["subnet-4968252c", "subnet-26d2d80b"]
}

variable "certificate_domain" {
  default = "*.cloudops.aconex.com"
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
variable "key_name" {
  default = "Platfrom"
}
variable "user_data_file" {
  default = "userdata.sh"
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
