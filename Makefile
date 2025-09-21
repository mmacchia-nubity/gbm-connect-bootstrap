.PHONY: help validate deploy-stg deploy-prd clean

help: ## 📖 Show this help message
	@echo "🚀 GBM Connect Bootstrap"
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

validate: ## ✅ Validate CloudFormation templates
	@echo "🔍 Validating templates..."
	@./scripts/validate.sh

deploy-stg: ## 🚀 Deploy to STG environment
	@echo "🚀 Deploying to STG..."
	@sam build
	@sam deploy --config-file config/samconfig-stg.toml --config-env stg

deploy-prd: ## 🏭 Deploy to PRD environment
	@echo "🏭 Deploying to PRD..."
	@sam build
	@sam deploy --config-file config/samconfig-prd.toml --config-env prd

clean: ## 🧹 Clean build artifacts
	@echo "🧹 Cleaning up..."
	@rm -rf .aws-sam/
	@echo "✅ Clean complete"