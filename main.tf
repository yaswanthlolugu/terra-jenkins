
provider "aws" {
  region = var.region
}
resource "aws_vpc" "petclinic" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.envname}-vpc"
  }
}

#subnets

resource "aws_subnet" "pubsubnet" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.petclinic.id
  cidr_block              = element(var.pubsubnets, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.envname}-pubsunet-${count.index + 1}"
  }
}


resource "aws_subnet" "privatesubnet" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.petclinic.id
  cidr_block        = element(var.privatesubnets, count.index)
  availability_zone = element(var.azs, count.index)


  tags = {
    Name = "${var.envname}-privatesunet-${count.index + 1}"
  }
}

resource "aws_subnet" "datasubnet" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.petclinic.id
  cidr_block        = element(var.datasubnets, count.index)
  availability_zone = element(var.azs, count.index)


  tags = {
    Name = "${var.envname}-datasubnets t-${count.index + 1}"
  }
}


#igw and attache vpcterraform {

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.petclinic.id

  tags = {
    Name = "${var.envname}-igw"
  }
}

#eip

resource "aws_eip" "natip" {
  vpc = true
  tags = {
    name = "${var.envname}-natip"
  }
}
#nat in the pubsubnet

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natip.id
  subnet_id     = aws_subnet.pubsubnet[0].id

  tags = {
    Name = "${var.envname}-natgw"
  }
}

#public route table
resource "aws_route_table" "publicroute" {
  vpc_id = aws_vpc.petclinic.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.envname}-publicroute"
  }
}

#private route
resource "aws_route_table" "privateroute" {
  vpc_id = aws_vpc.petclinic.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "${var.envname}-privateroute"
  }
}

#data route

resource "aws_route_table" "dataroute" {
  vpc_id = aws_vpc.petclinic.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "${var.envname}-dataroute"
  }
}

resource "aws_route_table_association" "pubsubassociation" {
  count          = length(var.pubsubnets)
  subnet_id      = element(aws_subnet.pubsubnet.*.id, count.index)
  route_table_id = aws_route_table.publicroute.id
}


resource "aws_route_table_association" "prisubassociation" {
  count          = length(var.privatesubnets)
  subnet_id      = element(aws_subnet.privatesubnet.*.id, count.index)
  route_table_id = aws_route_table.privateroute.id
}


resource "aws_route_table_association" "datasubassociation" {
  count          = length(var.datasubnets)
  subnet_id      = element(aws_subnet.datasubnet.*.id, count.index)
  route_table_id = aws_route_table.dataroute.id
}

