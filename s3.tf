// Create SA
resource "yandex_iam_service_account" "s3manager" {
  folder_id = data.yandex_client_config.client.folder_id
  name      = "tf-test-sa"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = data.yandex_client_config.client.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.s3manager.id}"
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.s3manager.id
  description        = "static access key for object storage"
}

// Use keys to create bucket
resource "yandex_storage_bucket" "test" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "tf-test-bucket-for-s3manager"
}

output "static_access_keys" {
  value = {
    access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
    # Предупреждение: Секретный ключ должен защищаться и не выводиться в логах в production
  }
  sensitive   = true
  description = "Static access keys for the service account (marked as sensitive)"
}

output "bucket_info" {
  value = {
    bucket_name = yandex_storage_bucket.test.bucket
  }
  description = "Information about the created S3 bucket"
}
