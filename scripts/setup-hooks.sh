#!/usr/bin/env bash
set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# Ensure hook script is executable
chmod +x scripts/pre-commit

# Configure Git to use scripts directory for hooks
git config core.hooksPath scripts

echo "Git pre-commit hook successfully configured via core.hooksPath."
