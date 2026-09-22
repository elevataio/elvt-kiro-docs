---
inclusion: manual
---

# OpenAPI Reference

This steering file is available manually via `#` in chat. Use it when implementing or modifying API endpoints.

Reference the full API spec:
#[[file:docs/openapi.yaml]]

## How to Use

When implementing a new endpoint:
1. Check the OpenAPI spec for the exact request/response contract
2. Match path parameters, query parameters, and headers exactly
3. Implement all documented error responses
4. Validate against the schema before deploying

## Endpoint Summary

| Method | Path | Description |
|--------|------|-------------|
| POST | /v1/orders | Create a new order |
| GET | /v1/orders | List orders (paginated) |
| GET | /v1/orders/{id} | Get order by ID |
| PUT | /v1/orders/{id} | Update order |
| DELETE | /v1/orders/{id} | Cancel order |
| POST | /v1/orders/{id}/items | Add item to order |
| GET | /v1/customers/{id} | Get customer profile |
| PUT | /v1/customers/{id} | Update customer profile |
