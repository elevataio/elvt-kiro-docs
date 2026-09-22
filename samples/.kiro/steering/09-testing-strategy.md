# Testing Strategy

## Test Pyramid

```
        /  E2E Tests  \          <- Few, slow, expensive (real AWS)
       / Integration   \         <- Some, medium speed (real AWS dev account)
      /   Unit Tests    \        <- Many, fast, no AWS (mocked)
     /____________________\
```

## Unit Tests

- Run locally without AWS credentials
- Mock all AWS services using `moto`
- Fast execution (full suite < 30 seconds)
- Minimum 80% code coverage on Lambda handlers
- Test business logic, validation, error handling

### Structure

```
tests/
├── unit/
│   ├── conftest.py              # Shared fixtures (mocked tables, etc.)
│   ├── test_create_order.py
│   ├── test_get_order.py
│   ├── test_list_orders.py
│   └── test_validation.py
```

### Example Unit Test

```python
# tests/unit/conftest.py
import pytest
import boto3
from moto import mock_aws

@pytest.fixture
def dynamodb_table():
    with mock_aws():
        dynamodb = boto3.resource("dynamodb", region_name="us-east-1")
        table = dynamodb.create_table(
            TableName="test-orders",
            KeySchema=[
                {"AttributeName": "pk", "KeyType": "HASH"},
                {"AttributeName": "sk", "KeyType": "RANGE"},
            ],
            AttributeDefinitions=[
                {"AttributeName": "pk", "AttributeType": "S"},
                {"AttributeName": "sk", "AttributeType": "S"},
            ],
            BillingMode="PAY_PER_REQUEST",
        )
        yield table


# tests/unit/test_create_order.py
import json
from moto import mock_aws
from src.lambdas.create_order.handler import handler

@mock_aws
def test_create_order_success(dynamodb_table, monkeypatch):
    monkeypatch.setenv("TABLE_NAME", "test-orders")

    event = {
        "body": json.dumps({
            "customer_email": "test@example.com",
            "items": [{"product_id": "prod-1", "quantity": 2}],
        }),
        "headers": {"x-correlation-id": "test-123"},
    }

    response = handler(event, None)

    assert response["statusCode"] == 201
    body = json.loads(response["body"])
    assert body["data"]["attributes"]["status"] == "pending"


def test_create_order_validation_error(dynamodb_table, monkeypatch):
    monkeypatch.setenv("TABLE_NAME", "test-orders")

    event = {
        "body": json.dumps({"customer_email": "not-an-email"}),
        "headers": {},
    }

    response = handler(event, None)

    assert response["statusCode"] == 400
    body = json.loads(response["body"])
    assert body["error"]["code"] == "VALIDATION_ERROR"
```

## Integration Tests

- Run against real AWS resources in the **dev** account
- Verify end-to-end behavior of individual components
- Execute after deployment to dev environment
- Require AWS credentials with dev account access

```python
# tests/integration/test_orders_api.py
import requests

BASE_URL = os.environ["API_URL"]  # Set by pipeline
AUTH_TOKEN = get_test_token()  # Cognito test user

def test_create_and_retrieve_order():
    # Create
    create_response = requests.post(
        f"{BASE_URL}/v1/orders",
        json={"customer_email": "integration@test.com", "items": [...]},
        headers={"Authorization": f"Bearer {AUTH_TOKEN}"},
    )
    assert create_response.status_code == 201
    order_id = create_response.json()["data"]["id"]

    # Retrieve
    get_response = requests.get(
        f"{BASE_URL}/v1/orders/{order_id}",
        headers={"Authorization": f"Bearer {AUTH_TOKEN}"},
    )
    assert get_response.status_code == 200
    assert get_response.json()["data"]["id"] == order_id
```

## E2E Tests

- Run against staging environment
- Simulate real user workflows
- Verify cross-service interactions
- Limited in number (expensive, slow)

## Running Tests

```bash
# Unit tests (no AWS required)
pytest tests/unit/ -v --cov=src --cov-report=term-missing

# Integration tests (requires AWS dev credentials)
AWS_PROFILE=dev API_URL=https://dev-api.example.com pytest tests/integration/ -v

# E2E tests (requires AWS staging credentials)
AWS_PROFILE=staging API_URL=https://staging-api.example.com pytest tests/e2e/ -v
```

## Test Data

- Unit tests: create test data inline or in fixtures
- Integration tests: use a dedicated test user in Cognito, clean up after each test
- Never share test data between test runs (isolation)
- Use factories (e.g., `factory_boy`) for complex test data generation

## CDK Tests

Test your infrastructure code separately:

```python
# tests/unit/test_stacks.py
import aws_cdk as cdk
from aws_cdk.assertions import Template
from infra.stacks.data_stack import DataStack

def test_data_stack_creates_encrypted_table():
    app = cdk.App()
    stack = DataStack(app, "TestDataStack", env_name="test")
    template = Template.from_stack(stack)

    template.has_resource_properties("AWS::DynamoDB::Table", {
        "SSESpecification": {"SSEEnabled": True},
        "PointInTimeRecoverySpecification": {"PointInTimeRecoveryEnabled": True},
    })
```
