# Forbidden Patterns

These patterns are explicitly prohibited in this project. Kiro must never generate code that uses them.

## Security Violations

### Never hardcode secrets

```python
# FORBIDDEN
API_KEY = "sk-1234567890abcdef"
DB_PASSWORD = "mysecretpassword"
os.environ["SECRET"] = "hardcoded-value"

# CORRECT
import boto3
secret = boto3.client("secretsmanager").get_secret_value(SecretId="my-secret")
```

### Never use wildcard IAM permissions in production

```python
# FORBIDDEN
iam.PolicyStatement(
    actions=["s3:*"],
    resources=["*"]
)

# CORRECT
iam.PolicyStatement(
    actions=["s3:GetObject", "s3:PutObject"],
    resources=[bucket.arn_for_objects("uploads/*")]
)
```

### Never disable encryption

```python
# FORBIDDEN
dynamodb.Table(..., encryption=dynamodb.TableEncryption.UNENCRYPTED)
s3.Bucket(..., encryption=s3.BucketEncryption.UNENCRYPTED)

# CORRECT - encryption is always on
dynamodb.Table(..., encryption=dynamodb.TableEncryption.AWS_MANAGED)
s3.Bucket(..., encryption=s3.BucketEncryption.S3_MANAGED)
```

### Never expose S3 buckets publicly

```python
# FORBIDDEN
s3.Bucket(..., public_read_access=True)
s3.Bucket(..., block_public_access=s3.BlockPublicAccess(block_public_acls=False))

# CORRECT
s3.Bucket(..., block_public_access=s3.BlockPublicAccess.BLOCK_ALL)
```

## Code Quality Violations

### Never use bare except

```python
# FORBIDDEN
try:
    do_something()
except:
    pass

# CORRECT
try:
    do_something()
except SpecificError as e:
    logger.error(f"Operation failed: {e}")
    raise
```

### Never use print statements for logging

```python
# FORBIDDEN
print(f"Processing order {order_id}")
print(f"Error: {e}")

# CORRECT
from aws_lambda_powertools import Logger
logger = Logger()
logger.info("Processing order", extra={"order_id": order_id})
logger.error("Operation failed", extra={"error": str(e)})
```

### Never import * (star imports)

```python
# FORBIDDEN
from boto3.dynamodb.conditions import *
from mymodule import *

# CORRECT
from boto3.dynamodb.conditions import Key, Attr
from mymodule import specific_function, SpecificClass
```

## Infrastructure Violations

### Never deploy directly to production

```bash
# FORBIDDEN
cdk deploy --all --profile production
cdk deploy MyStack --context env=prod

# CORRECT - use the pipeline
git push origin main  # Pipeline handles deployment
```

### Never use DESTROY removal policy in production

```python
# FORBIDDEN (in production config)
dynamodb.Table(..., removal_policy=RemovalPolicy.DESTROY)
s3.Bucket(..., removal_policy=RemovalPolicy.DESTROY, auto_delete_objects=True)

# CORRECT (in production)
dynamodb.Table(..., removal_policy=RemovalPolicy.RETAIN)
s3.Bucket(..., removal_policy=RemovalPolicy.RETAIN)
```

### Never skip input validation

```python
# FORBIDDEN
def handler(event, context):
    order_data = json.loads(event["body"])
    table.put_item(Item=order_data)  # Unvalidated input directly to DB

# CORRECT
def handler(event, context):
    try:
        request = CreateOrderRequest.model_validate_json(event["body"])
    except ValidationError as e:
        return {"statusCode": 400, "body": json.dumps({"error": str(e)})}
    # Now safe to use validated request
```

## DynamoDB Violations

### Never use Scan in production code paths

```python
# FORBIDDEN (in API handlers)
response = table.scan(FilterExpression=Attr("status").eq("pending"))

# CORRECT (use query with proper key design)
response = table.query(
    IndexName="gsi1",
    KeyConditionExpression=Key("gsi1_pk").eq("STATUS#pending")
)
```

### Never write without condition expressions

```python
# FORBIDDEN (can silently overwrite existing data)
table.put_item(Item=order_data)

# CORRECT (prevent accidental overwrites)
table.put_item(
    Item=order_data,
    ConditionExpression="attribute_not_exists(pk)"
)
```
