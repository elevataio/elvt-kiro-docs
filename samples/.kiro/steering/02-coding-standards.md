# Coding Standards

## Python Style

- Follow PEP 8 strictly
- Use type hints on all function signatures and return types
- Maximum line length: 120 characters
- Format with `black`, lint with `ruff`
- Sort imports with `isort` (profile: black)

## Naming Conventions

### Code
- Functions and variables: `snake_case`
- Classes: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Private methods: prefix with single underscore `_method_name`
- Lambda handler files: `{action}_{resource}.py` (e.g., `create_order.py`, `get_customer.py`)

### AWS Resources (CDK)
- Stack names: `{project}-{env}-{context}` (e.g., `orderapi-prod-compute`)
- Lambda function names: `{project}-{env}-{action}-{resource}` (e.g., `orderapi-prod-create-order`)
- DynamoDB table names: `{project}-{env}-{table}` (e.g., `orderapi-prod-orders`)
- S3 bucket names: `{org}-{project}-{env}-{purpose}` (e.g., `acme-orderapi-prod-uploads`)
- IAM role names: `{project}-{env}-{service}-role` (e.g., `orderapi-prod-create-order-role`)

## Error Handling

- All Lambda handlers must use try/except at the top level
- Return structured error responses with correlation IDs
- Never expose stack traces in API responses
- Log errors with full context to CloudWatch

```python
# Correct error handling pattern
def handler(event, context):
    correlation_id = event.get("headers", {}).get("x-correlation-id", str(uuid.uuid4()))
    try:
        # business logic here
        return {"statusCode": 200, "body": json.dumps(result)}
    except ValidationError as e:
        logger.warning(f"[{correlation_id}] Validation failed: {e}")
        return {"statusCode": 400, "body": json.dumps({"error": str(e), "correlationId": correlation_id})}
    except Exception as e:
        logger.error(f"[{correlation_id}] Unexpected error: {e}", exc_info=True)
        return {"statusCode": 500, "body": json.dumps({"error": "Internal server error", "correlationId": correlation_id})}
```

## Logging

- Use structured JSON logging (via `aws_lambda_powertools`)
- Always include: correlation_id, function_name, event_type
- Log levels: DEBUG for development, INFO for production
- Never log sensitive data (passwords, tokens, PII)

```python
from aws_lambda_powertools import Logger

logger = Logger(service="order-api")

@logger.inject_lambda_context(correlation_id_path="headers.x-correlation-id")
def handler(event, context):
    logger.info("Processing request", extra={"path": event["path"], "method": event["httpMethod"]})
```

## Testing

- Minimum 80% code coverage for Lambda handlers
- Use `pytest` as the test framework
- Use `moto` for mocking AWS services in unit tests
- Integration tests run against real AWS resources in the dev account
- Test file naming: `test_{module_name}.py`

## Documentation

- All public functions must have docstrings (Google style)
- CDK constructs must document their props interface
- Architecture decisions documented in `docs/architecture.md`
