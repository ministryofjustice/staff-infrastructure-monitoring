#!/bin/bash


if [ $ENV -neq "development" ]
then

export TEMP_KMS_KEY_ID=$(terraform output prometheus_long_term_storage_kms_key_id | tr '\n' '\0')
terraform state rm module.prometheus.aws_s3_bucket.storage
terraform state rm module.prometheus.aws_s3_bucket_metric.storage
terraform state rm module.prometheus.aws_kms_key.storage_key
terraform state rm module.grafana.aws_s3_bucket.external_image_storage
terraform state rm module.grafana.aws_s3_bucket_metric.external_image_storage
terraform state rm module.prometheus_v2.aws_s3_bucket.storage
terraform state rm module.prometheus_v2.aws_s3_bucket_metric.storage
terraform state rm module.prometheus_v2.aws_kms_key.storage_key
terraform state rm module.grafana_v2.aws_s3_bucket.external_image_storage
terraform state rm module.grafana_v2.aws_s3_bucket_metric.external_image_storage
terraform import module.prometheus-thanos-storage.aws_s3_bucket.encrypted[0] pttp-$ENV-ima-thanos-storage
terraform import module.grafana-image-storage.aws_s3_bucket.non-encrypted[0] pttp-$ENV-ima-grafana-image-storage
terraform import module.prometheus-thanos-storage.aws_kms_key.this $TEMP_KMS_KEY_ID

fi

