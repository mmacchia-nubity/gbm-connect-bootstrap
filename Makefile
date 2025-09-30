.PHONY: help validate deploy-stg deploy-prd clean

help: ## Show this help message
	@echo "GBM Connect Bootstrap"
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

validate: ## Validate CloudFormation templates
	@./scripts/validate.sh

deploy-stg: ## Deploy to STG environment
	@./scripts/bootstrap.sh stg

deploy-prd: ## Deploy to PRD environment
	@./scripts/bootstrap.sh prd

clean: ##  Clean build artifacts
	@echo "Nothing to clean (SAM removed)"
