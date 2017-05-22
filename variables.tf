variable "project" {
  type        = "string"
  default     = "gitlab"
}

variable "vpc_id" {
  type        = "string"
  default     = "vpc-01537b67"
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
## Gitab CE ami 9.0.2 release 21/4/2017
# Asia Pacific (Mumbai)	ami-9a4033f5
# EU (London)	ami-a0190dc4
# EU (Ireland)	ami-6f86b809
# Asia Pacific (Seoul)	ami-6b974505
# Asia Pacific (Tokyo)	ami-bbc7e0dc
# South America (Sao Paulo)	ami-4b593a27
# Canada (Central)	ami-c703bea3
# Asia Pacific (Singapore)	ami-48902f2b
# Asia Pacific (Sydney)	ami-c3919ea0
# EU (Frankfurt)	ami-6328f80c
# US East (N. Virginia)	ami-81991f97
# US East (Ohio)	ami-1dfade78
# US West (N. California)	ami-19461c79
# US West (Oregon)	ami-7c099e1c

variable "ami_id" {
  default = "ami-81991f97"
}
variable "instance_type" {
  default = "t2.medium"
}
variable "key_name" {
  default = "gitlab-test"
}
variable "user_data_file" {
  default = "userdata.sh"
}
variable "asg_name" {
  default = "gitlab-asg"
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
variable "data_subnet_list" {
  type = "list"
  default = ["subnet-4968252c", "subnet-26d2d80b"]
}
variable "data_subnets" {
  default = "subnet-4968252c,subnet-26d2d80b"
}
variable "unsafe_subnets" {
  default = "subnet-d66528b3,subnet-42dcd66f"
}
variable "private_subnets" {
  default = "subnet-73d0da5e,subnet-4e6a272b"
}
variable "dmz_subnets" {
  default = "subnet-2d652848,subnet-43dcd66e"
}
variable "dmz_subnet_list" {
  type        = "list"
  default     = ["subnet-2d652848", "subnet-43dcd66e"]
}
