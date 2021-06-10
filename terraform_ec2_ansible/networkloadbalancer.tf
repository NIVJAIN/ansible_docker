# # variables.tf
# variable "nlb_config" {
#   default = {
#     name            = "terraform-nlb"
#     internal        = "false"
#     environment     = "test"
#     subnet          = local.subnet_id
#     nlb_vpc_id      = local.vpc_id
#   }
# }
# variable "tg_config" {
#   default = {
#     name                              = "terraform-nlb-tg"
#     target_type                       = "instance"
#     health_check_protocol             = "TCP"
#     tg_vpc_id                         = local.vpc_id
#     target_id1                        = aws_instance.nginx.id
#   }
# }
# variable "forwarding_config" {
#   default = {
#       5672        =   "TCP"
#       # 80       =   "TCP" # and so on
#     #   443       =   "TCP" # and so on
#   }
# }

//nlb.tf
# resource "aws_eip" "eip_nlb" {
#   tags    = {
#     Name  = "test-network-lb-eip"
#     Env   = "test"
#   }
# }
# nlb
# add nlb
resource "aws_lb" "nlb_load_balancer" {
#   name                              = "test-network-lb" #can also be obtained from the variable nlb_config
  name = lookup(local.nlb_config,"name")
  load_balancer_type                = "network"
  subnet_mapping {
    subnet_id     = lookup(local.nlb_config,"subnet")
    # allocation_id = aws_eip.eip_nlb.id
  }
  tags = {
    Environment = lookup(local.nlb_config,"environment")
  }
}
resource "aws_lb_listener" "listener" {
  load_balancer_arn       = aws_lb.nlb_load_balancer.arn
  for_each = local.forwarding_config
      port                = each.key
      protocol            = each.value
      default_action {
        target_group_arn = "${aws_lb_target_group.tg[each.key].arn}"
        type             = "forward"
      }
}
resource "aws_lb_target_group" "tg" {
  for_each = local.forwarding_config
    name                  = "${lookup(local.nlb_config, "environment")}-tg-${lookup(local.tg_config, "name")}-${each.key}"
    port                  = each.key
    protocol              = each.value
  vpc_id                  = lookup(local.tg_config, "tg_vpc_id")
  target_type             = lookup(local.tg_config, "target_type")
  deregistration_delay    = 90
health_check {
    interval            = 30
    port                = each.value != "TCP_UDP" ? each.key : 80
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = {
    Environment = "test"
  }
}
resource "aws_lb_target_group_attachment" "tga1" {
  for_each = local.forwarding_config
    target_group_arn  = "${aws_lb_target_group.tg[each.key].arn}"
    port              = each.key
  target_id           = lookup(local.tg_config,"target_id1")
}

resource "aws_route53_record" "nlb_loadbalancer" {
  name    = "${local.domain_host_name}.${local.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.ecs_domain.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_lb.nlb_load_balancer.dns_name
    zone_id                = aws_lb.nlb_load_balancer.zone_id
  }
}