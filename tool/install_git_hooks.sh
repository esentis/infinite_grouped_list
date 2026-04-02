#!/usr/bin/env bash

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

chmod +x .githooks/pre-push
git config core.hooksPath .githooks

echo "Git hooks installed for $repo_root"
echo "core.hooksPath=$(git config --get core.hooksPath)"
