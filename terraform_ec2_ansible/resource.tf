locals {
  vpc_id          = "vpc-028b7724ac0331752"
  ubuntu_ami      = "ami-0d058fe428540cd89"
  amazonlinux_ami = "ami-02a3575cbd0c8c096" # amzon linux */
  subnet_id       = "subnet-08b1ad0d7506dca3f"
  ssh_user        = "ubuntu"
  key_name        = "vamakp"
  /* private_key_path = "~/PEM/gcc/AIKFUNG/vamakp.pem" */
  private_key_path = "./vamakp.pem"
  instance_name    = "terraform-ansible"
  schedule         = "true"
  project          = "terraform-ansible"
  requestor        = "jain"
  creator          = "jain-terraform"
  public_subnets   = ["subnet-08b1ad0d7506dca3f", "subnet-0e13dde65836782b9"]
  domain_name      = "aipo-imda.net"
  domain_host_name = "rabbitmq"
}

provider "aws" {
  region = "ap-southeast-1"
}



/* resource "aws_security_group" "nginx" {
  name   = "terraform-ansible-sg"
  vpc_id = local.vpc_id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["116.86.133.133/32"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["116.86.133.133/32"]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["sg-021bf7f871be99f3e", "sg-05057e074f565c0fa", "sg-0cc362e87c48e58ce"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.196.250.8/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
} */

resource "aws_instance" "nginx" {
  /* ami = "ami-02a3575cbd0c8c096" # amzon linux */
  ami                         = local.ubuntu_ami # ubuntu20
  subnet_id                   = local.subnet_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = local.key_name

  tags = {
    Name      = local.instance_name
    Scheduled = local.schedule
    Project   = local.project
    Requestor = local.requestor
    Creator   = local.creator
  }
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.nginx.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} nginx.yaml"
  }
  provisioner "local-exec" {
    command =  "echo ssh -i vamakp.pem ubuntu@${aws_instance.nginx.public_ip} > ubuntu.sh"
  }
}

output "nginx_ip" {
  value = aws_instance.nginx.public_ip
}

/* output "anible_playbook_run_command" {
  value = provisioner.local-exec
} */

/* ansible-playbook  -i 18.138.254.157, --private-key vamakp.pem nginx.yaml */