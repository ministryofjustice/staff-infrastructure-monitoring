resource "aws_s3_bucket" "external_image_storage" {
  bucket = "${var.prefix}-grafana-image-storage"
  acl    = "private"

  tags = var.tags
}
