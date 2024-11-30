#!/bin/bash

# Get branch name (e.g., from CI/CD pipeline)
BRANCH_NAME=${BRANCH_NAME:-$(git rev-parse --abbrev-ref HEAD)}

# Define environment based on branch
if [ "$BRANCH_NAME" == "master" ]; then
  ENV_FILE="values-production.yaml"
elif [ "$BRANCH_NAME" == "staging" ]; then
  ENV_FILE="values-staging.yaml"
else
  echo "Unknown branch: $BRANCH_NAME"
  exit 1
fi

# Helm deployment command
helm upgrade --install my-app ./deploy/helm/charts/my-app -f ./deploy/helm/charts/$ENV_FILE
