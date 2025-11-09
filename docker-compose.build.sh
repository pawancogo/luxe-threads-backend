#!/usr/bin/env bash

# Docker Compose build script that reads versions from version files
# This ensures consistency between local setup and Docker builds

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read Ruby version from .ruby-version
if [[ -f "$SCRIPT_DIR/.ruby-version" ]]; then
  RUBY_VERSION="$(cat "$SCRIPT_DIR/.ruby-version" | tr -d '\n' | sed 's/^v//')"
  export RUBY_VERSION
  echo "Using Ruby version from .ruby-version: ${RUBY_VERSION}"
else
  RUBY_VERSION="3.3.6"
  export RUBY_VERSION
  echo "Warning: .ruby-version not found, using default: ${RUBY_VERSION}"
fi

# Read Bundler version from .bundler-version
if [[ -f "$SCRIPT_DIR/.bundler-version" ]]; then
  BUNDLER_VERSION="$(cat "$SCRIPT_DIR/.bundler-version" | tr -d '\n')"
  export BUNDLER_VERSION
  echo "Using Bundler version from .bundler-version: ${BUNDLER_VERSION}"
else
  BUNDLER_VERSION="2.6.8"
  export BUNDLER_VERSION
  echo "Warning: .bundler-version not found, using default: ${BUNDLER_VERSION}"
fi

# Build with docker-compose using versions from files
# Pass versions as environment variables to docker-compose
RUBY_VERSION="${RUBY_VERSION}" BUNDLER_VERSION="${BUNDLER_VERSION}" \
  docker-compose -f docker-compose.production.yml build "$@"

echo "Docker Compose build complete with Ruby ${RUBY_VERSION} and Bundler ${BUNDLER_VERSION}"

