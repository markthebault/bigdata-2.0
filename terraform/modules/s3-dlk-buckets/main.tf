variable "names" {
  type = "list"
}

resource "aws_s3_bucket" "dlk" {
  count = "${length(var.names)}"

  bucket = "${element(var.names, count.index)}"
  acl    = "private"

  tags = {
    Name        = "Datalake Buckets"
    Environment = "Dev"
    Terraform   = "true"
  }
}

output "s3_bucket_id" {
  value = "${aws_s3_bucket.dlk.*.id}"
}

output "s3_bucket_arn" {
  value = "${aws_s3_bucket.dlk.*.arn}"
}
