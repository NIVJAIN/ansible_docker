
locals {
  name            = "terraform-ansible"
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
  project          = "testing"
  requestor        = "jain"
  creator          = "jain-terraform"
  public_subnets   = ["subnet-08b1ad0d7506dca3f","subnet-0e13dde65836782b9"]
  domain_name      = "aipo-imda.net"
  domain_host_name = "rabbitmq"
  backend_proto    = "HTTP"
  health_check = {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 10
    path                = "/"
  }
  nlb_config = {
    name        = "${local.name}-NLB"
    internal    = "false"
    environment = "Dev"
    subnet      = local.subnet_id
    nlb_vpc_id  = local.vpc_id
  }
  tg_config = {
    name                  = "${local.name}-nlbtg"
    target_type           = "instance"
    health_check_protocol = "TCP"
    tg_vpc_id             = local.vpc_id
    target_id1            = aws_instance.nginx.id
  }
  forwarding_config = {
    5672 = "TCP"
  }
  hosts2 = {
    "nginx" = {
      "tgport"  = "8080"
      "tgproto" = "HTTP"
    },
    "rabbit" = {
      "tgport"  = "15672"
      "tgproto" = "HTTP"
    }
  }

  # services_map = {
  #   "nginx"    = "8080"
  #   "rabbit"   = "15672"
  #   "rabbitmq" = "5672"
  # }

}
variable "services_map" {
  default = {
    "nginx"    = "8080"
    "rabbit"   = "15672"
    "rabbitmq" = "5672"
  }
}
provider "aws" {
  region = "ap-southeast-1"
}

# variable "hosts2" {
#   description = "This hosts will be added as dns names and rules for forwarding traffic if you are not sure ask jain"
#   /* type        = list(map(string)) */
#   default = {
#     "nginx2" = {
#       "tgport"  = "8080"
#       "tgproto" = "HTTP"
#     },
#     "rabbit2" = {
#       "tgport"  = "15672"
#       "tgproto" = "HTTP"
#     }
#   }
# }


resource "aws_instance" "nginx" {
  /* ami = "ami-02a3575cbd0c8c096" # amzon linux */
  ami                         = local.ubuntu_ami # ubuntu20
  subnet_id                   = local.subnet_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
    # security_groups             = [aws_security_group.nginx.id]  dont use this , when you re run terraform, it will destory and will recreate the resources.
  vpc_security_group_ids             = [aws_security_group.nginx.id]
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
    command = "echo ssh -i vamakp.pem ubuntu@${aws_instance.nginx.public_ip} > ubuntu.sh"
  }
}

output "nginx_ip" {
  value = aws_instance.nginx.public_ip
}

output "route53-2" {
  value = data.aws_acm_certificate.ecs_domain_certificate
}
output "aws_alb" {
  value = aws_alb.alb.dns_name
}
# output "aws_target" {
#   # value = aws_alb_target_group.alb_target_group
#   # value = {for name, role in aws_alb_target_group.alb_target_group: name => role }
#   # for_each = aws_alb_target_group.alb_target_group
#   # value = aws_alb_target_group.alb_target_group
#   # value = {for name, role in aws_alb_target_group.alb_target_group["nginx1"]: name => role.health_check }
#   # value = lookup(aws_alb_target_group.alb_target_group, "nginx1")
#   # value = aws_alb_target_group.alb_target_group["nginx"]
#   value = {for m, r in aws_alb_target_group.alb_target_group : m => r }
# }