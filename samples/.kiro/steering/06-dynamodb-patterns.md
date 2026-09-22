# DynamoDB Design Patterns

## Single-Table Design

This project uses a single-table design for DynamoDB. All entities share one table with carefully designed partition keys (PK) and sort keys (SK).

## Table Schema

| Entity | PK | SK | Purpose |
|--------|----|----|---------|
| Customer | `CUSTOMER#{customer_id}` | `PROFILE` | Customer profile |
| Order | `CUSTOMER#{customer_id}` | `ORDER#{order_id}` | Customer's orders |
| Order (by status) | `STATUS#{status}` | `ORDER#{order_id}` | Query orders by status (GSI) |
| Order Item | `ORDER#{order_id}` | `ITEM#{item_id}` | Items in an order |

## Access Patterns

1. **Get customer profile** → PK = `CUSTOMER#123`, SK = `PROFILE`
2. **List customer orders** → PK = `CUSTOMER#123`, SK begins_with `ORDER#`
3. **Get specific order** → PK = `CUSTOMER#123`, SK = `ORDER#456`
4. **List order items** → PK = `ORDER#456`, SK begins_with `ITEM#`
5. **Query orders by status** → GSI1 PK = `STATUS#pending`, SK begins_with `ORDER#`

## GSI Design

| Index | PK | SK | Projection |
|-------|----|----|-----------|
| GSI1 | `gsi1_pk` | `gsi1_sk` | ALL |
| GSI2 | `gsi2_pk` | `gsi2_sk` | KEYS_ONLY |

## CDK Table Definition

```python
from aws_cdk import (
    aws_dynamodb as dynamodb,
    RemovalPolicy,
)

table = dynamodb.Table(
    self, "OrdersTable",
    table_name=f"{project}-{env}-orders",
    partition_key=dynamodb.Attribute(name="pk", type=dynamodb.AttributeType.STRING),
    sort_key=dynamodb.Attribute(name="sk", type=dynamodb.AttributeType.STRING),
    billing_mode=dynamodb.BillingMode.PAY_PER_REQUEST,  # Use PROVISIONED for prod
    point_in_time_recovery=True,
    encryption=dynamodb.TableEncryption.AWS_MANAGED,
    removal_policy=RemovalPolicy.RETAIN,
)

# GSI for querying by status
table.add_global_secondary_index(
    index_name="gsi1",
    partition_key=dynamodb.Attribute(name="gsi1_pk", type=dynamodb.AttributeType.STRING),
    sort_key=dynamodb.Attribute(name="gsi1_sk", type=dynamodb.AttributeType.STRING),
    projection_type=dynamodb.ProjectionType.ALL,
)
```

## Data Access Pattern in Lambda

```python
import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])

def get_customer_orders(customer_id: str, limit: int = 20) -> list[dict]:
    """Retrieve all orders for a customer, most recent first."""
    response = table.query(
        KeyConditionExpression=Key("pk").eq(f"CUSTOMER#{customer_id}") & Key("sk").begins_with("ORDER#"),
        ScanIndexForward=False,  # Descending order
        Limit=limit,
    )
    return response["Items"]

def create_order(customer_id: str, order_id: str, order_data: dict) -> None:
    """Create a new order with a transaction (main record + status index)."""
    table.put_item(
        Item={
            "pk": f"CUSTOMER#{customer_id}",
            "sk": f"ORDER#{order_id}",
            "gsi1_pk": f"STATUS#pending",
            "gsi1_sk": f"ORDER#{order_id}",
            "order_id": order_id,
            "customer_id": customer_id,
            "status": "pending",
            "created_at": datetime.utcnow().isoformat(),
            **order_data,
        },
        ConditionExpression="attribute_not_exists(pk)",  # Prevent duplicates
    )
```

## Rules

- Always use `ConditionExpression` on writes to prevent accidental overwrites
- Use `ProjectionExpression` on reads to reduce data transfer
- Avoid Scan operations — they read the entire table
- Use batch operations (`batch_write_item`) for bulk inserts
- TTL: add `expires_at` attribute for temporary data (sessions, caches)
- Pagination: use `LastEvaluatedKey` / `ExclusiveStartKey` for large result sets
