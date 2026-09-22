# Monitoring and Observability

## Logging

### Standard Format

All Lambda functions use structured JSON logging via `aws_lambda_powertools`:

```python
from aws_lambda_powertools import Logger, Tracer, Metrics
from aws_lambda_powertools.metrics import MetricUnit

logger = Logger(service="order-api")
tracer = Tracer(service="order-api")
metrics = Metrics(namespace="OrderApi", service="order-api")
```

### Required Log Fields

Every log entry must include:
- `service` — which microservice/function
- `correlation_id` — request tracking across services
- `level` — INFO, WARNING, ERROR
- `timestamp` — ISO 8601 format

### Log Levels by Environment

| Environment | Minimum Level | Retention |
|-------------|--------------|-----------|
| Dev | DEBUG | 7 days |
| Staging | INFO | 14 days |
| Production | INFO | 90 days |

### What NOT to Log

- Passwords, tokens, API keys
- Full credit card numbers (mask to last 4 digits)
- Personal health information (PHI)
- Full request/response bodies in production (too verbose, potential PII)

## Tracing

AWS X-Ray is enabled on all Lambda functions for distributed tracing.

```python
from aws_lambda_powertools import Tracer

tracer = Tracer()

@tracer.capture_lambda_handler
def handler(event, context):
    result = process_order(event)
    return result

@tracer.capture_method
def process_order(event):
    # X-Ray will trace this method automatically
    ...
```

### Trace Annotations

Add annotations for filtering traces in the X-Ray console:

```python
tracer.put_annotation(key="order_id", value=order_id)
tracer.put_annotation(key="customer_tier", value="premium")
```

## Metrics

### Custom Metrics

Use CloudWatch Embedded Metric Format (EMF) via Powertools:

```python
from aws_lambda_powertools import Metrics
from aws_lambda_powertools.metrics import MetricUnit

metrics = Metrics()

@metrics.log_metrics(capture_cold_start_metric=True)
def handler(event, context):
    metrics.add_metric(name="OrdersCreated", unit=MetricUnit.Count, value=1)
    metrics.add_metric(name="OrderValue", unit=MetricUnit.Count, value=order_total)
    metrics.add_dimension(name="Environment", value="production")
```

### Key Metrics to Track

| Metric | Threshold | Action |
|--------|----------|--------|
| Lambda Error Rate | > 1% over 5 min | PagerDuty alert |
| Lambda Duration P99 | > 3 seconds | Warning notification |
| DynamoDB Throttled Requests | > 0 over 5 min | Auto-scaling review |
| API Gateway 5xx Rate | > 0.5% over 5 min | PagerDuty alert |
| API Gateway Latency P95 | > 2 seconds | Performance review |

## CloudWatch Alarms

### CDK Alarm Definition

```python
from aws_cdk import aws_cloudwatch as cw, aws_cloudwatch_actions as cw_actions, aws_sns as sns

# Error rate alarm
error_alarm = cw.Alarm(
    self, "LambdaErrorAlarm",
    metric=lambda_function.metric_errors(period=Duration.minutes(5)),
    threshold=1,
    evaluation_periods=2,
    comparison_operator=cw.ComparisonOperator.GREATER_THAN_OR_EQUAL_TO_THRESHOLD,
    alarm_description="Lambda function error rate exceeds threshold",
    treat_missing_data=cw.TreatMissingData.NOT_BREACHING,
)
error_alarm.add_alarm_action(cw_actions.SnsAction(alert_topic))

# Duration alarm
duration_alarm = cw.Alarm(
    self, "LambdaDurationAlarm",
    metric=lambda_function.metric_duration(
        period=Duration.minutes(5),
        statistic="p99"
    ),
    threshold=3000,  # 3 seconds in milliseconds
    evaluation_periods=3,
    comparison_operator=cw.ComparisonOperator.GREATER_THAN_THRESHOLD,
    alarm_description="Lambda P99 latency exceeds 3 seconds",
)
```

## CloudWatch Dashboard

Create a dashboard per environment with these panels:

1. **API Health** — Request count, 4xx/5xx rates, latency percentiles
2. **Lambda Performance** — Invocations, errors, duration, concurrent executions
3. **DynamoDB** — Read/write capacity usage, throttled requests, latency
4. **Business Metrics** — Orders created, order values, processing time

## Alerting Strategy

| Severity | Channel | Response Time | Example |
|----------|---------|--------------|---------|
| Critical | PagerDuty + Slack | < 15 min | 5xx rate > 5%, data loss |
| High | Slack #alerts | < 1 hour | Error rate > 1%, high latency |
| Medium | Slack #monitoring | Next business day | Capacity warnings, cost spikes |
| Low | Email digest | Weekly review | Performance trends, optimization opportunities |
