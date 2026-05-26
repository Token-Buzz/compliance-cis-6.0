output "detector_id" {
  value = var.enable ? aws_guardduty_detector.this[0].id : null
}
