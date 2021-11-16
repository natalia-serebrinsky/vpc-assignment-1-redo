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

##### application load balancer####
resource "aws_lb" "web" {
	subnets = aws_subnet.public_subnet.*.id
  	tags = {
      Name = "Application Load Balancer"
  	}
}
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb_target_group" "web" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled = true
    path    = "/"
  }

  tags = {
    "Name" = "web-target-group-${aws_vpc.main.id}"
  }
}

resource "aws_lb_target_group_attachment" "web_server" {
  count            = length(aws_instance.web)
  target_group_arn = aws_lb_target_group.web.id
  target_id        = aws_instance.web.*.id[count.index]
  port             = 80
}