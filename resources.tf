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
