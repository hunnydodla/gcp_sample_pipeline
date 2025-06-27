import csv

def parse_and_validate_customers(line):
    try:
        row = next(csv.reader([line]))
        return {
            'customer_id': row[0],
            'first_name': row[1],
            'last_name': row[2],
            'email': row[3],
            'signup_date': row[4]
        }
    except Exception as e:
        print(f"[Customer Parse Error] {e}")
        return None

def parse_and_validate_transactions(line):
    try:
        row = next(csv.reader([line]))
        return {
            'transaction_id': row[0],
            'customer_id': row[1],
            'transaction_amount': float(row[2]),
            'transaction_time': row[3]
        }
    except Exception as e:
        print(f"[Transaction Parse Error] {e}")
        return None