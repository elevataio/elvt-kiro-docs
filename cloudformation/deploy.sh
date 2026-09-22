#!/bin/bash
# =============================================================================
# Kiro Enterprise Deployment Script
# =============================================================================
# This script guides you through deploying the Kiro Enterprise CloudFormation
# stack. It validates prerequisites, collects your configuration, deploys the
# stack, and verifies the deployment.
#
# Usage:
#   chmod +x deploy.sh
#   ./deploy.sh
#
# Requirements:
#   - AWS CLI v2 installed and configured
#   - Valid AWS credentials with CloudFormation and IAM permissions
#   - IAM Identity Center already enabled in your account
#   - At least one group created in Identity Center
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="${SCRIPT_DIR}/kiro-enterprise-setup.yaml"

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${BOLD}$1${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${CYAN}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

confirm() {
    local prompt="$1"
    local response
    echo -e -n "${YELLOW}?${NC} ${prompt} [y/N]: "
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

prompt_input() {
    local prompt="$1"
    local default="${2:-}"
    local result
    if [[ -n "$default" ]]; then
        echo -e -n "${CYAN}?${NC} ${prompt} [${default}]: "
        read -r result
        echo "${result:-$default}"
    else
        echo -e -n "${CYAN}?${NC} ${prompt}: "
        read -r result
        echo "$result"
    fi
}

prompt_select() {
    local prompt="$1"
    shift
    local options=("$@")
    echo -e "${CYAN}?${NC} ${prompt}:"
    for i in "${!options[@]}"; do
        echo "    $((i+1)). ${options[$i]}"
    done
    local selection
    echo -e -n "  Select [1-${#options[@]}]: "
    read -r selection
    echo "${options[$((selection-1))]}"
}

# =============================================================================
# Pre-flight Checks
# =============================================================================

preflight_checks() {
    print_header "Pre-flight Checks"
    
    # Check AWS CLI
    print_step "Checking AWS CLI..."
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI not found. Install from: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
    local aws_version
    aws_version=$(aws --version 2>&1 | awk '{print $1}' | cut -d/ -f2)
    print_success "AWS CLI v${aws_version} found"

    # Check credentials
    print_step "Checking AWS credentials..."
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured or expired. Run 'aws configure' or refresh SSO."
        exit 1
    fi
    
    local account_id region caller_arn
    account_id=$(aws sts get-caller-identity --query Account --output text)
    caller_arn=$(aws sts get-caller-identity --query Arn --output text)
    region=$(aws configure get region 2>/dev/null || echo "us-east-1")
    
    print_success "Authenticated as: ${caller_arn}"
    print_success "Account: ${account_id}"
    print_success "Region: ${region}"
    
    # Export for later use
    export AWS_ACCOUNT_ID="$account_id"
    export AWS_REGION_DEFAULT="$region"
    
    # Check template file
    print_step "Checking CloudFormation template..."
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        print_error "Template not found at: ${TEMPLATE_FILE}"
        exit 1
    fi
    print_success "Template found: ${TEMPLATE_FILE}"
    
    # Validate template
    print_step "Validating CloudFormation template syntax..."
    if ! aws cloudformation validate-template --template-body "file://${TEMPLATE_FILE}" &> /dev/null; then
        print_error "Template validation failed!"
        aws cloudformation validate-template --template-body "file://${TEMPLATE_FILE}" 2>&1
        exit 1
    fi
    print_success "Template syntax is valid"
    
    echo ""
    print_success "All pre-flight checks passed!"
}

# =============================================================================
# Collect Configuration
# =============================================================================

collect_configuration() {
    print_header "Configuration"
    print_info "Please provide the following information to configure Kiro Enterprise."
    print_info "Tip: Have the IAM Identity Center console open in another tab."
    echo ""
    
    # Organization
    echo -e "${BOLD}── Organization ──${NC}"
    ORG_NAME=$(prompt_input "Organization name (lowercase, hyphens ok)" "")
    while [[ ! "$ORG_NAME" =~ ^[a-z0-9-]{3,30}$ ]]; do
        print_error "Must be 3-30 chars, lowercase letters, numbers, hyphens only"
        ORG_NAME=$(prompt_input "Organization name" "")
    done
    
    ENVIRONMENT=$(prompt_select "Environment" "production" "staging" "development")
    DEPLOY_REGION=$(prompt_select "Kiro deployment region" "us-east-1" "us-west-2" "eu-west-1" "eu-central-1" "ap-southeast-1" "ap-northeast-1")
    
    echo ""
    echo -e "${BOLD}── IAM Identity Center ──${NC}"
    print_info "Find these values in: AWS Console > IAM Identity Center > Settings"
    echo ""
    
    IDC_INSTANCE_ARN=$(prompt_input "Identity Center Instance ARN (arn:aws:sso:::instance/ssoins-...)" "")
    while [[ ! "$IDC_INSTANCE_ARN" =~ ^arn:aws:sso:::instance/ssoins-[a-z0-9]+$ ]]; do
        print_error "Must be format: arn:aws:sso:::instance/ssoins-XXXXXXXX"
        IDC_INSTANCE_ARN=$(prompt_input "Identity Center Instance ARN" "")
    done
    
    IDC_REGION=$(prompt_select "Identity Center region" "us-east-1" "us-west-2" "eu-west-1" "eu-central-1" "ap-southeast-1" "ap-northeast-1")
    
    echo ""
    print_info "Find Group IDs in: IAM Identity Center > Groups > [Group] > Group ID"
    echo ""
    
    ADMIN_GROUP_ID=$(prompt_input "Admin Group ID (UUID format)" "")
    while [[ ! "$ADMIN_GROUP_ID" =~ ^[a-f0-9-]{36}$ ]]; do
        print_error "Must be a UUID (e.g., a1b2c3d4-5678-90ab-cdef-111111111111)"
        ADMIN_GROUP_ID=$(prompt_input "Admin Group ID" "")
    done
    
    DEV_GROUP_ID=$(prompt_input "Developer Group ID (UUID format)" "")
    while [[ ! "$DEV_GROUP_ID" =~ ^[a-f0-9-]{36}$ ]]; do
        print_error "Must be a UUID"
        DEV_GROUP_ID=$(prompt_input "Developer Group ID" "")
    done
    
    echo ""
    echo -e "${BOLD}── Subscription ──${NC}"
    SUB_TIER=$(prompt_select "Default subscription tier" "Free" "Pro" "ProPlus" "ProMax" "Power")
    MAX_SUBS=$(prompt_input "Maximum subscriptions (budget control)" "50")
    
    echo ""
    echo -e "${BOLD}── Logging & Security ──${NC}"
    ENABLE_PROMPT_LOG="true"
    if confirm "Enable prompt logging to S3? (recommended for compliance)"; then
        ENABLE_PROMPT_LOG="true"
    else
        ENABLE_PROMPT_LOG="false"
    fi
    
    ENABLE_ACTIVITY="true"
    if confirm "Enable user activity reports? (recommended for usage tracking)"; then
        ENABLE_ACTIVITY="true"
    else
        ENABLE_ACTIVITY="false"
    fi
    
    ENABLE_TRAIL="true"
    if confirm "Enable CloudTrail audit logging? (recommended for security)"; then
        ENABLE_TRAIL="true"
    else
        ENABLE_TRAIL="false"
    fi
    
    ENABLE_KMS="true"
    if confirm "Enable KMS encryption for logs? (recommended for compliance)"; then
        ENABLE_KMS="true"
    else
        ENABLE_KMS="false"
    fi
    
    LOG_RETENTION=$(prompt_select "Log retention period (days)" "30" "60" "90" "180" "365" "730")
    
    # Stack name
    STACK_NAME="${ORG_NAME}-kiro-enterprise-${ENVIRONMENT}"
}

# =============================================================================
# Review Configuration
# =============================================================================

review_configuration() {
    print_header "Review Configuration"
    
    echo -e "${BOLD}Stack Name:${NC}        ${STACK_NAME}"
    echo -e "${BOLD}Organization:${NC}      ${ORG_NAME}"
    echo -e "${BOLD}Environment:${NC}       ${ENVIRONMENT}"
    echo -e "${BOLD}Region:${NC}            ${DEPLOY_REGION}"
    echo ""
    echo -e "${BOLD}Identity Center:${NC}   ${IDC_INSTANCE_ARN}"
    echo -e "${BOLD}IdC Region:${NC}        ${IDC_REGION}"
    echo -e "${BOLD}Admin Group:${NC}       ${ADMIN_GROUP_ID}"
    echo -e "${BOLD}Developer Group:${NC}   ${DEV_GROUP_ID}"
    echo ""
    echo -e "${BOLD}Subscription:${NC}      ${SUB_TIER} (max ${MAX_SUBS} users)"
    echo ""
    echo -e "${BOLD}Prompt Logging:${NC}    ${ENABLE_PROMPT_LOG}"
    echo -e "${BOLD}Activity Reports:${NC}  ${ENABLE_ACTIVITY}"
    echo -e "${BOLD}CloudTrail:${NC}        ${ENABLE_TRAIL}"
    echo -e "${BOLD}KMS Encryption:${NC}    ${ENABLE_KMS}"
    echo -e "${BOLD}Log Retention:${NC}     ${LOG_RETENTION} days"
    echo ""
    
    if ! confirm "Deploy with these settings?"; then
        print_warning "Deployment cancelled."
        exit 0
    fi
}

# =============================================================================
# Deploy Stack
# =============================================================================

deploy_stack() {
    print_header "Deploying CloudFormation Stack"
    
    print_step "Creating stack: ${STACK_NAME} in ${DEPLOY_REGION}..."
    echo ""
    
    aws cloudformation deploy \
        --template-file "$TEMPLATE_FILE" \
        --stack-name "$STACK_NAME" \
        --region "$DEPLOY_REGION" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameter-overrides \
            "OrganizationName=${ORG_NAME}" \
            "Environment=${ENVIRONMENT}" \
            "AwsRegion=${DEPLOY_REGION}" \
            "IdentityCenterInstanceArn=${IDC_INSTANCE_ARN}" \
            "IdentityCenterRegion=${IDC_REGION}" \
            "KiroAdminGroupId=${ADMIN_GROUP_ID}" \
            "KiroDeveloperGroupId=${DEV_GROUP_ID}" \
            "DefaultSubscriptionTier=${SUB_TIER}" \
            "MaxSubscriptions=${MAX_SUBS}" \
            "EnablePromptLogging=${ENABLE_PROMPT_LOG}" \
            "EnableUserActivityReports=${ENABLE_ACTIVITY}" \
            "LogRetentionDays=${LOG_RETENTION}" \
            "EnableCloudTrail=${ENABLE_TRAIL}" \
            "EnableKmsEncryption=${ENABLE_KMS}" \
            "AllowedIpCidrs=0.0.0.0/0" \
        --tags \
            "Key=Project,Value=kiro-enterprise" \
            "Key=Environment,Value=${ENVIRONMENT}" \
            "Key=ManagedBy,Value=cloudformation" \
            "Key=Organization,Value=${ORG_NAME}" \
        --no-fail-on-empty-changeset
    
    if [[ $? -eq 0 ]]; then
        print_success "Stack deployed successfully!"
    else
        print_error "Stack deployment failed. Check CloudFormation console for details."
        exit 1
    fi
}

# =============================================================================
# Post-Deployment Verification
# =============================================================================

verify_deployment() {
    print_header "Verifying Deployment"
    
    # Get stack outputs
    print_step "Retrieving stack outputs..."
    
    local outputs
    outputs=$(aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --region "$DEPLOY_REGION" \
        --query "Stacks[0].Outputs" \
        --output json 2>/dev/null)
    
    if [[ "$outputs" == "null" ]] || [[ -z "$outputs" ]]; then
        print_error "Could not retrieve stack outputs"
        exit 1
    fi
    
    print_success "Stack outputs retrieved"
    echo ""
    
    # Display key outputs
    echo -e "${BOLD}── Deployed Resources ──${NC}"
    echo ""
    
    local admin_role prompt_bucket activity_bucket kms_key
    admin_role=$(echo "$outputs" | python3 -c "import sys,json; data=json.load(sys.stdin); print(next((o['OutputValue'] for o in data if o['OutputKey']=='KiroAdminRoleArn'),'N/A'))" 2>/dev/null || echo "N/A")
    echo -e "  Admin Role ARN:        ${GREEN}${admin_role}${NC}"
    
    prompt_bucket=$(echo "$outputs" | python3 -c "import sys,json; data=json.load(sys.stdin); print(next((o['OutputValue'] for o in data if o['OutputKey']=='PromptLogBucketName'),'Not enabled'))" 2>/dev/null || echo "Not enabled")
    echo -e "  Prompt Log Bucket:     ${GREEN}${prompt_bucket}${NC}"
    
    activity_bucket=$(echo "$outputs" | python3 -c "import sys,json; data=json.load(sys.stdin); print(next((o['OutputValue'] for o in data if o['OutputKey']=='ActivityReportBucketName'),'Not enabled'))" 2>/dev/null || echo "Not enabled")
    echo -e "  Activity Report Bucket: ${GREEN}${activity_bucket}${NC}"
    
    kms_key=$(echo "$outputs" | python3 -c "import sys,json; data=json.load(sys.stdin); print(next((o['OutputValue'] for o in data if o['OutputKey']=='KmsKeyArn'),'Not enabled'))" 2>/dev/null || echo "Not enabled")
    echo -e "  KMS Key ARN:           ${GREEN}${kms_key}${NC}"
    
    echo ""
    
    # Verify S3 buckets exist
    if [[ "$ENABLE_PROMPT_LOG" == "true" ]]; then
        print_step "Verifying prompt log bucket..."
        if aws s3api head-bucket --bucket "$prompt_bucket" --region "$DEPLOY_REGION" 2>/dev/null; then
            print_success "Prompt log bucket accessible"
        else
            print_warning "Prompt log bucket not accessible (may take a moment)"
        fi
    fi
    
    if [[ "$ENABLE_ACTIVITY" == "true" ]]; then
        print_step "Verifying activity report bucket..."
        if aws s3api head-bucket --bucket "$activity_bucket" --region "$DEPLOY_REGION" 2>/dev/null; then
            print_success "Activity report bucket accessible"
        else
            print_warning "Activity report bucket not accessible (may take a moment)"
        fi
    fi
    
    # Verify IAM role
    print_step "Verifying admin role..."
    local role_name="${ORG_NAME}-kiro-admin-${ENVIRONMENT}"
    if aws iam get-role --role-name "$role_name" &>/dev/null; then
        print_success "Admin role exists and is accessible"
    else
        print_warning "Could not verify admin role"
    fi
    
    # Verify CloudTrail
    if [[ "$ENABLE_TRAIL" == "true" ]]; then
        print_step "Verifying CloudTrail..."
        local trail_name="${ORG_NAME}-kiro-audit-${ENVIRONMENT}"
        if aws cloudtrail get-trail-status --name "$trail_name" --region "$DEPLOY_REGION" &>/dev/null; then
            print_success "CloudTrail is active"
        else
            print_warning "CloudTrail verification pending"
        fi
    fi
}

# =============================================================================
# Print Next Steps
# =============================================================================

print_next_steps() {
    print_header "Next Steps (Manual in AWS Console)"
    
    echo -e "${BOLD}Your infrastructure is ready! Complete these final steps in the AWS Console:${NC}"
    echo ""
    echo -e "  ${CYAN}1.${NC} Open the ${BOLD}Kiro Console${NC} in AWS (search 'Kiro' in the console)"
    echo ""
    echo -e "  ${CYAN}2.${NC} Click ${BOLD}'Onboard your team'${NC} or ${BOLD}'Enable small teams'${NC}"
    echo ""
    echo -e "  ${CYAN}3.${NC} Select ${BOLD}'IAM Identity Center'${NC} as identity source"
    echo ""
    echo -e "  ${CYAN}4.${NC} Create a ${BOLD}Kiro Profile${NC} in region: ${GREEN}${DEPLOY_REGION}${NC}"
    echo ""
    echo -e "  ${CYAN}5.${NC} Go to ${BOLD}Users & Groups${NC}, add group: ${GREEN}${DEV_GROUP_ID}${NC}"
    echo "     Assign tier: ${GREEN}${SUB_TIER}${NC}"
    echo ""
    echo -e "  ${CYAN}6.${NC} Enable ${BOLD}Prompt Logging${NC} (Settings > Prompt Logging)"
    echo "     Bucket: ${GREEN}${ORG_NAME}-kiro-prompt-logs-${ENVIRONMENT}-${AWS_ACCOUNT_ID}${NC}"
    echo ""
    echo -e "  ${CYAN}7.${NC} Enable ${BOLD}User Activity Reports${NC} (Settings > User Activity)"
    echo "     Bucket: ${GREEN}${ORG_NAME}-kiro-activity-reports-${ENVIRONMENT}-${AWS_ACCOUNT_ID}${NC}"
    echo ""
    echo -e "  ${CYAN}8.${NC} Note the ${BOLD}Sign-in URL${NC} and share with your developers"
    echo ""
    echo -e "${BOLD}── Developer Sign-In Instructions ──${NC}"
    echo ""
    echo "  1. Open Kiro IDE/CLI"
    echo "  2. Click 'Sign in via IAM Identity Center'"
    echo "  3. Enter the Sign-in URL from the Kiro Console"
    echo "  4. Enter region: ${DEPLOY_REGION}"
    echo "  5. Authenticate with your corporate credentials"
    echo "  6. Click 'Allow Access'"
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Deployment Complete!                                        ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Save outputs to file
    local output_file="${SCRIPT_DIR}/deployment-output-${STACK_NAME}.txt"
    {
        echo "Kiro Enterprise Deployment Summary"
        echo "==================================="
        echo "Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
        echo "Stack Name: ${STACK_NAME}"
        echo "Region: ${DEPLOY_REGION}"
        echo "Account: ${AWS_ACCOUNT_ID}"
        echo ""
        echo "Organization: ${ORG_NAME}"
        echo "Environment: ${ENVIRONMENT}"
        echo "Identity Center: ${IDC_INSTANCE_ARN}"
        echo "Admin Group: ${ADMIN_GROUP_ID}"
        echo "Developer Group: ${DEV_GROUP_ID}"
        echo "Subscription Tier: ${SUB_TIER}"
        echo ""
        echo "S3 Buckets:"
        echo "  Prompt Logs: ${ORG_NAME}-kiro-prompt-logs-${ENVIRONMENT}-${AWS_ACCOUNT_ID}"
        echo "  Activity Reports: ${ORG_NAME}-kiro-activity-reports-${ENVIRONMENT}-${AWS_ACCOUNT_ID}"
        echo "  CloudTrail: ${ORG_NAME}-kiro-cloudtrail-${ENVIRONMENT}-${AWS_ACCOUNT_ID}"
        echo ""
        echo "Next Steps: Complete Kiro profile setup in the AWS Console"
    } > "$output_file"
    
    print_info "Deployment summary saved to: ${output_file}"
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                                                              ║${NC}"
    echo -e "${BLUE}║   ${BOLD}Kiro Enterprise Deployment${NC}${BLUE}                                 ║${NC}"
    echo -e "${BLUE}║   AWS CloudFormation Guided Setup                            ║${NC}"
    echo -e "${BLUE}║                                                              ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    print_info "This script will deploy all AWS resources needed for Kiro Enterprise."
    print_info "Estimated deployment time: 3-5 minutes."
    echo ""
    
    if ! confirm "Ready to begin?"; then
        echo "Cancelled."
        exit 0
    fi
    
    preflight_checks
    collect_configuration
    review_configuration
    deploy_stack
    verify_deployment
    print_next_steps
}

# Run
main "$@"
