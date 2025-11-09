# Docker Deployment Guide

Complete guide for deploying Luxe Threads Backend using Docker.

## Overview

This guide covers:
- Building production Docker images
- Running with Docker Compose
- Environment configuration
- Health checks and monitoring
- Production best practices

## Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- PostgreSQL 15+ (or use included docker-compose)
- Redis (or use included docker-compose)

## Quick Start

### 1. Configure Environment Variables

```bash
cd luxe-threads-backend
cp .env.production.example .env.production
# Edit .env.production with your values
```

**Required variables:**
- `RAILS_MASTER_KEY` - Get from `config/master.key` or generate new one
- `SECRET_KEY_BASE` - Generate with `rails secret`
- `DATABASE_PASSWORD` - Strong password for PostgreSQL

### 2. Generate Secrets

```bash
# Generate SECRET_KEY_BASE
rails secret

# Get RAILS_MASTER_KEY (if you have config/master.key)
cat config/master.key
```

### 3. Build and Start

**Version Management:**
The project uses version files (similar to `.nvmrc` for Node.js):
- `.ruby-version` - Ruby version (currently: 3.3.0)
- `.bundler-version` - Bundler version (currently: 2.5.3)

These versions are automatically read by the build scripts.

**Build Options:**

```bash
# Option 1: Use build script (reads from .ruby-version and .bundler-version)
./docker-build.sh

# Option 2: Use docker-compose build script
./docker-compose.build.sh

# Option 3: Manual build (versions from files)
docker build \
  --build-arg RUBY_VERSION=$(cat .ruby-version) \
  --build-arg BUNDLER_VERSION=$(cat .bundler-version) \
  -t luxe-threads-backend:latest .

# Option 4: Use docker-compose for full stack
docker-compose -f docker-compose.production.yml up -d --build
```

## Docker Compose Deployment

### Full Stack (Recommended)

The `docker-compose.production.yml` includes:
- **PostgreSQL** - Database
- **Redis** - Caching and job queue
- **Rails App** - Application server
- **Nginx** - Reverse proxy (optional)

```bash
# Start all services
docker-compose -f docker-compose.production.yml up -d

# View logs
docker-compose -f docker-compose.production.yml logs -f

# Stop all services
docker-compose -f docker-compose.production.yml down

# Stop and remove volumes (⚠️ deletes data)
docker-compose -f docker-compose.production.yml down -v
```

### Environment Variables

Set variables in `.env.production` or export them:

```bash
export RAILS_MASTER_KEY=your_key_here
export SECRET_KEY_BASE=your_secret_here
export DATABASE_PASSWORD=secure_password
```

Or use a `.env` file:

```bash
docker-compose -f docker-compose.production.yml --env-file .env.production up -d
```

## Manual Docker Deployment

### Build Image

**Recommended:** Use the build script that reads from version files:

```bash
./docker-build.sh
```

**Manual build** (reading versions from files):

```bash
docker build \
  --build-arg RUBY_VERSION=$(cat .ruby-version) \
  --build-arg BUNDLER_VERSION=$(cat .bundler-version) \
  -t luxe-threads-backend:latest \
  .
```

**Manual build** (with explicit versions):

```bash
docker build \
  --build-arg RUBY_VERSION=3.3.0 \
  --build-arg BUNDLER_VERSION=2.5.3 \
  -t luxe-threads-backend:latest \
  .
```

### Run Container

```bash
docker run -d \
  --name luxe_threads_app \
  -p 3000:3000 \
  -e RAILS_ENV=production \
  -e RAILS_MASTER_KEY=your_key \
  -e SECRET_KEY_BASE=your_secret \
  -e DATABASE_URL=postgresql://user:pass@host:5432/dbname \
  -e REDIS_URL=redis://host:6379/0 \
  --restart unless-stopped \
  luxe-threads-backend:latest
```

## Database Setup

### First Time Setup

```bash
# Run migrations
docker-compose -f docker-compose.production.yml exec app bundle exec rails db:migrate

# Seed database (optional)
docker-compose -f docker-compose.production.yml exec app bundle exec rails db:seed
```

### Database Migrations

```bash
# Run new migrations
docker-compose -f docker-compose.production.yml exec app bundle exec rails db:migrate

# Rollback
docker-compose -f docker-compose.production.yml exec app bundle exec rails db:rollback
```

## Health Checks

The application includes health check endpoints:

```bash
# Check application health
curl http://localhost:3000/up

# Response:
{
  "status": "healthy",
  "timestamp": "2025-01-18T00:00:00Z",
  "checks": {
    "database": "ok",
    "redis": "ok"
  }
}
```

## Monitoring

### View Logs

```bash
# All services
docker-compose -f docker-compose.production.yml logs -f

# Specific service
docker-compose -f docker-compose.production.yml logs -f app

# Last 100 lines
docker-compose -f docker-compose.production.yml logs --tail=100 app
```

### Container Status

```bash
# Check container status
docker-compose -f docker-compose.production.yml ps

# Container health
docker inspect luxe_threads_app | grep -A 10 Health
```

### Resource Usage

```bash
# Container stats
docker stats luxe_threads_app

# Disk usage
docker system df
```

## Production Best Practices

### 1. Security

- ✅ Use strong passwords for database
- ✅ Set `DATABASE_SSLMODE=require` in production
- ✅ Use secrets management (Docker secrets, AWS Secrets Manager, etc.)
- ✅ Run as non-root user (already configured)
- ✅ Keep images updated

### 2. Performance

- ✅ Use connection pooling (configured in database.yml)
- ✅ Enable jemalloc (already configured)
- ✅ Use Redis for caching
- ✅ Configure Puma workers based on CPU cores

### 3. Scaling

```bash
# Scale app containers
docker-compose -f docker-compose.production.yml up -d --scale app=3

# Use load balancer (nginx) to distribute traffic
```

### 4. Backups

```bash
# Backup PostgreSQL
docker-compose -f docker-compose.production.yml exec postgres pg_dump -U postgres luxe_threads_production > backup.sql

# Restore
docker-compose -f docker-compose.production.yml exec -T postgres psql -U postgres luxe_threads_production < backup.sql
```

## Nginx Configuration

Nginx is included for reverse proxy and SSL termination.

### SSL Setup

1. Place SSL certificates in `config/ssl/`:
   - `cert.pem` - Certificate
   - `key.pem` - Private key

2. Update `config/nginx.conf` to enable HTTPS server block

3. Restart nginx:
```bash
docker-compose -f docker-compose.production.yml restart nginx
```

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose -f docker-compose.production.yml logs app

# Check environment variables
docker-compose -f docker-compose.production.yml exec app env

# Verify database connection
docker-compose -f docker-compose.production.yml exec app bundle exec rails db:version
```

### Database Connection Issues

```bash
# Test database connection
docker-compose -f docker-compose.production.yml exec app bundle exec rails db:version

# Check PostgreSQL logs
docker-compose -f docker-compose.production.yml logs postgres
```

### Memory Issues

```bash
# Check memory usage
docker stats

# Increase memory limits in docker-compose.yml
# Add to app service:
deploy:
  resources:
    limits:
      memory: 2G
```

### Build Failures

```bash
# Clean build (no cache)
docker build --no-cache -t luxe-threads-backend:latest .

# Check build logs
docker build -t luxe-threads-backend:latest . 2>&1 | tee build.log
```

## Updating Application

```bash
# Pull latest code
git pull

# Rebuild image
docker-compose -f docker-compose.production.yml build app

# Restart with new image
docker-compose -f docker-compose.production.yml up -d app

# Run migrations
docker-compose -f docker-compose.production.yml exec app bundle exec rails db:migrate
```

## Zero-Downtime Deployment

For zero-downtime deployments:

1. Build new image
2. Start new container alongside old one
3. Run migrations
4. Switch traffic (via load balancer)
5. Stop old container

Or use orchestration tools:
- **Kamal** (included in Gemfile)
- **Kubernetes**
- **Docker Swarm**

## Environment-Specific Configs

### Development

```bash
docker-compose up -d
```

### Staging

```bash
docker-compose -f docker-compose.production.yml --env-file .env.staging up -d
```

### Production

```bash
docker-compose -f docker-compose.production.yml --env-file .env.production up -d
```

## Security Checklist

- [ ] Change all default passwords
- [ ] Use strong `SECRET_KEY_BASE`
- [ ] Enable SSL/TLS
- [ ] Set `DATABASE_SSLMODE=require`
- [ ] Use secrets management
- [ ] Enable firewall rules
- [ ] Regular security updates
- [ ] Monitor logs for suspicious activity
- [ ] Use non-root user (already configured)
- [ ] Limit container resources

## Support

For deployment issues:
- Check logs: `docker-compose logs -f`
- Verify environment variables
- Test database connectivity
- Check health endpoint: `curl http://localhost:3000/up`

