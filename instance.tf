data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_eip" "ip_for_instance" {
    depends_on = [aws_internet_gateway.internet_gateway]
    instance = aws_instance.demo_instance.id
    vpc      = true
}

# to create instance
resource "aws_instance" "demo_instance" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "${var.instance_type}"
    key_name = data.aws_key_pair.keypair.key_name
    # key_name = aws_key_pair.key-tf.key_name
    user_data = file("${path.module}/script.sh")
    subnet_id = aws_subnet.public_subnet.id
    security_groups = [
        "${aws_security_group.demoSG1.id}"
    ]
    tags = {
        Name = "tf-instance"
    }
}

# generate RSA key using this command > $ ssh-keygen -t rsa

# resource "aws_key_pair" "key-tf" {
#     key_name   = "key-tf"
#     public_key = file("${path.module}/ida_rsa_1.pub")
# }

data "aws_key_pair" "keypair" {
    key_name = "my-keypair"
}

resource "aws_security_group" "demoSG1" {
    name        = "Demo Security Group"
    description = "Demo Module"
    vpc_id = aws_vpc.vpc.id 
    
    # Inbound Rules
    # HTTP access from anywhere
    # introduce dynamic block to run same block of code in an iterative manner using for loop
    dynamic "ingress" {
        for_each = [22, 80, 443]
            iterator = port
        content {
            from_port   = port.value
            to_port     = port.value
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
    # Outbound Rules
    # opening outbound connection for all the ports and IPs.
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        "Name" = "Testing-SG"
    }
}

resource "aws_vpc" "vpc" {
    cidr_block       = var.vpc_cidr_block
    instance_tenancy = "default"
    tags = {
    Name = "practice_vpc"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = var.public_subnet_cidr
    availability_zone = var.availability_zone
    tags = {
    Name = "public subnet"
    }
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "demo_igw"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "dev_public_rt"
    }
}

resource "aws_route" "default_route" {
    route_table_id         = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "mtc_public_assoc" {
    subnet_id      = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}