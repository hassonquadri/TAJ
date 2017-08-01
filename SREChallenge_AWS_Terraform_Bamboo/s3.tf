resource "aws_s3_bucket" "terraform-state" {
    bucket = "terraform-state-hasson"
    acl = "private"

    tags {
        Name = "Terraform state"
    }
}
