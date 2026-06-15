resource "yandex_iam_service_account" "state" {
  name = "kittygram-tfstate"
}

resource "yandex_resourcemanager_folder_iam_member" "state_admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.state.id}"
}

resource "yandex_iam_service_account_static_access_key" "state" {
  service_account_id = yandex_iam_service_account.state.id
}

resource "yandex_storage_bucket" "state" {
  bucket     = var.bucket_name
  access_key = yandex_iam_service_account_static_access_key.state.access_key
  secret_key = yandex_iam_service_account_static_access_key.state.secret_key

  anonymous_access_flags {
    read        = false
    list        = false
    config_read = false
  }

  versioning {
    enabled = true
  }

  depends_on = [yandex_resourcemanager_folder_iam_member.state_admin]
}
