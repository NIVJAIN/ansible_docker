resource "aws_alb_target_group" "rabbitmq_alb_target_group" {
  name     = "tfansible-rabbitmq-targetgroup"
  port     = "15672"
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  tags = {
    name = "tfansible-rabbitmq-targetgroup"
  }
  #   stickiness {    
  #     type            = "lb_cookie"    
  #     cookie_duration = 1800    
  #     enabled         = "${var.target_group_sticky}"  
  #   }   
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = "15672"
  }
}
resource "aws_alb_listener_rule" "alb_listener_rabbitmq" {
  depends_on         = [aws_alb.alb]
  listener_arn = aws_alb_listener.alb_listener.arn

  action {
    target_group_arn = aws_alb_target_group.rabbitmq_alb_target_group.arn
    type             = "forward"
  }
    condition {
    host_header {
      /* values = ["${lower(local.ecs_service_name)}.${data.terraform_remote_state.platform.outputs.ecs_domain_name}"] */
      values = ["${local.domain_host_name}.${local.domain_name}"]
      # values = ["${lower(local.ecs_service_name)}.vama-dsl.com"]
      #  values = ["${element(values(var.services_map), count.index)}.${var.domain}"]
    }
  }
}



resource "aws_lb_target_group_attachment" "rabbitmq" {
  target_group_arn = aws_alb_target_group.rabbitmq_alb_target_group.arn
  target_id        = aws_instance.nginx.id
  port             = 15672
}