resource "aws_s3_bucket" "external_image_storage" {
  bucket = "${var.prefix_pttp}-grafana-image-storage"
  acl    = "private"

  tags = var.tags
}

resource "aws_s3_bucket_metric" "external_image_storage" {
  bucket = aws_s3_bucket.external_image_storage.bucket
  name   = "EntireBucket"
}