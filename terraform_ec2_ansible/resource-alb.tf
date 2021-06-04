resource "aws_alb_target_group" "alb_target_group" {
  name     = "terraform-ansible-targetgroup"
  port     = "8080"
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  tags = {
    name = "terrafomr-ansible-targetgroup"
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
    port                = "8080"
  }
}

resource "aws_alb" "alb" {
  depends_on         = [aws_security_group.alb]
  name               = "terraform-alb-tf"
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

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_alb_target_group.alb_target_group.arn
  target_id        = aws_instance.nginx.id
  port             = 8080
}

output "aws_alb" {
  value = aws_alb.alb.arn
}