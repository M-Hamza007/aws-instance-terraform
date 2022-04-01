## How to SSH into aws instance

There are two methods to SSH in AWS instance:

### 1. First method:

generate a rsa key using the below mentioned command:

```
ssh-keygen -t rsa
```

then create a key_pair resource using the code:

```
 resource "aws_key_pair" "key-tf" {
    key_name   = "key-tf"
    public_key = file("${path.module}/<enter_public_key_filename_here>")
 }
```

then ssh into the created aws instance using private key:

```
ssh -i <enter_private_key_filename_here> ubuntu@<ip_of_instance>
or
ssh -i C:\Users\xFlow\.ssh\my-keypair.pem ubuntu@<ip_of_instance>
```

### 2. Second method:

If key-pair resource is already created

then you will have private key downloaded, paste that private key file in C:\Users\xFlow\.ssh\

mention that pre-created key-pair as aws instance attribute, which we get by using data source, for example:
```
key_name = data.aws_key_pair.keypair.key_name
```
```
data "aws_key_pair" "keypair" {
    key_name = "<key_pair_resource_name>"
}
```
then ssh into the created aws instance using private key:

```
ssh -i C:\Users\xFlow\.ssh\my-keypair.pem ubuntu@<ip_of_instance>
```

____________________________________________________________________

### Notes:

* "${path.module}" --> it just print the directory of the module

* Resource: aws_route. Provides a resource to create a routing table entry (a route) in a VPC routing table.

* AWS Route Table Association:
Your VPC has an implicit router, and you use route tables to control where network traffic is directed. Each subnet in your VPC must be associated with a route table, which controls the routing for the subnet (subnet route table). You can explicitly associate a subnet with a particular route table.

