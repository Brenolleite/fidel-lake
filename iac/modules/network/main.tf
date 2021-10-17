resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  

  tags = {
    Name = "fidel-vpc"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = "${aws_vpc.main.id}"

  count = "${length(data.aws_availability_zones.available.names)}"  
  cidr_block = "10.0.${count.index}.0/24"

  availability_zone= "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false

  tags = {
        Name = "fidel-private-subnet-${count.index + 1}"
  }
}

/*
No need for public subnets
resource "aws_subnet" "public_subnet" {  
  vpc_id = "${aws_vpc.main.id}"

  count = "${length(data.aws_availability_zones.available.names)}"  
  cidr_block = "10.0.${10 + count.index}.0/24"
  
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "fidel-public-subnet-${count.index + 1}"
  }
}
*/