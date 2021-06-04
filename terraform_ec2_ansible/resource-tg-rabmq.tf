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
resource "aws_alb_listener" "alb_listener_rabbitmq" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 15672
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.rabbitmq_alb_target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "rabbitmq" {
  target_group_arn = aws_alb_target_group.rabbitmq_alb_target_group.arn
  target_id        = aws_instance.nginx.id
  port             = 15672
}