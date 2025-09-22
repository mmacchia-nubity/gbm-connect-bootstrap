#!/bin/bash
set -e

echo "🔍 Validating CloudFormation templates..."

if ! command -v cfn-lint &> /dev/null; then
    echo "⚠️  cfn-lint not found, installing..."
    pip install cfn-lint
fi

cfn-lint templates/*.yaml

echo "✅ All templates are valid!"
