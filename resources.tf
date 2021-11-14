resource "aws_vpc" "main"{
	cidr_block = "10.10.0.0/16"
	instance_tenancy = "default"
}

resource "aws_subnet" "public_subnet"{
	count = var.subnets
  vpc_id = aws_vpc.main.id
	cidr_block = var.cidr_block[count.index]
  availability_zone = var.availability_zone[count.index]
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
    	Owner = "whiskey"
    	Server_name = "whiskey"
  	}
  	#subnet_id = "${aws_subnet.public_subnet.id}"
    subnet_id = aws_subnet.public_subnet.*.id[count.index]
}

resource "aws_subnet" "private_subnet"{
  count = var.subnets
  vpc_id = aws_vpc.main.id
  cidr_block = var.cidr_block[count.index]
  availability_zone = var.availability_zone[count.index]
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
}