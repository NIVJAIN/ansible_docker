provider "aws" {
  region = "ap-southeast-1"
}

/* variable "user_names" {
  description = "Create IAM users with these names"
  type        = list(string)
  default     = ["neo", "trinity", "morpheus"]
}

resource "aws_iam_user" "example" {
  count = length(var.user_names)
  name  = format("%s-%s",var.user_names[count.index],"AWS")
} */


/* resource "aws_iam_user" "example" {
  count = 3
  name  = "neo.${count.index}"
} */

/* output "all_arns" {
  value       = aws_iam_user.example[*].arn
  description = "The ARNs for all users"
} */


variable "hero_thousand_faces" {
  description = "map"
  type        = map(string)
  default     = {
    neo      = "hero"
    trinity  = "love interest"
    morpheus = "mentor"
  }
}
output "upper_roles" {
  /* value = {for name, role in var.hero_thousand_faces : upper(name) => upper(role)} */
  value = {for name, role in var.hero_thousand_faces: name => role }
}

variable "hosts" {
  description = "This hosts will be added as dns names and rules for forwarding traffic"
  /* type        = list(map(string)) */
  default = {
      "nginx1" = {
        "tgname" = "nginx"
        "tgport"    = "80"
        "tgproto"  = "HTTP"
      },
      "rabbit1" = {
        "tgname" = "rabbit"
        "tgport"    = "15672"
        "tgproto"  = "HTTP"
      }
  }
}




resource "aws_alb_target_group" "alb_target_group" {
  for_each = var.hosts
  /* count        = "${length(var.hosts)}" */
  name         = "${each.value.tgname}-Dev"
  port         = "${each.value.tgport}"
  protocol     = "${each.value.tgproto}"
  vpc_id       =  "vpc-028b7724ac0331752"
  /* health_check =  "${local.health_check}" */
  /* health_check = ["${local.healthcheck}"] */
  health_check     {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
  }
  /* tags = {
    Name      = each.value.tgname
    Scheduled = each.value.tgport
    Sccd = each.value.tgproto
  } */
}



variable "hosts2" {
  description = "map"
  type        = map(string)
  default     = {
    nginx2      = "80"
    rabbit2  = "15672"
  }
}

resource "aws_alb_target_group" "alb_target_group_2" {
  for_each = var.hosts2
  /* count        = "${length(var.hosts)}" */
  name         = "${each.key}-Dev"
  port         = "${each.value}"
  protocol     = "HTTP"
  vpc_id       =  "vpc-028b7724ac0331752"
  /* health_check =  "${local.health_check}" */
  /* health_check = ["${local.healthcheck}"] */
  health_check     {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
  }
  /* tags = {
    Name      = each.value.tgname
    Scheduled = each.value.tgport
    Sccd = each.value.tgproto
  } */
}