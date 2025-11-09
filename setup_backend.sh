#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read versions from version files (similar to .nvmrc for Node.js)
if [[ -f "$SCRIPT_DIR/.ruby-version" ]]; then
  REQUIRED_RUBY="$(cat "$SCRIPT_DIR/.ruby-version" | tr -d '\n' | sed 's/^v//')"
else
  REQUIRED_RUBY="3.3.6"
  echo "${REQUIRED_RUBY}" > "$SCRIPT_DIR/.ruby-version"
fi

if [[ -f "$SCRIPT_DIR/.bundler-version" ]]; then
  BUNDLER_VERSION="$(cat "$SCRIPT_DIR/.bundler-version" | tr -d '\n')"
else
  BUNDLER_VERSION="2.6.8"
  echo "${BUNDLER_VERSION}" > "$SCRIPT_DIR/.bundler-version"
fi

log() {
  printf '\n[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

error() {
  printf '\nERROR: %s\n' "$*" 1>&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

compare_versions() {
  # Returns 0 (true) when $1 >= $2, otherwise 1 (false)
  local IFS=.
  local -a v1=($1) v2=($2)
  local i len diff
  len=${#v1[@]}
  if [ ${#v2[@]} -gt $len ]; then
    len=${#v2[@]}
  fi
  for ((i=0; i<len; i++)); do
    local num1=${v1[i]:-0}
    local num2=${v2[i]:-0}
    if ((10#$num1 > 10#$num2)); then
      return 0
    fi
    if ((10#$num1 < 10#$num2)); then
      return 1
    fi
  done
  return 0
}

ensure_ruby_version() {
  log "Checking Ruby version (project-local only)"
  
  # Check if .ruby-version exists
  if [[ -f "$SCRIPT_DIR/.ruby-version" ]]; then
    local project_ruby
    project_ruby="$(cat "$SCRIPT_DIR/.ruby-version" | tr -d '\n')"
    log "Found .ruby-version: ${project_ruby}"
  else
    # Create .ruby-version if it doesn't exist
    echo "${REQUIRED_RUBY}" > "$SCRIPT_DIR/.ruby-version"
    log "Created .ruby-version with ${REQUIRED_RUBY}"
    local project_ruby="${REQUIRED_RUBY}"
  fi
  
  # Try to use rbenv (project-local)
  if command_exists rbenv || [[ -d "$HOME/.rbenv" ]]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)" 2>/dev/null || true
    
    if ! rbenv versions --bare | grep -q "^${project_ruby}$"; then
      log "Installing Ruby ${project_ruby} (project-local via rbenv)..."
      rbenv install -s "${project_ruby}" || error "Failed to install Ruby ${project_ruby}"
    fi
    
    # Set local version (project-level only)
    rbenv local "${project_ruby}" 2>/dev/null || true
    eval "$(rbenv init -)" 2>/dev/null || true
    hash -r 2>/dev/null || true
    
    local ruby_version
    ruby_version="$(ruby -e 'print RUBY_VERSION' 2>/dev/null || echo '0.0.0')"
    
    if compare_versions "$ruby_version" "$project_ruby"; then
      log "Ruby version check passed: ${ruby_version} (project-local)"
    else
      error "Ruby ${project_ruby} required, found ${ruby_version}. Please install it manually: rbenv install ${project_ruby}"
    fi
    return
  fi
  
  # Try asdf (project-local)
  if command_exists asdf || [[ -d "$HOME/.asdf" ]]; then
    . "$HOME/.asdf/asdf.sh" 2>/dev/null || true
    
    if ! asdf list ruby 2>/dev/null | grep -q "${project_ruby}"; then
      log "Installing Ruby ${project_ruby} (project-local via asdf)..."
      asdf plugin add ruby 2>/dev/null || true
      asdf install ruby "${project_ruby}" || error "Failed to install Ruby ${project_ruby}"
    fi
    
    # Set local version (project-level only)
    echo "ruby ${project_ruby}" > "$SCRIPT_DIR/.tool-versions"
    asdf reshim ruby 2>/dev/null || true
    
    local ruby_version
    ruby_version="$(ruby -e 'print RUBY_VERSION' 2>/dev/null || echo '0.0.0')"
    
    if compare_versions "$ruby_version" "$project_ruby"; then
      log "Ruby version check passed: ${ruby_version} (project-local)"
    else
      error "Ruby ${project_ruby} required, found ${ruby_version}. Please install it manually: asdf install ruby ${project_ruby}"
    fi
    return
  fi
  
  # Fallback: check if Ruby is available and matches
  if command_exists ruby; then
    local ruby_version
    ruby_version="$(ruby -e 'print RUBY_VERSION' 2>/dev/null || echo '0.0.0')"
    
    if compare_versions "$ruby_version" "$project_ruby"; then
      log "Ruby version check passed: ${ruby_version}"
      log "Note: Consider using rbenv or asdf for project-local Ruby management"
    else
      error "Ruby ${project_ruby}+ required, found ${ruby_version}. Please install it manually."
    fi
  else
    error "Ruby is required. Please install Ruby ${project_ruby} using rbenv or asdf for project-local management."
  fi
}

ensure_bundler() {
  log "Checking Bundler (project-local)"
  
  if ! command_exists bundle || ! bundle _${BUNDLER_VERSION}_ --version >/dev/null 2>&1; then
    log "Installing Bundler ${BUNDLER_VERSION} (project-local)..."
    gem install bundler -v "${BUNDLER_VERSION}" --no-document --user-install || \
    gem install bundler -v "${BUNDLER_VERSION}" --no-document || \
    error "Failed to install Bundler"
    log "Bundler ${BUNDLER_VERSION} installed successfully"
  else
    log "Bundler version check passed"
  fi
}

ensure_prerequisites() {
  log "Checking prerequisites (project-local only)"
  
  # Check git
  if ! command_exists git; then
    error "git is required. Install it via https://git-scm.com/downloads"
  fi
  
  # Check and setup Ruby (project-local)
  ensure_ruby_version
  
  # Verify Ruby is available
  if ! command_exists ruby; then
    error "Ruby installation failed. Please install Ruby ${REQUIRED_RUBY} manually."
  fi
  
  # Install/check Bundler (project-local)
  ensure_bundler
  
  # Check SQLite (optional but recommended)
  if ! command_exists sqlite3; then
    log "Warning: sqlite3 not found. Install SQLite for local Rails development."
    if [[ "$OSTYPE" == "darwin"* ]] && command_exists brew; then
      log "You can install it with: brew install sqlite3"
    fi
  else
    log "sqlite3 check passed"
  fi
  
  # Check Redis (optional)
  if ! command_exists redis-server; then
    log "Warning: redis-server not found. Redis-backed cache features will need a Redis instance."
    if [[ "$OSTYPE" == "darwin"* ]] && command_exists brew; then
      log "You can install it with: brew install redis"
    fi
  else
    log "redis-server check passed"
  fi
  
  log "All prerequisites checked (project-local)"
}

setup_backend() {
  log "Setting up luxe-threads-backend (Rails)"
  pushd "$SCRIPT_DIR" >/dev/null
  
  # Install gems (project-local)
  log "Installing gems..."
  bundle _${BUNDLER_VERSION}_ install || error "Failed to install gems"
  
  # Setup database
  log "Setting up database..."
  bundle exec rails db:prepare || error "Failed to setup database"
  
  popd >/dev/null
  log "Backend setup complete"
}

main() {
  log "Starting backend setup (project-local configuration only)"
  ensure_prerequisites
  setup_backend
  log "Setup complete! All configurations are project-local."
}

main "$@"

