#!/bin/bash
set -e

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
    echo "❌ Usage: $0 <stg|prd>"
    exit 1
fi

if [[ "$ENVIRONMENT" != "stg" && "$ENVIRONMENT" != "prd" ]]; then
    echo "❌ Environment must be 'stg' or 'prd'"
    exit 1
fi

echo "🚀 Starting bootstrap for $ENVIRONMENT environment..."

# Validate templates
./scripts/validate.sh

# Deploy buckets
aws cloudformation deploy \
  --template-file templates/buckets.yaml \
  --stack-name gbm-connect-buckets-$ENVIRONMENT \
  --capabilities CAPABILITY_NAMED_IAM

# Deploy pipeline
aws cloudformation deploy \
  --template-file templates/pipelines-$ENVIRONMENT.yaml \
  --stack-name gbm-connect-pipeline-$ENVIRONMENT \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    Environment=$ENVIRONMENT \
    ArtifactsBucket=gbm-connect-artifacts-$ENVIRONMENT \
    PipelineRoleArn=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/gbm-connect-pipeline-$ENVIRONMENT-role \
    BuildRoleArn=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/gbm-connect-build-$ENVIRONMENT-role
