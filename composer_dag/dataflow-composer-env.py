from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
}

with DAG(
        dag_id='dataflow-composer-env',
        default_args=default_args,
        schedule_interval=None,  # Run manually or trigger with a schedule like '0 3 * * *'
        catchup=False,
        tags=['dataflow', 'csv', 'composer', 'debugged']
) as dag:

    ingest_transactions = BashOperator(
        task_id='ingest_transactions',
        bash_command="""
	    export PYTHONPATH=$PYTHONPATH:/home/airflow/gcs/dags && \
        python3 /home/airflow/gcs/dags/dataflow_ingest_csv_to_bq_main.py \
        --input gs://customer_analytics-bucket/data/transactions.csv \
        --output_table feisty-ceiling-462711-h4:customer_analytics.transactions \
        --schema_type transactions \
        --project feisty-ceiling-462711-h4 \
        --region us-central1 \
        --temp_location gs://customer_analytics-bucket/tmp/dataflow \
        --runner DataflowRunner \
        --setup_file /home/airflow/gcs/dags/setup.py
        """
    )

    ingest_customers = BashOperator(
        task_id='ingest_customers',
        bash_command="""
	    export PYTHONPATH=$PYTHONPATH:/home/airflow/gcs/dags && \
        python3 /home/airflow/gcs/dags/dataflow_ingest_csv_to_bq_main.py \
        --input gs://customer_analytics-bucket/data/customers.csv \
        --output_table feisty-ceiling-462711-h4:customer_analytics.customers \
        --schema_type customers \
        --project feisty-ceiling-462711-h4 \
        --region us-central1 \
        --temp_location gs://customer_analytics-bucket/tmp/dataflow \
        --runner DataflowRunner \
        --setup_file /home/airflow/gcs/dags/setup.py
        """
    )

    ingest_customers >> ingest_transactions