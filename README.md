# gcp_sample_pipeline
Sample GCP ETL  pipeline to process files using gcp components and loads the data to Bigquery

# Architecture Overview

Local CSV Files
⬇
Upload to GCS Bucket 
⬇
Dataflow (Apache Beam Python Pipeline)
⬇
Schema Validation Cleansing 
⬇
BigQuery Tables and views (Partitioned & Clustered) - Terraform scripts
⬇
Views:
- Monthly Spend Per Customer
- Top 5% Customers by LTV
⬇
Orchestration via Cloud Composer (Airflow DAG)
⬇
Git 

# Setup instructions

--Prerequisites
Google Cloud Project with billing enabled

IAM roles for:
Create service account -terraform-****@feisty-ce***ng-*****-h4.iam.gserviceaccount.com
BigQuery Admin
Dataflow Developer
logs bucket writer
Composer Admin
Storage Admin
Service Account User 

Tools installed:
gcloud
terraform
python3 & pip

GCP Permissions Setup
Grant iam.serviceAccountUser role to your user on the Compute Engine default SA:
- to give access to service account 670******520-compute@developer.gserviceaccount.com(dataflow)
  to run dataflow job using service account- terraform-****@feisty-ce***ng-*****-h4.iam.gserviceaccount.com for dataflow job


gcloud projects add-iam-policy-binding feisty-ce***ng-*****-h4 \
--member="user:d*d*****ll@gmail.com" \
--role="roles/iam.serviceAccountUser"

Terraform Infra Setup:
Create GCS bucket, BQ dataset, and tables with Terraform:
terraform init
terraform plan
terraform apply

Resources:
GCS bucket (e.g., customer_analytics-bucket)
BigQuery dataset: customer_analytics
BQ tables:
customers (clustered on customer_id)
transactions (partitioned on DATE(transaction_time), clustered on customer_id)

Views:
customer_monthly_spend
top_5pct_customers

Upload CSVs to Cloud Storage:
gsutil cp data/customers.csv gs://customer_analytics-bucket/data/
gsutil cp data/transactions.csv gs://customer_analytics-bucket/data/

Running the Pipeline Locally, To test locally using DirectRunner:

python3 dataflow_ingest_csv_to_bq_main.py \

ingest transactions file: 
--input gs://customer_analytics-bucket/data/transactions.csv \
--output_table feisty-ceiling-462711-h4:customer_analytics.transactions \
--schema_type transactions \
--project feisty-ceiling-462711-h4 \
--region us-central1 \
--temp_location gs://customer_analytics-bucket/tmp/dataflow \
--runner DirectRunner

Running Pipeline in Cloud Composer:
Upload DAG and Beam script to Composer,
Copy dataflow_ingest_csv_to_bq_main.py and dataflow_dag.py to Composer’s /dags/ folder.


Airflow UI:

Navigate to Cloud Composer → Environments → dataflow-composer-env → Airflow UI
Trigger DAG: dataflow-composer-env

BigQuery Modeling:
View 1: Monthly Spend Per Customer

CREATE OR REPLACE VIEW customer_monthly_spend AS
SELECT
customer_id,
FORMAT_TIMESTAMP('%Y-%m', transaction_time) AS year_month,
COUNT(*) AS transaction_count,
SUM(transaction_amount) AS total_spend,
AVG(transaction_amount) AS avg_spend
FROM `customer_analytics.transactions`
GROUP BY customer_id, year_month;

View 2: Top 5% by Lifetime Value

CREATE OR REPLACE VIEW top_5pct_customers AS
SELECT *
FROM (
SELECT
customer_id,
SUM(transaction_amount) AS lifetime_value,
NTILE(20) OVER (ORDER BY SUM(transaction_amount) DESC) AS percentile
FROM `customer_analytics.transactions`
GROUP BY customer_id
)
WHERE percentile = 1;

Assumptions:
------------
Schema is flat (no nested fields)
CSVs have headers and consistent formatting
GCS bucket, BQ dataset/table names are fixed
Data ingestion is batch-mode, not streaming
No PII masking or data encryption requirements beyond defaults
Cost optimization is not yet prioritized