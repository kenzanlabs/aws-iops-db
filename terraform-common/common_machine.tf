data "aws_vpc" "selected" {
  id = "${var.common_vpc_id}"
}

data "aws_subnet" "selected" {
  id = "${var.common_subnet_id}"
}

resource "aws_instance" "database" {

  count = 1

  ami                         = "${lookup(var.common_aws_amis, var.common_aws_region)}"
  key_name                    = "${var.common_key_name}"
  subnet_id                   = "${var.common_subnet_id}"

  instance_type               = "${var.machine_instance_type}"
  associate_public_ip_address = true

  # provided by database implementation
  # comment this line to let terraform compute the default 
  security_groups = [ "${aws_security_group.database.id}" ]

  root_block_device {
    volume_size           = "${var.machine_root_volume_size}"
    volume_type           = "${var.machine_root_volume_type}"
    delete_on_termination = "${var.machine_root_delete_on_termination}"
  }

  ebs_block_device {
    device_name           = "${var.machine_ebs_device_name}"
    volume_size           = "${var.machine_ebs_volume_size}"
    volume_type           = "${var.machine_ebs_type}"
    iops                  = "${var.machine_ebs_iops}"
    delete_on_termination = "${var.machine_ebs_delete_on_termination}"
  }

  tags {
    Name = "${var.machine_instance_name}"
  }

  connection {
    user        = "${var.common_username}"
    private_key = "${var.common_key_path}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs -t xfs /dev/xvdh"
    ]
    connection {
      type = "ssh"
      host = "${aws_instance.database.public_ip}"
      user = "${var.common_username}"
      private_key = "${file("${var.common_key_path}")}"
    }
  }

}
