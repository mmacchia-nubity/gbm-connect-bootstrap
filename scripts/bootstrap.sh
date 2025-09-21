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

# Validate templates first
echo "🔍 Validating templates..."
./scripts/validate.sh

# Build
echo "🔨 Building SAM application..."
sam build

# Deploy
echo "📦 Deploying to $ENVIRONMENT..."
sam deploy --config-file "config/samconfig-$ENVIRONMENT.toml" --config-env "$ENVIRONMENT"

echo "✅ Bootstrap complete for $ENVIRONMENT environment!"