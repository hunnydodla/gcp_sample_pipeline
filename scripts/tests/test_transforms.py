import pytest
from parse_transforms.transforms import parse_and_validate_customers, parse_and_validate_transactions

def test_valid_customer_line():
    line = "C123,John,Doe,john@example.com,2023-01-01"
    result = parse_and_validate_customers(line)
    assert result["customer_id"] == "C123"
    assert result["email"] == "john@example.com"

def test_invalid_customer_line():
    line = "invalid,21,59.4,23233-02-35"
    result = parse_and_validate_customers(line)
    assert result is None

def test_valid_transaction_line():
    line = "T789,C123,99.95,2023-05-01T10:15:00Z"
    result = parse_and_validate_transactions(line)
    assert result["transaction_amount"] == 99.95

def test_invalid_transaction_amount():
    line = "T123,C123,abc,2023-01-01T00:00:00Z"
    result = parse_and_validate_transactions(line)
    assert result is None