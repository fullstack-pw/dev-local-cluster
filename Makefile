# Makefile for Local Development Environment Setup

.PHONY: help check-deps install-rancher setup-rancher check-cluster terraform-init terraform-plan terraform-apply deploy clean status

# Default target
help: ## Show this help message
	@echo "Local Development Environment Setup"
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Check if required tools are installed
check-deps: ## Check if required dependencies are installed
	@echo "Checking dependencies..."
	@command -v brew >/dev/null 2>&1 || { echo "❌ Homebrew is required but not installed. Please install from https://brew.sh/"; exit 1; }
	@echo "✅ Homebrew found"
	@command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform not found. Installing..."; brew install terraform; }
	@echo "✅ Terraform found"

# Check if Rancher Desktop is installed
check-rancher: ## Check if Rancher Desktop is installed
	@if ! test -d "/Applications/Rancher Desktop.app"; then \
		echo "❌ Rancher Desktop not found in Applications"; \
		$(MAKE) install-rancher; \
	else \
		echo "✅ Rancher Desktop found"; \
	fi

# Install Rancher Desktop
install-rancher: ## Install Rancher Desktop using Homebrew
	@echo "Installing Rancher Desktop..."
	@brew install --cask rancher
	@echo "✅ Rancher Desktop installed"
	@echo "⚠️  Please start Rancher Desktop manually from Applications and complete the initial setup"
	@echo "⚠️  Make sure to enable Kubernetes in Rancher Desktop settings"
	@echo "⚠️  Run 'make setup-rancher' after Rancher Desktop is running"

# Setup Rancher Desktop context
setup-rancher: ## Setup kubectl context for Rancher Desktop
	@echo "Setting up Rancher Desktop context..."
	@if ! kubectl config get-contexts rancher-desktop >/dev/null 2>&1; then \
		echo "❌ rancher-desktop context not found. Make sure Rancher Desktop is running with Kubernetes enabled"; \
		exit 1; \
	fi
	@kubectl config use-context rancher-desktop
	@echo "✅ Switched to rancher-desktop context"

# Check if cluster is accessible
check-cluster: ## Check if Kubernetes cluster is accessible
	@echo "Checking cluster access..."
	@kubectl cluster-info --context rancher-desktop >/dev/null 2>&1 || { \
		echo "❌ Cannot access Rancher Desktop cluster"; \
		echo "Please ensure:"; \
		echo "  1. Rancher Desktop is running"; \
		echo "  2. Kubernetes is enabled in Rancher Desktop"; \
		echo "  3. Run 'make setup-rancher' to set context"; \
		exit 1; \
	}
	@echo "✅ Cluster is accessible"
	@kubectl get nodes --context rancher-desktop

# Initialize Terraform
terraform-init: ## Initialize Terraform
	@echo "Initializing Terraform..."
	@terraform init
	@echo "✅ Terraform initialized"

# Plan Terraform deployment
terraform-plan: terraform-init ## Plan Terraform deployment
	@echo "Planning Terraform deployment..."
	@terraform plan
	@echo "✅ Terraform plan completed"

# Apply Terraform configuration
terraform-apply: terraform-init ## Apply Terraform configuration
	@echo "Applying Terraform configuration..."
	@terraform apply -auto-approve
	@echo "✅ Infrastructure deployed"

# Full deployment pipeline
deploy: check-deps check-rancher setup-rancher check-cluster terraform-apply ## Full deployment pipeline
	@echo ""
	@echo "🎉 Deployment completed successfully!"
	@echo ""
	@echo "Connection details:"
	@terraform output -json | jq -r 'to_entries[] | "  \(.key): \(.value.value)"'
	@echo ""
	@echo "Useful commands:"
	@echo "  kubectl get pods                    # Check running pods"
	@echo "  kubectl get services                # Check services"
	@echo "  kubectl port-forward svc/mysql 3306:3306  # Access MySQL locally"

# Show current status
status: ## Show status of deployed resources
	@echo "Kubernetes Resources:"
	@kubectl get pods,services,pvc --context rancher-desktop
	@echo ""
	@echo "Terraform Outputs:"
	@terraform output 2>/dev/null || echo "Run 'terraform apply' first"

# Clean up resources
clean: ## Clean up all deployed resources
	@echo "Cleaning up resources..."
	@terraform destroy -auto-approve
	@echo "✅ Resources cleaned up"

# Quick start (interactive)
quick-start: ## Interactive quick start
	@echo "🚀 Local Development Environment Quick Start"
	@echo ""
	@echo "This will:"
	@echo "  1. Check and install dependencies"
	@echo "  2. Setup Rancher Desktop"
	@echo "  3. Deploy infrastructure"
	@echo ""
	@read -p "Continue? (y/N): " confirm && [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ] || { echo "Aborted."; exit 1; }
	@$(MAKE) deploy

# Development helpers
logs-mysql: ## Show MySQL logs
	@kubectl logs -l app.kubernetes.io/name=mysql --tail=50 -f

logs-localstack: ## Show LocalStack logs  
	@kubectl logs -l app.kubernetes.io/name=localstack --tail=50 -f

port-forward-mysql: ## Port forward MySQL to localhost:3306
	@echo "Port forwarding MySQL to localhost:3306..."
	@echo "Use Ctrl+C to stop"
	@kubectl port-forward svc/mysql 3306:3306

port-forward-localstack: ## Port forward LocalStack to localhost:4566
	@echo "Port forwarding LocalStack to localhost:4566..."
	@echo "Use Ctrl+C to stop"  
	@kubectl port-forward svc/localstack 4566:4566

# Troubleshooting
troubleshoot: ## Run troubleshooting checks
	@echo "🔍 Running troubleshooting checks..."
	@echo ""
	@echo "1. Checking Rancher Desktop:"
	@ps aux | grep -i rancher || echo "❌ Rancher Desktop not running"
	@echo ""
	@echo "2. Checking kubectl contexts:"
	@kubectl config get-contexts
	@echo ""
	@echo "3. Checking cluster access:"
	@kubectl cluster-info --context rancher-desktop 2>/dev/null || echo "❌ Cannot access cluster"
	@echo ""
	@echo "4. Checking pods:"
	@kubectl get pods --context rancher-desktop 2>/dev/null || echo "❌ Cannot get pods"
	@echo ""
	@echo "5. Checking Terraform state:"
	@terraform show 2>/dev/null | head -10 || echo "❌ No Terraform state found"