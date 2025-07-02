# Run below scripts in cloud shell manually,

python3 dataflow_ingest_csv_to_bq_main.py \
 --input gs://customer_analytics-bucket/data/transactions.csv \
 --output_table feisty-ceiling-462711-h4:customer_analytics.transactions \
 --schema_type transactions \
 --project feisty-ceiling-462711-h4 \
 --region us-central1 \
 --temp_location gs://customer_analytics-bucket/tmp/dataflow \
 --runner DirectRunner \
 --setup_file ./setup.py

 python3 dataflow_ingest_csv_to_bq_main.py \
 --input gs://customer_analytics-bucket/data/customers.csv \
 --output_table feisty-ceiling-462711-h4:customer_analytics.customers \
 --schema_type customers \
 --project feisty-ceiling-462711-h4 \
 --region us-central1 \
 --temp_location gs://customer_analytics-bucket/tmp/dataflow \
 --runner DirectRunner \
 --setup_file ./setup.py


  # running test cases command
  # In cloud shell,
  # shellcheck disable=SC2155
  export PYTHONPATH=$(pwd)
  pytest tests/


   # copy dag and main job scripts to gcp bucket
  gsutil cp dataflow_ingest_csv_to_bq_main.py gs://customer_analytics-bucket/dags/
  gsutil cp setup.py gs://customer_analytics-bucket/dags/
  gsutil cp dataflow_pipeline_ingest_dag.py gs://customer_analytics-bucket/dags/