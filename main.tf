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
  credentials = file("C:/Kumar/IntelliJ_Projects/lbg/gcp_sample_pipeline/feisty-ceiling-462711-h4-4b2f13b3b2b7.json")
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
  time_partitioning {
    type  = "DAY"
    field = "signup_date" #  Partition by signup_date
  }

  clustering = ["customer_id"] #  Cluster by customer_id
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
    },

  ])
  time_partitioning {
    type  = "DAY"
    field = "transaction_time" # Partition by transaction_time
  }

  clustering = ["customer_id"] # Cluster by customer_id
}

resource "google_bigquery_table" "monthly_spend_view" {
  dataset_id = google_bigquery_dataset.pipeline_dataset.dataset_id
  table_id   = "customer_monthly_spend"
  deletion_protection = false
  depends_on = [
    google_bigquery_table.transactions
  ]
  view {
    query = <<EOF
      SELECT
        customer_id,
        FORMAT_TIMESTAMP('%Y-%m', transaction_time) AS year_month,
        COUNT(*) AS transaction_count,
        SUM(transaction_amount) AS total_spend,
        AVG(transaction_amount) AS avg_spend
      FROM `${var.project_id}.${google_bigquery_dataset.pipeline_dataset.dataset_id}.transactions`
      GROUP BY customer_id, year_month
    EOF
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "top_5pct_ltv_view" {
  dataset_id = google_bigquery_dataset.pipeline_dataset.dataset_id
  table_id   = "top_5pct_customers"
  deletion_protection = false
  depends_on = [
    google_bigquery_table.transactions
  ]
  view {
    query = <<EOF
      SELECT *
      FROM (
        SELECT
          customer_id,
          SUM(transaction_amount) AS lifetime_value,
          NTILE(20) OVER (ORDER BY SUM(transaction_amount) DESC) AS percentile
        FROM `${var.project_id}.${google_bigquery_dataset.pipeline_dataset.dataset_id}.transactions`
        GROUP BY customer_id
      )
      WHERE percentile = 1
    EOF
    use_legacy_sql = false
  }
}
