variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "availability_zone" {
	default = ["us-east-1a","us-east-1c"]
	type    = list(string)
}

variable "cidr_block_public"{
	default = ["10.10.2.0/24", "10.10.3.0/24"]
	type = list(string)
}

variable "cidr_block_private"{
	default = ["10.10.4.0/24", "10.10.5.0/24"]
	type = list(string)
}

variable "ami"{
	default = "ami-0279c3b3186e54acd"
}

variable "root_disk_size"{
	default = "8"
}

variable "subnets"{
	default = 2
}
variable "db"{
	default = 2
}
variable "web"{
	default = 2
}
variable "natgw"{
	default = 2
}
variable "route_tables_names" {
  type    = list(string)
  default = ["public", "private-a", "private-b"]
}