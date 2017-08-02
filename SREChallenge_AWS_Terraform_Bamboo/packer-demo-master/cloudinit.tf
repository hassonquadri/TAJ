provider "cloudinit" {}

data "template_file" "bamboo-init" {
  template = "${file("scripts/bamboo-init.sh")}"
  vars {
    DEVICE = "${var.INSTANCE_DEVICE_NAME}"  
  }
}
data "template_cloudinit_config" "cloudinit-bamboo" {

  gzip = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.bamboo-init.rendered}"
  }

}
