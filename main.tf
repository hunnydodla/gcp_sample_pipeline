terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "google" {
  credentials = file("C:/Kumar/IntelliJ_Projects/lbg/gcp_sample_pipeline/feisty-ceiling-462711-h4-ce411e66690e.json")
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "data_bucket" {
  name     = var.bucket_name
  location = var.bucket_location
  force_destroy = true
}

resource "google_bigquery_dataset" "pipeline_dataset" {
  dataset_id = var.dataset_id
  location   = var.bq_location
}
resource "google_bigquery_table" "customers" {
  dataset_id = google_bigquery_dataset.pipeline_dataset.dataset_id
  table_id   = "customers"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "first_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "last_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "email"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "signup_date"
      type = "DATE"
      mode = "REQUIRED"
    }
  ])
}

resource "google_bigquery_table" "transactions" {
  dataset_id = google_bigquery_dataset.pipeline_dataset.dataset_id
  table_id   = "transactions"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "transaction_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "transaction_amount"
      type = "FLOAT"
      mode = "REQUIRED"
    },
    {
      name = "transaction_time"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])
}
