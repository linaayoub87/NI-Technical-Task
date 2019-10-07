data "aws_arn" "this" {
  arn = aws_lb.this.arn
}
