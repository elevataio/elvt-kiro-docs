---
inclusion: fileMatch
fileMatchPattern: "src/lambdas/**/*.py"
---

# Lambda Handler Guide

This steering activates automatically when working on Lambda function files.

## Handler Template

Every new Lambda handler must follow this structure:

```python
"""
Lambda handler for {action} {resource}.

Trigger: API Gateway {METHOD} /v1/{resource}
"""
import json
import os
import uuid
from typing import Any

from aws_lambda_powertools import Logger, Metrics, Tracer
from aws_lambda_powertools.metrics import MetricUnit
from aws_lambda_powertools.utilities.typing import LambdaContext
from pydantic import BaseModel, ValidationError

logger = Logger()
tracer = Tracer()
metrics = Metrics()


class RequestModel(BaseModel):
    """Define expected request body here."""
    pass


class ResponseModel(BaseModel):
    """Define response structure here."""
    pass


@logger.inject_lambda_context(correlation_id_path="headers.x-correlation-id")
@tracer.capture_lambda_handler
@metrics.log_metrics(capture_cold_start_metric=True)
def handler(event: dict[str, Any], context: LambdaContext) -> dict[str, Any]:
    """Main entry point for the Lambda function."""
    correlation_id = event.get("headers", {}).get(
        "x-correlation-id", str(uuid.uuid4())
    )

    try:
        # 1. Parse and validate input
        body = json.loads(event.get("body") or "{}")
        request = RequestModel.model_validate(body)

        # 2. Execute business logic
        result = _process(request)

        # 3. Record metrics
        metrics.add_metric(name="SuccessCount", unit=MetricUnit.Count, value=1)

        # 4. Return success response
        return _success_response(201, result, correlation_id)

    except ValidationError as e:
        logger.warning("Validation failed", extra={"errors": e.errors()})
        return _error_response(400, "VALIDATION_ERROR", str(e), correlation_id)

    except Exception as e:
        logger.error("Unexpected error", exc_info=True)
        metrics.add_metric(name="ErrorCount", unit=MetricUnit.Count, value=1)
        return _error_response(500, "INTERNAL_ERROR", "Internal server error", correlation_id)


def _process(request: RequestModel) -> dict:
    """Business logic goes here. Keep handler thin."""
    raise NotImplementedError


def _success_response(status_code: int, data: dict, correlation_id: str) -> dict:
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json", "x-correlation-id": correlation_id},
        "body": json.dumps({"data": data, "meta": {"correlation_id": correlation_id}}),
    }


def _error_response(status_code: int, code: str, message: str, correlation_id: str) -> dict:
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json", "x-correlation-id": correlation_id},
        "body": json.dumps({"error": {"code": code, "message": message}, "meta": {"correlation_id": correlation_id}}),
    }
```

## Rules for Lambda Handlers

1. **Keep handlers thin** — extract business logic into separate functions or modules
2. **Parse → Validate → Execute → Respond** — always in this order
3. **Cold start optimization** — imports at module level, SDK clients at module level, secrets cached
4. **Timeout buffer** — leave 5 seconds before timeout for cleanup logging
5. **Idempotency** — POST/PUT handlers must handle duplicate invocations gracefully
