variable "sns_topic_name" {}
variable "attached_lambda_arn" {}

resource "aws_sns_topic" "topic" {
  name = "${var.sns_topic_name}"
}

resource "aws_lambda_permission" "sns_topic_attachment" {
  action        = "lambda:InvokeFunction"
  function_name = "${var.attached_lambda_arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.topic.arn}"
}

output "sns_topic_arn" {
  value = "${aws_sns_topic.topic.arn}"
}

output "sns_topic_id" {
  value = "${aws_sns_topic.topic.id}"
}
