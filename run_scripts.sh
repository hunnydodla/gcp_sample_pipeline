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