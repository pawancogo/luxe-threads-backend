# syntax=docker/dockerfile:1
# Multi-stage Dockerfile for production deployment
# Optimized for security, performance, and minimal image size

# Read Ruby version from .ruby-version file (default fallback)
ARG RUBY_VERSION=3.3.6
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

# Read Bundler version from .bundler-version file (default fallback)
ARG BUNDLER_VERSION=2.6.8

# Install system dependencies and clean up in one layer to reduce image size
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    libpq-dev \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Set production environment variables
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development test" \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    LD_PRELOAD=libjemalloc.so.2

# Create app directory
WORKDIR /rails

# ============================================================================
# Build stage - install dependencies and compile assets
# ============================================================================
FROM base AS build

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libyaml-dev \
    pkg-config \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Install Bundler (version from build arg)
RUN gem install bundler -v "${BUNDLER_VERSION}" --no-document

# Copy dependency files
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Precompile bootsnap for faster boot times
RUN bundle exec bootsnap precompile app/ lib/ || true

# Make bin files executable
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# Precompile assets (using dummy secret key)
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile || true

# ============================================================================
# Final stage - minimal production image
# ============================================================================
FROM base

# Install runtime dependencies only
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    libpq5 \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Copy gems from build stage
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"

# Copy application from build stage
COPY --from=build /rails /rails

# Create non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd --system --uid 1000 --gid 1000 --create-home --shell /bin/bash rails && \
    chown -R rails:rails /rails

# Switch to non-root user
USER rails:rails

# Set working directory
WORKDIR /rails

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000/up || exit 1

# Expose port
EXPOSE 3000

# Entrypoint prepares the database and runs migrations
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Default command - start Puma server
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
