#!/bin/bash
bucket=$1
aws s3api delete-objects \
      --bucket $bucket \
      --delete "$(aws s3api list-object-versions \
      --bucket $bucket \
      --max-items 400 | \
#      jq '{Objects: [.DeleteMarkers[] | {Key:.Key, VersionId : .VersionId}], Quiet: false}')"
      jq '{Objects: [.Versions[] | {Key:.Key, VersionId : .VersionId}], Quiet: false}')"
aws s3api delete-bucket --bucket $bucket --region eu-west-2