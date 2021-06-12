provider "aws" {
  region = var.region
   default_tags {
   tags = var.default_tags
 }
  ignore_tags {
    keys = ["LastScanned"]
  }
}
# terraform {
#   backend "s3" {}
# }

resource "aws_instance" "nginx" {
  /* ami = "ami-02a3575cbd0c8c096" # amzon linux */
  # name_prefix = format("%s-%s", var.project_name,"EC2")
  ami                         = var.ami_id
  subnet_id                   = var.subnet_id
  instance_type               = var.instance_type
  associate_public_ip_address = var.associate_public_ip_address
    # security_groups             = [aws_security_group.nginx.id]  dont use this , when you re run terraform, it will destory and will recreate the resources.
  vpc_security_group_ids             = [aws_security_group.nginx.id]
  key_name                    = var.key_name

 tags = merge(
    var.default_tags,
    {
     Name = "RabbitMQ-ROS"
    }
  )
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]
    # inline = [
    #   "chmod +x /tmp/start_node.sh",
    #   "sudo sed -i -e 's/\r$//' /tmp/start_node.sh", # Remove the spurious CR characters.
    #   "sudo /tmp/start_node.sh",
    # ]
    connection {
      type        = "ssh"
      user        = var.ssh_username
      # private_key = file(var.private_key_path)
      private_key = var.private_key_path
      host        = aws_instance.nginx.public_ip
    }
  }
  # provisioner "local-exec" {
  #   command = "ansible-playbook  -i ${aws_instance.nginx.public_ip}, --private-key ${var.private_key_path} nginx.yaml"
  # }
  # provisioner "local-exec" {
  #   command = "echo ssh -i vamakp.pem ubuntu@${aws_instance.nginx.public_ip} > ubuntu.sh"
  # }
}

# resource "null_resource" "test_box" {
#   depends_on = [aws_instance.nginx]
#   connection {
#     host = "${aws_instance.nginx.0.public_ip}"
#     # private_key = "${file("./test_box")}"
#     private_key = var.private_key_path
#   }
#   provisioner "ansible" {
#     plays {
#       playbook {
#         file_path = "nginx_ansible.yaml"
#         roles_path = ["/roles"]
#         force_handlers = false
#         # skip_tags = ["list", "of", "tags", "to", "skip"]
#         # start_at_task = "task-name"
#         # tags = ["list", "of", "tags"]
#       }
#       hosts = ["aws_instance.nginx.*.public_ip"]
#       groups = ["consensus"]
#     }
#   }
# }

# resource "null_resource" "test_box" {
#   depends_on = "aws_instance.test_box"
#   connection {
#     host = "${aws_instance.test_box.0.public_ip}"
#     private_key = "${file("./test_box")}"
#   }
#   provisioner "ansible" {
#     plays {
#       playbook {
#         file_path = "/path/to/playbook/file.yml"
#         roles_path = ["/path1", "/path2"]
#         force_handlers = false
#         skip_tags = ["list", "of", "tags", "to", "skip"]
#         start_at_task = "task-name"
#         tags = ["list", "of", "tags"]
#       }
#       hosts = ["aws_instance.test_box.*.public_ip"]
#       groups = ["consensus"]
#     }
#   }
# }