# 🚀 Production Deployment Guide

**Date:** 2025-01-18  
**Status:** ✅ **DEPLOYMENT INFRASTRUCTURE COMPLETE**

---

## 📋 Overview

This guide provides step-by-step instructions for deploying the LuxeThreads e-commerce platform to production with zero-downtime deployment strategy.

---

## 🎯 Phase 6: Production Deployment

### ✅ Completed Components

1. **Feature Flags System** ✅
   - Centralized feature flag management
   - Environment variable-based
   - Easy enable/disable without code changes

2. **Staging Environment** ✅
   - Staging configuration
   - Separate database
   - Testing environment

3. **Production Configuration** ✅
   - Production settings
   - SSL enforcement
   - Security headers
   - CORS configuration

4. **Deployment Scripts** ✅
   - Pre-deployment checks
   - Database backup
   - Staging deployment
   - Production deployment
   - Rollback procedures

5. **Monitoring Setup** ✅
   - Health checks
   - Error tracking (Sentry)
   - Performance monitoring
   - Logging configuration

---

## 📝 Pre-Deployment Checklist

### 1. Environment Setup

- [ ] Set up production database (PostgreSQL)
- [ ] Configure Redis for caching (optional but recommended)
- [ ] Set up SMTP server for emails
- [ ] Configure SSL certificates
- [ ] Set up error tracking (Sentry)
- [ ] Configure CDN (optional)

### 2. Environment Variables

Copy `.env.production.example` to `.env.production` and configure:

```bash
# Required
DATABASE_NAME=luxe_threads_production
DATABASE_USER=postgres
DATABASE_PASSWORD=secure_password
SECRET_KEY_BASE=generate_secure_key
FRONTEND_URL=https://yourdomain.com

# Optional but recommended
REDIS_URL=redis://localhost:6379/0
SENTRY_DSN=your_sentry_dsn
SMTP_* (email configuration)
```

### 3. Database Setup

```bash
# Create production database
rails db:create RAILS_ENV=production

# Run migrations
rails db:migrate RAILS_ENV=production

# Seed initial data (if needed)
rails db:seed RAILS_ENV=production
```

### 4. Pre-Deployment Verification

```bash
# Run pre-deployment checks
rails deployment:pre_deployment_check RAILS_ENV=production

# Verify production readiness
rails deployment:verify_production RAILS_ENV=production
```

---

## 🚀 Deployment Steps

### Step 1: Staging Deployment (Recommended First)

```bash
# Deploy to staging
rails deployment:deploy_staging RAILS_ENV=staging

# Test all features in staging
# Run API tests
./COMPREHENSIVE_API_TEST.sh https://staging.yourdomain.com/api/v1

# Manual testing
# Follow END_TO_END_TESTING_GUIDE.md
```

### Step 2: Production Deployment

#### Option A: Zero-Downtime Deployment (Recommended)

```bash
# 1. Pre-deployment checks
rails deployment:pre_deployment_check RAILS_ENV=production

# 2. Create backup
rails deployment:backup_database RAILS_ENV=production

# 3. Deploy code (without activating)
# - Deploy application code
# - Keep feature flags disabled initially

# 4. Run migrations (during maintenance window or using zero-downtime strategy)
rails db:migrate RAILS_ENV=production

# 5. Validate data
rails data:validate RAILS_ENV=production

# 6. Enable feature flags gradually
# Set environment variables:
# FEATURE_NEW_NOTIFICATION_SYSTEM=true
# FEATURE_SUPPORT_TICKETS=true
# etc.

# 7. Monitor
# - Check error logs
# - Monitor performance
# - Verify functionality
```

#### Option B: Standard Deployment

```bash
# Full deployment with checks
rails deployment:deploy_production RAILS_ENV=production
```

---

## 🔄 Rollback Procedures

### Quick Rollback

```bash
# Rollback last migration
rails rollback:database RAILS_ENV=production

# Disable all feature flags (emergency)
rails rollback:disable_all_features RAILS_ENV=production
```

### Rollback to Specific Version

```bash
# Rollback to specific migration version
rails rollback:to_version[VERSION] RAILS_ENV=production
```

### Database Restore

```bash
# Restore from backup
# Use the backup file created in backups/ directory
PGPASSWORD=password psql -h host -U user -d database < backup_file.sql
```

---

## 📊 Monitoring & Health Checks

### Health Check Endpoint

Rails provides a health check endpoint:
```
GET /up
```

### Manual Health Checks

```bash
# Application health
rails monitoring:health_check RAILS_ENV=production

# Application metrics
rails monitoring:metrics RAILS_ENV=production

# Error rates
rails monitoring:check_errors RAILS_ENV=production
```

---

## 🔐 Security Checklist

### Pre-Production
- [ ] SSL certificates configured
- [ ] CORS origins restricted
- [ ] Rate limiting enabled
- [ ] Input sanitization verified
- [ ] Environment variables secured
- [ ] Database credentials secured
- [ ] Secret keys rotated

### Post-Deployment
- [ ] HTTPS enforced
- [ ] Security headers configured
- [ ] Error tracking working
- [ ] Logging configured
- [ ] Backup strategy verified

---

## 📈 Performance Monitoring

### Key Metrics to Monitor

1. **Response Times**
   - API endpoint response times
   - Database query times
   - Cache hit rates

2. **Error Rates**
   - 4xx errors (client errors)
   - 5xx errors (server errors)
   - Exception rates

3. **Resource Usage**
   - Database connections
   - Memory usage
   - CPU usage

4. **Business Metrics**
   - Orders per hour
   - Active users
   - API requests per minute

### Monitoring Tools

- **Application:** Sentry, New Relic, Datadog
- **Infrastructure:** Server monitoring (e.g., AWS CloudWatch)
- **Logs:** Centralized logging (e.g., ELK stack, Papertrail)

---

## 🎛️ Feature Flags Management

### Enable/Disable Features

Feature flags are controlled via environment variables:

```bash
# Enable a feature
export FEATURE_NEW_NOTIFICATION_SYSTEM=true

# Disable a feature
export FEATURE_NEW_NOTIFICATION_SYSTEM=false
```

### Check Feature Status

```ruby
# In code
if FeatureFlags.check(:new_notification_system)
  # Feature is enabled
end

# In controllers
if feature_enabled?(:new_notification_system)
  # Feature is enabled
end
```

---

## 🚨 Emergency Procedures

### High Error Rate

1. **Check logs:**
   ```bash
   tail -f log/production.log
   ```

2. **Disable problematic features:**
   ```bash
   rails rollback:disable_all_features
   ```

3. **Rollback if needed:**
   ```bash
   rails rollback:database
   ```

### Database Issues

1. **Stop writes** (if possible)
2. **Check database logs**
3. **Restore from backup** if needed
4. **Rollback migrations** if safe

### Performance Degradation

1. **Check monitoring metrics**
2. **Review slow queries**
3. **Check cache status**
4. **Scale resources** if needed

---

## 📝 Post-Deployment Tasks

### Immediate (First Hour)
- [ ] Monitor error logs
- [ ] Check application health
- [ ] Verify critical features
- [ ] Check database performance

### Short-term (First Day)
- [ ] Monitor user activity
- [ ] Check error rates
- [ ] Review performance metrics
- [ ] Gather user feedback

### Long-term (First Week)
- [ ] Performance optimization
- [ ] Address any issues
- [ ] Update documentation
- [ ] Team training

---

## ✅ Success Criteria

### Deployment Successful When:
- [ ] All migrations run successfully
- [ ] No errors in logs
- [ ] Health checks pass
- [ ] All features working
- [ ] Performance acceptable
- [ ] Monitoring active

---

## 📚 Documentation

1. **DEPLOYMENT_GUIDE.md** - This document
2. **.env.production.example** - Environment variables template
3. **.env.staging.example** - Staging variables template
4. **Feature Flags** - `config/initializers/feature_flags.rb`
5. **Monitoring** - `config/initializers/monitoring.rb`

---

*Deployment Guide - 2025-01-18*  
*Phase 6: Production Deployment Infrastructure Complete*

