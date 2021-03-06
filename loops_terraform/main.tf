data "aws_route53_zone" "ecs_domain" {
  name         = local.domain_name
  private_zone = false
}

data "aws_acm_certificate" "ecs_domain_certificate" {
  domain      = "*.${local.domain_name}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
locals {
  name = "django"
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
  services = ["nginx", "rabbit"]
  environment = "Dev"
  backend_proto    = "HTTP"
  health_check =  {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 10
    path                = "/"
  }
  /* hosts = {
    "nginx" = "nginx"
    "rabbit"    = "rabbitmq"
  }
  ports = {
    "nginx" = "80"
    "rabbit"    = "8080"
  } */
}

variable "hosts" {
  description = "This hosts will be added as dns names and rules for forwarding traffic if you are not sure ask jain"
  /* type        = list(map(string)) */
  default = {
      "nginx" = {
        "tgport"    = "80"
        "tgproto"  = "HTTP"
      },
      "rabbit" = {
        "tgport"    = "15672"
        "tgproto"  = "HTTP"
      }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}


resource "aws_instance" "nginx" {
  /* ami = "ami-02a3575cbd0c8c096" # amzon linux */
  /* name = format("%s-%s", local.name, "ec2") */
  ami                         = local.ubuntu_ami # ubuntu20
  subnet_id                   = local.subnet_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = local.key_name

  tags = {
    Name      = local.name
    Scheduled = local.schedule
    Project   = local.project
    Requestor = local.requestor
    Creator   = local.creator
  }
}


resource "aws_alb" "alb" {
  depends_on         = [aws_security_group.alb]
  name               = format("%s-%s", local.name, "alb")
  subnets            = local.public_subnets
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  internal           = false
  idle_timeout       = 80 #default is 60 
  tags = {
    Name = "terraform-ansible-alb-tf"
  }
  #   access_logs {    
  #     bucket = "${var.s3_bucket}"    
  #     prefix = "ELB-logs"  
  #   }
}

resource "aws_alb_target_group" "alb_target_group" {
  for_each = var.hosts
  /* count        = "${length(var.hosts)}" */
  name         = "${each.key}-Dev"
  port         = "${each.value.tgport}"
  protocol     = "${each.value.tgproto}"
  vpc_id   = local.vpc_id
  /* health_check =  "${local.health_check}" */
  /* health_check = ["${local.healthcheck}"] */
  health_check     {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
  }
  tags = {
    Name      = each.key
    Port = each.value.tgport
  }
}

resource "aws_alb_listener" "alb_listener" {
   depends_on = [aws_alb_target_group.alb_target_group]
  # for_each = aws_alb_target_group.alb_target_group["nginx1"]
  
  load_balancer_arn = aws_alb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  /* ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01" */
  ssl_policy = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
    /* ssl_policy = "" */
  // certificate_arn   = data.aws_acm_certificate.ecs_domain_certificate.arn
  certificate_arn   = data.aws_acm_certificate.ecs_domain_certificate.arn


  default_action {
    #  target_group_arn = "${aws_alb_target_group.alb_target_group[each.key[nginx1]].arn}" 
    #  target_group_arn = lookup(aws_alb_target_group.alb_target_group, "nginx1")
    target_group_arn = aws_alb_target_group.alb_target_group["nginx"].arn
    # target_group_arn = [for m in aws_alb_target_group.alb_target_group : m if contains(keys(m), "nginx")  ]
    type             = "forward"
  }
}





resource "aws_alb_listener_rule" "alb_listener_rabbitmq" {
  for_each = aws_alb_target_group.alb_target_group

  depends_on         = [aws_alb.alb]
  listener_arn = aws_alb_listener.alb_listener.arn

  action {
    /* target_group_arn = aws_alb_target_group.rabbitmq_alb_target_group.arn */
    target_group_arn = each.value.arn
    type             = "forward"
  }
    condition {
    host_header {
      /* values = ["${lower(local.ecs_service_name)}.${data.terraform_remote_state.platform.outputs.ecs_domain_name}"] */
      values = ["${each.value.tags.Name}.${local.domain_name}"]
      # values = ["${lower(local.ecs_service_name)}.vama-dsl.com"]
      #  values = ["${element(values(var.services_map), count.index)}.${var.domain}"]
    }
  }
}

/* output "anible_playbook_run_command" {
  value = provisioner.local-exec
} */

# /* ansible-playbook  -i 18.138.254.157, --private-key vamakp.pem nginx.yaml */

resource "aws_lb_listener" "redirect-http-https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }

  }
}

# data "aws_route53_zone" "ecs_domain" {
#   name         = local.domain_name
#   private_zone = false
# }

# data "aws_acm_certificate" "ecs_domain_certificate" {
#   domain      = "*.${local.domain_name}"
#   types       = ["AMAZON_ISSUED"]
#   most_recent = true
# }
resource "aws_route53_record" "ecs_load_balancer_record" {
  name    = "${local.domain_host_name}.${local.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.ecs_domain.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_alb.alb.dns_name
    zone_id                = aws_alb.alb.zone_id
  }
}

output "route53" {
  value = data.aws_acm_certificate.ecs_domain_certificate
}
output "nginx_ip" {
  value = aws_instance.nginx.public_ip
}
output "aws_target" {
  # value = aws_alb_target_group.alb_target_group
  # value = {for name, role in aws_alb_target_group.alb_target_group: name => role }
  # for_each = aws_alb_target_group.alb_target_group
  # value = aws_alb_target_group.alb_target_group
  # value = {for name, role in aws_alb_target_group.alb_target_group["nginx1"]: name => role.health_check }
  # value = lookup(aws_alb_target_group.alb_target_group, "nginx1")
  # value = aws_alb_target_group.alb_target_group["nginx"]
  value = {for m, r in aws_alb_target_group.alb_target_group : m => r }
}