# Kiro + AWS Backend Services: A Practical Guide

> A guide for teams deploying Kiro with AWS backend services. Written for non-technical decision-makers and first-time users who want to get the most out of Kiro's AI-powered development workflow.

---

## Table of Contents

1. [What is Kiro?](#what-is-kiro)
2. [Getting Started](#getting-started)
3. [Steering Files — Teaching Kiro Your Standards](#steering-files)
4. [Hooks — Automating Your Workflow](#hooks)
5. [Specs — Structured Development](#specs)
6. [MCP Servers — Extending Kiro's Capabilities](#mcp-servers)
7. [AWS Bedrock Integration](#aws-bedrock-integration)
8. [Deploying AWS Infrastructure with Kiro](#deploying-aws-infrastructure)
9. [Enterprise Governance and Security](#enterprise-governance)
10. [One-Click Deployment — CloudFormation Template](#cloudformation-deployment)
11. [Best Practices Summary](#best-practices)
12. [Reference Links](#reference-links)

---

## What is Kiro? <a name="what-is-kiro"></a>

Kiro is an AI-powered development environment built by AWS that helps you build software from prototype to production. It transforms natural language prompts into structured specifications and working code.

Kiro is available across multiple surfaces:

| Surface | Description |
|---------|-------------|
| **IDE** | Desktop application built on VS Code |
| **CLI** | Command-line interface for terminal workflows |
| **Web** | Browser-based development (GitHub/GitLab connected) |
| **Mobile** | On-the-go access |
| **Crew** | Personal AI agent running locally |

The core advantage: your configuration, specs, steering files, and hooks work identically across all surfaces. Start a feature in the IDE, continue from the CLI, hand off to the Web agent — everything stays in sync.

### Key Concepts at a Glance

- **Steering Files** — Persistent instructions that tell Kiro about your project conventions
- **Hooks** — Automated actions triggered by events (file saves, tool calls, etc.)
- **Specs** — Structured development workflow: Requirements → Design → Tasks
- **MCP Servers** — External tools and services Kiro can use
- **Powers** — Packaged bundles of documentation, workflows, and MCP servers
- **Custom Agents** — Specialized Kiro configurations for specific tasks

---

## Getting Started <a name="getting-started"></a>

### Prerequisites

- **An AWS account with a valid payment method (credit card required)** — Kiro billing goes directly through your AWS account. Even the Free tier requires an AWS account for enterprise usage.
- Kiro installed from [kiro.dev](https://kiro.dev/docs/getting-started/installation/)
- AWS credentials configured (`aws configure`) if you plan to deploy infrastructure

> **Important**: For individual use, you can sign in with GitHub or Google without an AWS account. However, for enterprise/team deployment with billing control and governance features, an AWS account is mandatory since all charges appear on your AWS bill.

### Enabling Kiro in Your AWS Account (Billing & Subscription)

Before your team can use Kiro, an administrator must enable the service in the AWS Console. This is where billing control lives.

#### Step 1: Enable IAM Identity Center

1. Choose the [AWS Region supported by Kiro](https://kiro.dev/docs/enterprise/getting-started/) for Identity Center
2. Navigate to **IAM Identity Center** in the AWS Console
3. Click **Enable**
4. Add your users in the Users section
5. (Optional) Configure MFA settings under Settings → Authentication

> IAM Identity Center is offered at no additional charge.

#### Step 2: Enable Kiro in the AWS Console

1. Navigate to the **Kiro Console** within AWS
2. Click **Onboard your team to Kiro** or **Enable small teams**
3. When prompted for identity source, select **IAM Identity Center**
4. Verify your Identity Center configuration
5. Click **Enable** to activate Kiro in your AWS account
6. Note the **Sign in URL** — your users will need this

#### Step 3: Subscribe Users and Control Billing

1. In the Kiro Console, go to **Users & Groups**
2. Click **Add user** or **Add group**
3. Select the IdC user or group you created
4. Choose the subscription tier:

| Tier | Cost | Credits/Month | Best For |
|------|------|--------------|----------|
| **Free** | $0 | 50 | Evaluation, light exploration |
| **Pro** | $20/month | 1,000 | Individual developers |
| **Pro+** | $40/month | 2,000+ | Active development teams |
| **Pro Max** | $100/month | 4,000+ | Heavy usage, multiple projects |
| **Power** | $200/month | 10,000 | Enterprise power users |

#### Billing Control Best Practices

- **All charges appear on your AWS bill** — use AWS Cost Explorer to track Kiro spend
- **Set AWS Budgets alerts** — create budget alerts for the `kiro` service to avoid surprises
- **Use cost allocation tags** — tag users by team for chargeback reporting
- **Avoid duplicate subscriptions** — a user subscribed in two AWS Regions gets billed twice
- **To stop billing** — remove the user from the subscribed group or remove their individual subscription
- **Use SCPs (Service Control Policies)** — restrict which AWS accounts or OUs can enable Kiro subscriptions

#### Users Sign In

Once enabled, users connect to your organization from the Kiro application:

1. In Kiro, click **Sign in via IAM Identity Center**
2. Enter the **Sign in URL** from your Kiro Console
3. Enter the correct **AWS Region code**
4. Authenticate via your Identity Center login portal
5. Click **Allow Access**

> **Source**: [Enable Kiro enterprise subscription with IAM Identity Center](https://repost.aws/articles/AR3YUupHzQQ2mqMzL5Y8KvbQ/enable-kiro-enterprise-subscription-with-iam-identity-center-in-your-aws-accounts)

### Installation

Kiro is available for Mac, Windows, and Linux. Download from [kiro.dev](https://kiro.dev) and install like any standard application.

After installation:

1. Launch Kiro
2. Sign in with your **organization's IAM Identity Center** (enterprise) or AWS Builder ID / Google / GitHub (individual)
3. Open your project folder (File → Open Folder)
4. Start a conversation with the AI agent

### First Steps

When you open Kiro, you'll land in a session with the default agent — a general-purpose coding assistant. You can:

- **Vibe sessions** — Free-form conversation, Q&A, exploratory coding
- **Spec sessions** — Structured workflow: requirements → design → implementation tasks

For your first project, we recommend following the [official first project guide](https://kiro.dev/docs/getting-started/first-project/).

---

## Steering Files — Teaching Kiro Your Standards <a name="steering-files"></a>

Steering files give Kiro persistent knowledge about your project. Instead of explaining your conventions in every conversation, steering files ensure Kiro consistently follows your established patterns, libraries, and standards.

### What Are Steering Files?

They are simple Markdown files stored in `.kiro/steering/` within your project. Think of them as a "project playbook" that Kiro reads before doing any work.

### Where They Live

```
your-project/
├── .kiro/
│   └── steering/
│       ├── project-overview.md
│       ├── coding-standards.md
│       ├── aws-conventions.md
│       └── deployment-rules.md
├── src/
└── ...
```

### Inclusion Modes

Steering files support three inclusion modes:

| Mode | When Loaded | Use Case |
|------|-------------|----------|
| **Always** (default) | Every session automatically | Project conventions, architecture rules |
| **File Match** | When a matching file is read | Language-specific rules, module guides |
| **Manual** | Only when user includes via `#` reference | Reference docs, API specs |

#### Always-Included (Default)

```markdown
# Project Conventions

- Use Python 3.12 for all backend services
- All Lambda functions must include error handling and CloudWatch logging
- Use AWS CDK (Python) for infrastructure as code
- Follow the AWS Well-Architected Framework
```

#### Conditional (File Match)

Add a front-matter section to activate only when relevant files are opened:

```markdown
---
inclusion: fileMatch
fileMatchPattern: "**/*.py"
---

# Python Standards

- Use type hints on all function signatures
- Format with black, lint with ruff
- All modules must have docstrings
```

#### Manual Inclusion

```markdown
---
inclusion: manual
---

# API Specification Reference

This document describes the REST API contract...
```

Users activate manual steering in chat by typing `#` and selecting the file.

### Including External Files in Steering

Steering files can reference other project files using a special syntax:

```markdown
# API Implementation Guide

Follow the OpenAPI spec defined here:
#[[file:docs/openapi.yaml]]

All implementations must match this contract.
```

This is powerful for keeping Kiro aligned with your existing specifications (OpenAPI, GraphQL schemas, Terraform modules, etc.) without duplicating content.

### Global Steering (User-Level)

You can also define steering that applies to ALL your projects by placing files in:

```
~/.kiro/steering/
```

This is useful for personal preferences like preferred code style, commit message format, or tools you always use.

### Practical Example: AWS Project Steering

Here's a complete steering file for an AWS-focused project:

```markdown
# AWS Backend Project Standards

## Architecture
- Serverless-first: prefer Lambda + API Gateway + DynamoDB
- Use AWS CDK (Python) for all infrastructure definitions
- One CDK stack per bounded context (auth, api, data, monitoring)
- Each custom construct lives in its own file, named after the construct

## Security
- All Lambda functions run with least-privilege IAM roles
- Secrets stored in AWS Secrets Manager, never in environment variables
- Enable encryption at rest for all data stores
- API Gateway must require authentication (Cognito or IAM)

## Naming Conventions
- CDK stack names: `{project}-{env}-{context}` (e.g., `myapp-prod-api`)
- Lambda function names: `{project}-{env}-{action}` (e.g., `myapp-prod-processOrder`)
- S3 bucket names: `{org}-{project}-{env}-{purpose}`

## Deployment
- All changes go through CDK Pipelines
- Dev → Staging → Production promotion
- Never deploy directly to production without pipeline approval
```

> **Source**: Steering documentation at [kiro.dev/docs/steering/](https://kiro.dev/docs/steering/)

---

## Hooks — Automating Your Workflow <a name="hooks"></a>

Hooks run shell commands or agent prompts automatically when specific events happen in your session. You define the trigger and the action; Kiro handles the execution.

### What Are Hooks?

Hooks are JSON configuration files stored in `.kiro/hooks/`. They automate repetitive tasks like:

- Running linters when you save a file
- Validating infrastructure changes before applying them
- Running tests after completing a spec task
- Injecting context when a session starts

### Where They Live

```
your-project/
├── .kiro/
│   └── hooks/
│       ├── lint-on-save.json
│       ├── test-after-task.json
│       └── security-check.json
```

### Hook Structure

Every hook file follows this format:

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Human-readable name",
      "trigger": "TriggerName",
      "matcher": "optional-regex-pattern",
      "action": {
        "type": "command",
        "command": "shell command to run"
      }
    }
  ]
}
```

### Available Triggers

| Trigger | When It Fires | Common Use |
|---------|--------------|------------|
| `PostFileSave` | After a file is saved | Linting, formatting, validation |
| `PostFileCreate` | When a new file is created | Scaffolding checks, header injection |
| `PostFileDelete` | When a file is deleted | Cleanup related resources |
| `PreToolUse` | Before the agent uses a tool | Access control, safety gates |
| `PostToolUse` | After a tool is executed | Logging, notifications |
| `SessionStart` | When a new session begins | Load context, check environment |
| `PreTaskExec` | Before a spec task starts | Validation, dependency checks |
| `PostTaskExec` | After a spec task completes | Run tests, update docs |
| `UserPromptSubmit` | When user sends a message | Input validation, routing |
| `Stop` | When agent execution completes | Cleanup, summary generation |

### Action Types

**Command** — Runs a shell command:

```json
{
  "type": "command",
  "command": "npm run lint -- --fix"
}
```

**Agent** — Injects a prompt into the AI context:

```json
{
  "type": "agent",
  "prompt": "Before making changes, verify this follows our AWS security baseline."
}
```

### Matcher (Optional)

The matcher is a regex pattern that filters which events fire the hook:

- For `PostFileSave` / `PostFileCreate` / `PostFileDelete`: tested against the file path
- For `PreToolUse` / `PostToolUse`: tested against the tool name

### Practical Examples

#### 1. Lint TypeScript on Save

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Lint TypeScript on Save",
      "trigger": "PostFileSave",
      "matcher": "\\.(ts|tsx)$",
      "action": {
        "type": "command",
        "command": "npx eslint --fix"
      }
    }
  ]
}
```

#### 2. Run CDK Synth After Infrastructure Changes

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Validate CDK Stack",
      "trigger": "PostFileSave",
      "matcher": "infra/.*\\.py$",
      "action": {
        "type": "command",
        "command": "cd infra && cdk synth --quiet"
      }
    }
  ]
}
```

#### 3. Run Tests After Completing a Spec Task

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Run Tests After Task",
      "trigger": "PostTaskExec",
      "action": {
        "type": "command",
        "command": "npm run test"
      }
    }
  ]
}
```

#### 4. Security Gate for Write Operations

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Security Review on Writes",
      "trigger": "PreToolUse",
      "matcher": "fs_write|str_replace|fs_append",
      "action": {
        "type": "agent",
        "prompt": "Before writing this file, verify: 1) No secrets or credentials are being hardcoded, 2) The change follows our IAM least-privilege principle, 3) No sensitive data is exposed in logs."
      }
    }
  ]
}
```

#### 5. Load AWS Context at Session Start

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Load AWS Environment Info",
      "trigger": "SessionStart",
      "action": {
        "type": "command",
        "command": "echo \"AWS Account: $(aws sts get-caller-identity --query Account --output text), Region: $(aws configure get region)\""
      }
    }
  ]
}
```

### Exit Code Behavior

For command-type hooks:

| Exit Code | Meaning |
|-----------|---------|
| `0` | Success — output is forwarded to the agent |
| `2` | Block the action (only for Pre* triggers) — stderr is forwarded |
| Other | Silent failure, no blocking |

### Creating Hooks

You can create hooks in three ways:

1. **Ask Kiro** — Describe what you want in chat and Kiro generates the hook
2. **Hook UI** — Use Command Palette → "Open Kiro Hook UI"
3. **Manual** — Create JSON files directly in `.kiro/hooks/`

> **Source**: Hooks documentation at [kiro.dev/docs/hooks/](https://kiro.dev/docs/hooks/)

---

## Specs — Structured Development <a name="specs"></a>

Specs provide a systematic approach to building features. Instead of unstructured chatting, Specs guide you through a formal process: Requirements → Design → Implementation Tasks.

### Why Use Specs?

- Reduces ambiguity before coding starts
- Creates documentation as a byproduct of development
- Ensures the AI understands the full context before writing code
- Provides trackable progress through implementation

### The Spec Workflow

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────────┐
│  Requirements   │ ──> │    Design    │ ──> │     Tasks       │
│                 │     │              │     │                 │
│ - User stories  │     │ - Components │     │ - Implement X   │
│ - Constraints   │     │ - Data model │     │ - Add tests     │
│ - Edge cases    │     │ - API design │     │ - Deploy config │
└─────────────────┘     └──────────────┘     └─────────────────┘
```

1. **Requirements** — Kiro asks clarifying questions, then generates detailed requirements
2. **Design** — Technical design based on the requirements (components, data flow, APIs)
3. **Tasks** — Actionable implementation tasks Kiro will execute

### Spec Types

| Type | When to Use |
|------|-------------|
| **Feature Spec** | Building new functionality from scratch |
| **Bug Fix Spec** | Investigating and fixing issues systematically |
| **Quick Spec** | One-shot generation of requirements + design + tasks |

### Using Specs with AWS Projects

When building AWS backend services, Specs shine because they:

1. Force you to think about IAM permissions before coding
2. Document the infrastructure design (CDK stacks, Lambda functions, API routes)
3. Break deployment into safe, reviewable steps
4. Create a clear audit trail of decisions

### Example: Creating a Spec for an API Feature

Start a Spec session and describe your feature:

> "I need a REST API endpoint that accepts file uploads, stores them in S3, triggers a Lambda function to process the file, and stores metadata in DynamoDB."

Kiro will then:
1. Ask clarifying questions (file size limits? auth required? retry policy?)
2. Generate requirements (functional + non-functional)
3. Propose a technical design (CDK stack, Lambda handler, S3 event config)
4. Create implementation tasks you can approve and execute one by one

### Best Practices for Specs

- **Be specific in your initial description** — the more context upfront, the better the requirements
- **Review requirements carefully** — this is where you catch missing edge cases
- **Use MCP integration** — connect requirement tools directly to import into specs
- **Reference existing docs** — use `#[[file:path]]` syntax to point to API specs or architecture diagrams

> **Source**: Specs documentation at [kiro.dev/docs/specs/](https://kiro.dev/docs/specs/)

---

## MCP Servers — Extending Kiro's Capabilities <a name="mcp-servers"></a>

MCP (Model Context Protocol) is a protocol that allows Kiro to communicate with external servers for specialized tools and information. For example, the AWS Documentation MCP server lets Kiro search and read AWS docs directly during a session.

### Configuration

MCP servers are configured in JSON files at two levels:

| Scope | Location | Applies To |
|-------|----------|-----------|
| **User (global)** | `~/.kiro/settings/mcp.json` | All your projects |
| **Workspace** | `.kiro/settings/mcp.json` | Current project only |

Workspace config takes precedence over user config.

### Configuration Format

```json
{
  "mcpServers": {
    "server-name": {
      "command": "uvx",
      "args": ["package-name@latest"],
      "env": {
        "ENV_VAR": "value"
      },
      "disabled": false
    }
  }
}
```

### Installing `uvx`

Many MCP servers use `uvx` (from the `uv` Python package manager) to run. Install it with:

```bash
# macOS (Homebrew)
brew install uv

# pip
pip install uv

# Or follow: https://docs.astral.sh/uv/getting-started/installation/
```

Once installed, `uvx` automatically downloads and runs MCP servers — no per-server installation needed.

### Recommended MCP Servers for AWS Projects

#### AWS Documentation Server

Search, read, and get recommendations from AWS documentation:

```json
{
  "mcpServers": {
    "aws-docs": {
      "command": "uvx",
      "args": ["awslabs.aws-documentation-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      },
      "disabled": false
    }
  }
}
```

#### AWS CDK MCP Server

Get CDK-specific guidance and code generation:

```json
{
  "mcpServers": {
    "aws-cdk": {
      "command": "uvx",
      "args": ["awslabs.cdk-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      },
      "disabled": false
    }
  }
}
```

#### CloudWatch Observability Server

Monitor and analyze your AWS resources:

```json
{
  "mcpServers": {
    "ai-observability": {
      "command": "python3",
      "args": ["/path/to/mcp-server/cloudwatch_mcp_server.py"],
      "env": {
        "AWS_REGION": "us-east-1"
      },
      "disabled": false
    }
  }
}
```

### Adding MCP Servers via the IDE

1. Click the Kiro icon in the sidebar
2. Find "MCP Servers" in the panel
3. Click "+" to add a new server
4. Kiro will guide you through configuration

### Enterprise MCP Governance

For organizations, administrators can control which MCP servers are available:

- **Allow-list** — Only approved servers can be used
- **Disable entirely** — Block all MCP server usage
- Policies are enforced across both IDE and CLI

> **Source**: MCP documentation at [kiro.dev/docs/mcp/](https://kiro.dev/docs/mcp/)

---

## AWS Bedrock Integration <a name="aws-bedrock-integration"></a>

Kiro is natively integrated with AWS services, including Amazon Bedrock. This integration enables powerful AI workflows that go beyond code generation.

### What is Amazon Bedrock?

Amazon Bedrock is a fully managed service that provides access to foundation models (like Claude, Llama, Titan) through a unified API. Combined with Kiro, you can:

- Build and deploy AI agents that use Bedrock models
- Use Bedrock AgentCore for agent runtime and memory
- Deploy conversational agents with persistent memory
- Access multiple foundation models from your development environment

### Kiro + Bedrock AgentCore

Bedrock AgentCore provides infrastructure for running AI agents in production. With Kiro, you can:

1. **Design agents** using Specs (requirements → design → tasks)
2. **Implement agent logic** with Kiro's AI assistance
3. **Deploy to AgentCore Runtime** for production execution
4. **Add persistent memory** using AgentCore Memory

### Deploying Agents to Bedrock

A typical workflow:

```
Kiro IDE/CLI                    AWS
┌──────────────┐               ┌──────────────────────┐
│ Spec session │               │  Bedrock AgentCore   │
│ ─────────── │               │  ┌────────────────┐  │
│ 1. Define    │  ──deploy──> │  │ Agent Runtime   │  │
│ 2. Build     │               │  └────────────────┘  │
│ 3. Test      │               │  ┌────────────────┐  │
│ 4. Deploy    │               │  │ Agent Memory    │  │
│              │               │  └────────────────┘  │
└──────────────┘               └──────────────────────┘
```

### Prerequisites for Bedrock Integration

1. **Enable Bedrock models** in your AWS account via the [Bedrock Console](https://console.aws.amazon.com/bedrock/)
2. **Configure AWS credentials** — `aws configure` with appropriate permissions
3. **Enable required models** — select which foundation models you need access to

### IAM Permissions for Bedrock

Your AWS credentials need these permissions at minimum:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream",
        "bedrock:ListFoundationModels",
        "bedrock:GetFoundationModel"
      ],
      "Resource": "*"
    }
  ]
}
```

For AgentCore, add:

```json
{
  "Effect": "Allow",
  "Action": [
    "bedrock:CreateAgent",
    "bedrock:InvokeAgent",
    "bedrock:GetAgent",
    "bedrock:ListAgents"
  ],
  "Resource": "*"
}
```

### Steering File for Bedrock Projects

```markdown
# Bedrock Integration Standards

## Model Selection
- Use Claude (via Bedrock) for complex reasoning tasks
- Use Titan for embeddings and simple classification
- Always specify model version explicitly (no "latest" in production)

## Agent Design
- All agents must have a defined scope and guardrails
- Use AgentCore Memory for multi-turn conversations
- Implement fallback logic for model throttling (429 responses)

## Cost Management
- Set per-model invocation budgets via AWS Budgets
- Use Provisioned Throughput for predictable workloads
- Log all invocations to CloudWatch for cost attribution
```

> **Sources**: 
> - [Extending conversational memory in Kiro CLI using Amazon Bedrock AgentCore Memory](https://aws.amazon.com/blogs/machine-learning/extending-conversational-memory-in-kiro-cli-using-amazon-bedrock-agentcore-memory/)
> - [Kiro quick deploy to Amazon Bedrock AgentCore](https://aws.amazon.com/cn/blogs/china/kiro-quick-deploy-agent-deploy-amazon-bedrock-agentcore/)

---

## Deploying AWS Infrastructure with Kiro <a name="deploying-aws-infrastructure"></a>

Kiro includes a built-in **cloud-architect** power that helps you build AWS infrastructure with CDK in Python following the AWS Well-Architected Framework.

### The Cloud-Architect Power

Powers are packaged bundles of documentation, workflow guides, and MCP servers. The `cloud-architect` power provides:

- AWS pricing information
- AWS architecture knowledge base
- AWS API references
- Best practice guidance aligned with the Well-Architected Framework

### Using Kiro for Infrastructure as Code

#### Step 1: Set Up Your Project Structure

```
my-aws-project/
├── .kiro/
│   ├── steering/
│   │   └── infrastructure.md
│   ├── hooks/
│   │   └── validate-cdk.json
│   └── settings/
│       └── mcp.json
├── infra/
│   ├── app.py
│   ├── stacks/
│   │   ├── network_stack.py
│   │   ├── compute_stack.py
│   │   └── data_stack.py
│   └── constructs/
├── src/
│   └── lambdas/
├── tests/
└── requirements.txt
```

#### Step 2: Create a Steering File for Infrastructure

```markdown
# Infrastructure Conventions

## CDK Standards
- Python 3.12 with AWS CDK v2
- One stack per bounded context
- Each construct in its own file, named after the construct
- Props interfaces in the same file as the construct
- Use L2/L3 constructs where available; L1 only when necessary

## Environments
- dev: `us-east-1`, minimal capacity, no alarms
- staging: `us-east-1`, production-like config, synthetic monitoring
- prod: `us-east-1` + `eu-west-1`, full capacity, PagerDuty alerts

## Security Baseline
- All S3 buckets: encryption enabled, public access blocked, versioning on
- All Lambda functions: VPC-attached for data access, security groups restricted
- All DynamoDB tables: encryption at rest, point-in-time recovery enabled
- IAM roles: one role per function, least-privilege, no wildcards in resource ARNs
```

#### Step 3: Ask Kiro to Build Infrastructure

In a Spec session, describe what you need:

> "Create a serverless API with API Gateway, Lambda functions for CRUD operations, DynamoDB for storage, and S3 for file uploads. Include a CDK Pipeline for automated deployments."

Kiro will:
1. Propose a CDK stack structure
2. Generate the infrastructure code
3. Include proper IAM roles and security configuration
4. Set up the deployment pipeline

#### Step 4: Validate with Hooks

Add a hook that validates your CDK code on save:

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "CDK Synth Validation",
      "trigger": "PostFileSave",
      "matcher": "infra/.*\\.py$",
      "action": {
        "type": "command",
        "command": "cd infra && cdk synth --quiet 2>&1 | tail -5"
      }
    }
  ]
}
```

### Common AWS Architectures with Kiro

| Architecture | Components | Kiro Approach |
|--------------|-----------|---------------|
| REST API | API Gateway + Lambda + DynamoDB | Spec session → CDK stack |
| Event-Driven | S3 → Lambda → SQS → Lambda | Steering for event patterns |
| Data Pipeline | S3 → Lambda → Redshift | Spec with data validation |
| Auth System | Cognito + API Gateway + Lambda | Spec with security focus |

### Deployment Commands

After Kiro generates your CDK infrastructure:

```bash
# Install dependencies
pip install -r requirements.txt

# Synthesize CloudFormation template (validates your code)
cdk synth

# Compare changes against deployed stack
cdk diff

# Deploy to your AWS account
cdk deploy

# Deploy specific stack
cdk deploy MyApp-Prod-ApiStack
```

> **Source**: [AWS CDK best practices](https://docs.aws.amazon.com/cdk/latest/guide/best-practices.html)

---

## Enterprise Governance and Security <a name="enterprise-governance"></a>

For organizations, Kiro provides comprehensive governance controls to manage AI-assisted development at scale.

### Permission Policies

Kiro uses a capability-based permissions system with fine-grained control over agent actions:

- **Block dangerous shell commands** — prevent destructive operations
- **Deny web access** — restrict external network calls
- **Force approval prompts** — require human confirmation for specific capabilities
- **File path restrictions** — limit which files the agent can modify

These policies take precedence over individual user settings.

### Model Governance

Administrators can:

- **Restrict available models** — only approved models accessible
- **Set a default model** — applied automatically to all clients
- **Track usage** — per-user and per-team consumption reporting

### MCP Server Governance

Control which external tools your team can use:

- **Allow-list approach** — create a JSON file with approved servers, serve it over HTTPS, add the URL to your Kiro profile
- **Complete disable** — turn off all MCP server access organization-wide
- **Per-profile enforcement** — different teams get different server access

### Identity and Access

Kiro supports enterprise identity providers:

- **AWS IAM Identity Center** (SSO)
- **Microsoft Entra ID** (Azure AD)
- **SAML 2.0 providers**

Subscription governance is enforced via IAM condition keys, allowing you to:
- Restrict which groups can be assigned Kiro subscriptions
- Prevent individual user assignments
- Use Service Control Policies (SCPs) for organization-wide enforcement

### Security Architecture

Kiro's security framework is built on AWS infrastructure:

- Data encrypted in transit and at rest
- Code context processed in your AWS region
- No training on your proprietary code
- Audit logging available via CloudTrail

### Recommended Enterprise Setup

```
Organization Level
├── IAM Identity Center → Kiro SSO
├── SCP → Subscription governance
├── Governance Profile
│   ├── Approved models: [Claude Sonnet, Claude Haiku]
│   ├── MCP allow-list: [aws-docs, aws-cdk, github]
│   └── Permission policy: block-destructive-commands
│
Team Level (workspace .kiro/)
├── steering/ → Team-specific conventions
├── hooks/ → Automated quality gates
└── settings/mcp.json → Team MCP servers
```

> **Source**: Enterprise governance at [kiro.dev/docs/enterprise/governance/](https://kiro.dev/docs/enterprise/governance/)

---

## One-Click Deployment — CloudFormation Template <a name="cloudformation-deployment"></a>

This repository includes a validated CloudFormation template that provisions all AWS infrastructure needed for Kiro Enterprise in a single deployment. No manual resource creation required.

### What the Template Deploys

| Resource | Purpose |
|----------|---------|
| IAM Admin Role | Manage Kiro profiles, subscriptions, governance |
| IAM Developer Policy | Read-only access for developers |
| S3 Bucket (Prompt Logs) | Stores user prompts and Kiro responses for compliance |
| S3 Bucket (Activity Reports) | Daily CSV usage telemetry per user |
| S3 Bucket (CloudTrail) | Audit trail of all Kiro API calls |
| KMS Key | Customer-managed encryption for all log buckets |
| CloudTrail Trail | Records who did what, when (API-level audit) |
| CloudWatch Alarm | Budget alert for Kiro spending |
| Permission Boundary | Controls which subscription tiers can be created |

### Prerequisites

Before deploying:

1. **AWS Account** with a valid payment method (credit card required)
2. **AWS CLI v2** installed and configured (`aws configure`)
3. **IAM Identity Center** enabled in your account
4. **At least two groups** created in Identity Center:
   - One for Kiro Administrators
   - One for Kiro Developers (users)
5. **IAM permissions** to create CloudFormation stacks, IAM roles, S3 buckets, KMS keys

### Option A: Guided Deployment (Recommended)

The interactive script walks you through every parameter with validation:

```bash
# Navigate to the cloudformation folder
cd cloudformation/

# Make the script executable
chmod +x deploy.sh

# Run the guided deployment
./deploy.sh
```

The script will:
1. Validate your AWS credentials and template syntax
2. Prompt you for each configuration value (with examples and validation)
3. Show a review screen before deploying
4. Deploy the CloudFormation stack (~3-5 minutes)
5. Verify all resources were created successfully
6. Print the next steps to complete in the AWS Console

### Option B: Direct AWS CLI Deployment

If you prefer a non-interactive approach:

```bash
aws cloudformation deploy \
  --template-file cloudformation/kiro-enterprise-setup.yaml \
  --stack-name myorg-kiro-enterprise-production \
  --region us-east-1 \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    OrganizationName=myorg \
    Environment=production \
    AwsRegion=us-east-1 \
    IdentityCenterInstanceArn=arn:aws:sso:::instance/ssoins-XXXXXXXXX \
    IdentityCenterRegion=us-east-1 \
    KiroAdminGroupId=aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee \
    KiroDeveloperGroupId=ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj \
    DefaultSubscriptionTier=Pro \
    MaxSubscriptions=50 \
    EnablePromptLogging=true \
    EnableUserActivityReports=true \
    LogRetentionDays=90 \
    EnableCloudTrail=true \
    EnableKmsEncryption=true
```

### Option C: AWS Console (Upload Template)

1. Open **CloudFormation** in the AWS Console
2. Click **Create Stack** → **Upload a template file**
3. Upload `cloudformation/kiro-enterprise-setup.yaml`
4. Fill in the parameters (organized by category in the console)
5. Acknowledge IAM resource creation
6. Click **Create Stack**

### After Deployment — Complete Kiro Setup

The CloudFormation stack creates the infrastructure. Complete these final steps in the AWS Console:

```
Step 1: Navigate to the Kiro Console (search "Kiro" in AWS Console)
        ↓
Step 2: Click "Onboard your team to Kiro"
        ↓
Step 3: Select "IAM Identity Center" as identity source
        ↓
Step 4: Create a Kiro Profile in your chosen region
        ↓
Step 5: Go to Users & Groups → Add your developer group
        ↓
Step 6: Assign the subscription tier (Pro, Pro+, etc.)
        ↓
Step 7: Enable Prompt Logging → select the S3 bucket from stack outputs
        ↓
Step 8: Enable User Activity Reports → select the activity bucket
        ↓
Step 9: Note the Sign-in URL → share with developers
```

### Verifying the Deployment

After deployment, check that everything is working:

```bash
# Check stack status
aws cloudformation describe-stacks \
  --stack-name myorg-kiro-enterprise-production \
  --region us-east-1 \
  --query "Stacks[0].StackStatus" \
  --output text

# Expected output: CREATE_COMPLETE

# View all outputs (bucket names, role ARNs, etc.)
aws cloudformation describe-stacks \
  --stack-name myorg-kiro-enterprise-production \
  --region us-east-1 \
  --query "Stacks[0].Outputs[*].[OutputKey,OutputValue]" \
  --output table
```

### Where Logs Will Appear

Once Kiro is configured and users start working:

**Prompt Logs** (user prompts + Kiro responses):
```
s3://myorg-kiro-prompt-logs-production-123456789012/
  └── AWSLogs/123456789012/KiroLogs/prompt_log/us-east-1/2026/08/20/
```

**User Activity Reports** (daily CSV per client type):
```
s3://myorg-kiro-activity-reports-production-123456789012/
  └── AWSLogs/123456789012/KiroLogs/user_report/us-east-1/2026/08/20/00/
        ├── IDE_123456789012_user_report_20260820T020000Z.csv
        ├── CLI_123456789012_user_report_20260820T020000Z.csv
        └── Plugin_123456789012_user_report_20260820T020000Z.csv
```

**CloudTrail Audit** (API calls):
```
s3://myorg-kiro-cloudtrail-production-123456789012/
  └── AWSLogs/123456789012/CloudTrail/us-east-1/2026/08/20/
```

### Infrastructure Cost Estimate

| Resource | Approximate Cost |
|----------|-----------------|
| KMS Key | ~$1/month + $0.03 per 10,000 requests |
| S3 Storage | ~$0.023/GB/month (auto-tiers to IA/Glacier) |
| CloudTrail | First trail free, $2 per 100,000 events |
| CloudWatch Alarm | $0.10/month |
| **Total infrastructure** | **~$3-10/month** (varies by usage) |

Kiro subscription costs are separate (per-user, per-month, based on chosen tier).

### Cleanup

To remove all deployed resources:

```bash
# Empty S3 buckets first (required before deletion)
aws s3 rm s3://myorg-kiro-prompt-logs-production-123456789012 --recursive
aws s3 rm s3://myorg-kiro-activity-reports-production-123456789012 --recursive
aws s3 rm s3://myorg-kiro-cloudtrail-production-123456789012 --recursive

# Delete the stack
aws cloudformation delete-stack \
  --stack-name myorg-kiro-enterprise-production \
  --region us-east-1
```

> **Note**: S3 buckets use `DeletionPolicy: Retain` to prevent accidental data loss. You must empty and delete them manually.

---

## Best Practices Summary <a name="best-practices"></a>

### For Non-Technical Teams Getting Started

1. **Start with steering files** — Write down your project conventions before anything else. Even a simple file describing your tech stack and naming conventions makes a huge difference.

2. **Use Spec sessions for new features** — Don't just chat. The structured workflow catches edge cases early and creates documentation automatically.

3. **Set up basic hooks** — Start with linting on save and tests after task completion. These prevent common issues without manual effort.

4. **Install the AWS Documentation MCP server** — This gives Kiro direct access to AWS best practices during development.

5. **Enable the cloud-architect power** — Built-in guidance for AWS CDK and Well-Architected patterns.

### For AWS Infrastructure Projects

1. **One CDK stack per context** — Don't put everything in one massive stack
2. **Use steering to enforce security baselines** — IAM least-privilege, encryption, no public access
3. **Validate with hooks** — Run `cdk synth` on every save to infrastructure files
4. **Deploy through pipelines** — Never `cdk deploy` directly to production
5. **Reference architecture docs in steering** — Use `#[[file:docs/architecture.md]]` to keep Kiro aligned

### For Enterprise Deployment

1. **Set up governance profiles first** — Model restrictions, MCP allow-lists, permission policies
2. **Distribute steering files via version control** — Team conventions stay in the repo
3. **Use hooks for compliance gates** — Security scanning, license checking, format validation
4. **Integrate with existing CI/CD** — Kiro generates code, your pipeline validates and deploys
5. **Audit with CloudTrail** — Track all Kiro interactions with your AWS account

### Steering File Quick Wins

| File | Content | Impact |
|------|---------|--------|
| `project-overview.md` | Tech stack, architecture, key decisions | Kiro understands your project immediately |
| `coding-standards.md` | Language style, error handling, logging | Consistent code output |
| `aws-conventions.md` | Naming, IAM, deployment rules | Secure infrastructure by default |
| `forbidden-patterns.md` | What NOT to do (hardcoded secrets, etc.) | Prevents common mistakes |

---

## Reference Links <a name="reference-links"></a>

### Official Kiro Documentation

| Resource | URL |
|----------|-----|
| Kiro Docs Home | [kiro.dev/docs/](https://kiro.dev/docs/) |
| Installation Guide | [kiro.dev/docs/getting-started/installation/](https://kiro.dev/docs/getting-started/installation/) |
| First Project | [kiro.dev/docs/getting-started/first-project/](https://kiro.dev/docs/getting-started/first-project/) |
| Steering Files | [kiro.dev/docs/steering/](https://kiro.dev/docs/steering/) |
| Hooks | [kiro.dev/docs/hooks/](https://kiro.dev/docs/hooks/) |
| Hook Triggers | [kiro.dev/docs/hooks/types/](https://kiro.dev/docs/hooks/types/) |
| Hook Examples | [kiro.dev/docs/hooks/examples/](https://kiro.dev/docs/hooks/examples/) |
| Specs | [kiro.dev/docs/specs/](https://kiro.dev/docs/specs/) |
| MCP Configuration | [kiro.dev/docs/mcp/configuration/](https://kiro.dev/docs/mcp/configuration/) |
| MCP Examples | [kiro.dev/docs/mcp/examples/](https://kiro.dev/docs/mcp/examples/) |
| Custom Agents | [kiro.dev/docs/custom-agents/](https://kiro.dev/docs/custom-agents/) |
| Permissions | [kiro.dev/docs/permissions/](https://kiro.dev/docs/permissions/) |
| Enterprise Governance | [kiro.dev/docs/enterprise/governance/](https://kiro.dev/docs/enterprise/governance/) |
| Privacy & Security | [kiro.dev/docs/privacy-and-security/](https://kiro.dev/docs/privacy-and-security/) |
| Configuration Scopes | [kiro.dev/docs/configuration/](https://kiro.dev/docs/configuration/) |
| Powers | [kiro.dev/docs/powers/installation/](https://kiro.dev/docs/powers/installation/) |
| Enterprise Onboarding | [kiro.dev/docs/enterprise/getting-started/](https://kiro.dev/docs/enterprise/getting-started/) |
| Subscribe Your Team | [kiro.dev/docs/enterprise/subscribe/](https://kiro.dev/docs/enterprise/subscribe/) |
| Billing & Pricing | [kiro.dev/docs/enterprise/billing/](https://kiro.dev/docs/enterprise/billing/) |
| Subscription Management | [kiro.dev/docs/enterprise/subscription-management/](https://kiro.dev/docs/enterprise/subscription-management/) |
| IAM Permissions for Kiro | [kiro.dev/docs/enterprise/iam/](https://kiro.dev/docs/enterprise/iam/) |
| Pricing Page | [kiro.dev/pricing/](https://kiro.dev/pricing/) |

### AWS Integration Resources

| Resource | URL |
|----------|-----|
| AWS CDK Best Practices | [docs.aws.amazon.com/cdk/latest/guide/best-practices.html](https://docs.aws.amazon.com/cdk/latest/guide/best-practices.html) |
| Kiro + Bedrock AgentCore Memory | [AWS Blog](https://aws.amazon.com/blogs/machine-learning/extending-conversational-memory-in-kiro-cli-using-amazon-bedrock-agentcore-memory/) |
| Kiro + Agent Toolkit for AWS | [repost.aws article](https://www.repost.aws/articles/AReLJ1UhxdTzqXP-h421MFCg/use-kiro-ide-with-agent-toolkit-for-aws-to-build-deploy-and-manage-your-aws-environment) |
| Transform DevOps with Kiro | [AWS Public Sector Blog](https://aws.amazon.com/blogs/publicsector/transform-devops-practice-with-kiro-ai-powered-agents/) |
| Kiro Steering Blog | [kiro.dev/blog/teaching-kiro-new-tricks-with-agent-steering-and-mcp/](https://kiro.dev/blog/teaching-kiro-new-tricks-with-agent-steering-and-mcp/) |
| Global Steering Blog | [kiro.dev/blog/stop-repeating-yourself/](https://kiro.dev/blog/stop-repeating-yourself/) |

---

> **Note**: Content in this guide was rephrased for compliance with licensing restrictions. All information is sourced from official Kiro documentation and AWS resources linked above.

---

*Last updated: August 2026*