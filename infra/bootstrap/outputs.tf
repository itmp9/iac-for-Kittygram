output "bucket_name" {
  value = yandex_storage_bucket.state.bucket
}

output "access_key" {
  value = yandex_iam_service_account_static_access_key.state.access_key
}

output "secret_key" {
  value     = yandex_iam_service_account_static_access_key.state.secret_key
  sensitive = true
}
