import argparse, apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from transforms import parse_and_validate_customers, parse_and_validate_transactions

def run(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', required=True)
    parser.add_argument('--output_table', required=True)
    parser.add_argument('--schema_type', choices=['customers','transactions'], required=True)
    parser.add_argument('--project', required=True)
    parser.add_argument('--region', required=True)
    parser.add_argument('--temp_location', required=True)
    args, pipeline_args = parser.parse_known_args(argv)

    opts = PipelineOptions(pipeline_args, runner='DataflowRunner',
                           project=args.project, region=args.region,
                           temp_location=args.temp_location, save_main_session=True)

    with beam.Pipeline(options=opts) as p:
        lines = p | 'ReadCSV' >> beam.io.ReadFromText(args.input, skip_header_lines=1)
        if args.schema_type == 'customers':
            data = lines | 'ParseCust' >> beam.Map(parse_and_validate_customers)
            schema = 'customer_id:STRING,first_name:STRING,last_name:STRING,email:STRING,signup_date:DATE'
        else:
            data = lines | 'ParseTxn' >> beam.Map(parse_and_validate_transactions)
            schema = 'transaction_id:STRING,customer_id:STRING,transaction_amount:FLOAT,transaction_time:TIMESTAMP'

        data | 'FilterValid' >> beam.Filter(lambda r: r) \
             | 'WriteBQ' >> beam.io.WriteToBigQuery(
                 args.output_table, schema=schema,
                 create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
                 write_disposition=beam.io.BigQueryDisposition.WRITE_TRUNCATE
             )

if __name__ == '__main__':
    run()