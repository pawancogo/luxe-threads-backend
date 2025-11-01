# Environment Setup Guide

## Overview
This guide explains how to set up environment variables and SMTP configuration for the LuxeThreads application.

## 1. Environment Variables Setup

### Create .env File
Create a `.env` file in the root directory with the following variables:

```bash
# ===========================================
# APPLICATION SETTINGS
# ===========================================
RAILS_ENV=production
SECRET_KEY_BASE=your_production_secret_key_base_here
HOST=yourdomain.com
PORT=3000

# ===========================================
# DATABASE CONFIGURATION
# ===========================================
DATABASE_URL=postgresql://username:password@localhost:5432/luxe_threads_production

# ===========================================
# JWT CONFIGURATION
# ===========================================
JWT_SECRET_KEY=your_jwt_secret_key_here_make_it_very_long_and_secure
JWT_ALGORITHM=HS256
JWT_EXPIRATION_TIME=24h

# ===========================================
# EMAIL CONFIGURATION (SMTP)
# ===========================================
# Production SMTP (SendGrid)
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_PORT=587
SMTP_DOMAIN=yourdomain.com
SMTP_USERNAME=apikey
SMTP_PASSWORD=your_sendgrid_api_key_here
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
SMTP_OPENSSL_VERIFY_MODE=none

# Email Settings
MAILER_FROM_EMAIL=noreply@yourdomain.com
MAILER_FROM_NAME=LuxeThreads
SUPPORT_EMAIL=support@yourdomain.com

# ===========================================
# CLOUDINARY CONFIGURATION
# ===========================================
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret

# ===========================================
# STRIPE CONFIGURATION
# ===========================================
STRIPE_PUBLISHABLE_KEY=pk_live_your_stripe_publishable_key
STRIPE_SECRET_KEY=sk_live_your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# ===========================================
# REDIS CONFIGURATION
# ===========================================
REDIS_URL=redis://username:password@your-redis-host:6379/0

# ===========================================
# SECURITY SETTINGS
# ===========================================
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
RATE_LIMIT_REQUESTS_PER_MINUTE=60
RATE_LIMIT_BURST=100

# ===========================================
# EMAIL VERIFICATION SETTINGS
# ===========================================
OTP_EXPIRY_MINUTES=15
OTP_LENGTH=6
MAX_OTP_ATTEMPTS=3
OTP_RESEND_COOLDOWN_MINUTES=1

# ===========================================
# ADMIN SETTINGS
# ===========================================
ADMIN_SESSION_TIMEOUT=8h
ADMIN_MAX_LOGIN_ATTEMPTS=5
ADMIN_LOCKOUT_DURATION=30m

# ===========================================
# LOGGING & MONITORING
# ===========================================
LOG_LEVEL=warn
SENTRY_DSN=your_sentry_dsn_here

# ===========================================
# FILE UPLOAD SETTINGS
# ===========================================
MAX_FILE_SIZE=10MB
ALLOWED_FILE_TYPES=jpg,jpeg,png,gif,pdf,doc,docx
```

## 2. SMTP Configuration Options

### Option 1: SendGrid (Recommended for Production)

1. **Sign up for SendGrid**: https://sendgrid.com/
2. **Create API Key**:
   - Go to Settings > API Keys
   - Create API Key with "Mail Send" permissions
   - Copy the API key

3. **Configure Environment Variables**:
```bash
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_PORT=587
SMTP_DOMAIN=yourdomain.com
SMTP_USERNAME=apikey
SMTP_PASSWORD=your_sendgrid_api_key_here
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
```

### Option 2: Gmail (For Development/Testing)

1. **Enable 2-Factor Authentication** on your Gmail account
2. **Generate App Password**:
   - Go to Google Account settings
   - Security > 2-Step Verification > App passwords
   - Generate password for "Mail"

3. **Configure Environment Variables**:
```bash
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=gmail.com
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_app_specific_password
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
```

### Option 3: Amazon SES

1. **Set up Amazon SES**:
   - Create AWS account
   - Verify your domain/email
   - Get SMTP credentials

2. **Configure Environment Variables**:
```bash
SMTP_ADDRESS=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_DOMAIN=yourdomain.com
SMTP_USERNAME=your_ses_smtp_username
SMTP_PASSWORD=your_ses_smtp_password
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
```

## 3. Development vs Production Settings

### Development Environment
```bash
# Development specific settings
RAILS_ENV=development
HOST=localhost
PORT=3000
LOG_EMAILS_TO_CONSOLE=true
SKIP_EMAIL_VERIFICATION_IN_DEV=false
LOG_LEVEL=debug
```

### Production Environment
```bash
# Production specific settings
RAILS_ENV=production
HOST=yourdomain.com
LOG_EMAILS_TO_CONSOLE=false
SKIP_EMAIL_VERIFICATION_IN_DEV=false
LOG_LEVEL=warn
```

## 4. Security Best Practices

### 1. Environment File Security
- **Never commit .env file** to version control
- Add `.env` to `.gitignore`
- Use different .env files for different environments
- Rotate secrets regularly

### 2. Secret Generation
```bash
# Generate Rails secret key
rails secret

# Generate JWT secret (use a long, random string)
openssl rand -hex 64
```

### 3. Database Security
- Use strong passwords
- Enable SSL connections
- Restrict database access by IP
- Regular backups

### 4. Email Security
- Use app-specific passwords (Gmail)
- Rotate API keys regularly
- Monitor email delivery rates
- Set up SPF, DKIM, and DMARC records

## 5. Deployment Checklist

### Before Deployment
- [ ] All environment variables set
- [ ] SMTP configuration tested
- [ ] Database migrations run
- [ ] SSL certificates configured
- [ ] Domain DNS configured
- [ ] Email deliverability tested

### After Deployment
- [ ] Test email verification flow
- [ ] Test admin login
- [ ] Test API endpoints
- [ ] Monitor error logs
- [ ] Set up monitoring/alerts

## 6. Testing Email Configuration

### Test SMTP Connection
```ruby
# In Rails console
ActionMailer::Base.smtp_settings
ActionMailer::Base.delivery_method

# Test email sending
EmailVerificationMailer.send_otp(verification).deliver_now
```

### Test Email Templates
```ruby
# Preview emails in development
# Visit: http://localhost:3000/rails/mailers/email_verification_mailer/send_otp
```

## 7. Troubleshooting

### Common Issues

1. **Email not sending**:
   - Check SMTP credentials
   - Verify firewall settings
   - Check spam folder
   - Test with different SMTP provider

2. **Authentication errors**:
   - Verify username/password
   - Check 2FA settings (Gmail)
   - Ensure API key has correct permissions

3. **Connection timeouts**:
   - Check network connectivity
   - Verify SMTP server address/port
   - Check firewall rules

### Debug Mode
```bash
# Enable detailed logging
LOG_LEVEL=debug

# Log emails to console in development
LOG_EMAILS_TO_CONSOLE=true
```

## 8. Monitoring & Alerts

### Email Delivery Monitoring
- Set up SendGrid webhooks
- Monitor bounce rates
- Track open/click rates
- Set up alerts for failures

### Application Monitoring
- Use Sentry for error tracking
- Monitor response times
- Track API usage
- Set up uptime monitoring

## 9. Backup & Recovery

### Environment Variables Backup
```bash
# Export environment variables
env > environment_backup.txt

# Store securely (encrypted)
gpg -c environment_backup.txt
```

### Database Backup
```bash
# PostgreSQL backup
pg_dump luxe_threads_production > backup_$(date +%Y%m%d).sql

# Restore
psql luxe_threads_production < backup_20241220.sql
```

This setup ensures your LuxeThreads application is production-ready with proper email verification and secure configuration management.





