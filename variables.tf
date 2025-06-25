variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "GCS bucket name"
  type        = string
}

variable "bucket_location" {
  description = "GCS bucket location"
  type        = string
  default     = "us-central1"
}

variable "dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
}

variable "bq_location" {
  description = "BigQuery dataset location"
  type        = string
  default     = "us-central1"
}

variable "dataflow_sa_email" {
  description = "Email of Dataflow service account"
  type        = string
}
