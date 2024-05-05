# Find the Main VPC
data "aws_vpc" "selected" {
  default = true
}

# Find the AMI of Amazon Linux 2023
data "aws_ami" "al2023" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Find the subnets of Main VPC
data "aws_subnets" "phonebook-app-subnets" {
  filter {
    name   = "vpc-id"
    values = [ data.aws_vpc.selected.id ]
  }
}

# Find my Github Token from AWS Parameter Store
data "aws_ssm_parameter" "github-token" {
  name = "/phonebook/github/token"
}