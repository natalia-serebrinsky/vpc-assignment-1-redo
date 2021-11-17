resource "aws_vpc" "main"{
	cidr_block = "10.10.0.0/16"
	instance_tenancy = "default"
}

resource "aws_subnet" "public_subnet"{
	count = var.subnets
  vpc_id = aws_vpc.main.id
	cidr_block = var.cidr_block_public[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
      Name = "Public subnet ${count.index}"
  }
}

resource "aws_instance" "web"{
	count = var.web
  instance_type = "t2.micro"
	ami = var.ami
	root_block_device {
    	encrypted   = false
    	volume_type = "gp2"
    	volume_size = var.root_disk_size
  	}
   	user_data = "${file("user-data-nginx.sh")}"
  	tags = {
      Name = "Whiskey ${count.index}"
    	Owner = "whiskey"
  	}
  	#subnet_id = "${aws_subnet.public_subnet.id}"
    subnet_id = aws_subnet.public_subnet.*.id[count.index]
}

resource "aws_subnet" "private_subnet"{
  count = var.subnets
  vpc_id = aws_vpc.main.id
  cidr_block = var.cidr_block_private[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
      Name = "Private subnet ${count.index}"
  }
}

resource "aws_instance" "db"{
  count = var.db
  instance_type = "t2.micro"
  ami = var.ami
  root_block_device {
      encrypted   = false
      volume_type = "gp2"
      volume_size = var.root_disk_size
    }
    subnet_id = aws_subnet.private_subnet.*.id[count.index]
    tags = {
        Name = "DB instance ${count.index}"
    }
}

resource "aws_security_group" "DB_instnaces_access" {
  vpc_id = aws_vpc.main.id
  name   = "DB-access"

  tags = {
    "Name" = "DB-access-${aws_vpc.main.id}"
  }
}

resource "aws_security_group_rule" "DB_ssh_acess" {
  description       = "allow ssh access from anywhere"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.DB_instnaces_access.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "DB_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.DB_instnaces_access.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}