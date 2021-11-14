resource "aws_internet_gateway" "igw"{
	vpc_id = aws_vpc.main.id
	tags = {
      Name = "Igw terraform vpc"
  	}
}
resource "aws_eip" "elastic_ip"{
	vpc = true
	count = 2
	tags = {
      Name = "eip ${count.index}"
  	}
}
resource "aws_nat_gateway" "natgw"{
	count = var.natgw
	subnet_id = aws_subnet.public_subnet.*.id[count.index]
	tags = {
      Name = "natgw ${count.index}"
  	}
  	allocation_id = aws_eip.elastic_ip.*.id[count.index]
}