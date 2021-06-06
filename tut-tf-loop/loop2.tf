variable "hosts_j" {
  description = "This hosts will be added as dns names and rules for forwarding traffic"
  /* type        = list(map(string)) */
  default = {
      "nginx1" = {
        "tgname" = "nginx"
        "tgport"    = "80"
        /* "tgproto"  = "HTTP" */
      },
      "rabbit1" = {
        "tgname" = "rabbit"
        "tgport"    = "15672"
        /* "tgproto"  = "HTTP" */
      }
  }
}

resource "null_resource" "heights" {
    for_each = var.hosts_j
    triggers = {
        name = each.value.tgname
        port = each.value.tgport
    }
}

resource "null_resource" "heights2" {
    for_each = null_resource.heights
     triggers = {
        name2 = each.value.triggers.name
        port2 = each.value.triggers.port
    }
}

output "heights" {
    value = null_resource.heights2
}