#!/bin/bash

set -e

echo "🔍 Validating CloudFormation templates..."

# Check if cfn-lint is installed
if ! command -v cfn-lint &> /dev/null; then
    echo "⚠️  cfn-lint not found, installing..."
    pip install cfn-lint
fi

# Validate with SAM
echo "📋 Running SAM validate..."
sam validate

# Validate with cfn-lint
echo "🔍 Running cfn-lint..."
cfn-lint templates/*.yaml

echo "✅ All templates are valid!"