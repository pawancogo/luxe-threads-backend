#!/usr/bin/env bash

# Docker build script that reads versions from .ruby-version and .bundler-version
# Similar to how nvm uses .nvmrc

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read Ruby version from .ruby-version
if [[ -f "$SCRIPT_DIR/.ruby-version" ]]; then
  RUBY_VERSION="$(cat "$SCRIPT_DIR/.ruby-version" | tr -d '\n' | sed 's/^v//')"
  echo "Using Ruby version from .ruby-version: ${RUBY_VERSION}"
else
  RUBY_VERSION="3.3.6"
  echo "Warning: .ruby-version not found, using default: ${RUBY_VERSION}"
fi

# Read Bundler version from .bundler-version
if [[ -f "$SCRIPT_DIR/.bundler-version" ]]; then
  BUNDLER_VERSION="$(cat "$SCRIPT_DIR/.bundler-version" | tr -d '\n')"
  echo "Using Bundler version from .bundler-version: ${BUNDLER_VERSION}"
else
  BUNDLER_VERSION="2.6.8"
  echo "Warning: .bundler-version not found, using default: ${BUNDLER_VERSION}"
fi

# Build Docker image with versions from files
docker build \
  --build-arg RUBY_VERSION="${RUBY_VERSION}" \
  --build-arg BUNDLER_VERSION="${BUNDLER_VERSION}" \
  -t luxe-threads-backend:latest \
  "$@"

echo "Docker image built successfully with Ruby ${RUBY_VERSION} and Bundler ${BUNDLER_VERSION}"

