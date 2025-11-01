#!/bin/bash

# LuxeThreads Environment Setup Script
# This script helps you set up the environment variables

echo "🚀 LuxeThreads Environment Setup"
echo "================================="

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "📝 Creating .env file from template..."
    
    # Copy development template
    cp .env.development .env
    echo "✅ .env file created from development template"
else
    echo "✅ .env file already exists"
fi

echo ""
echo "🔧 Next Steps:"
echo "1. Edit .env file with your actual values:"
echo "   nano .env"
echo ""
echo "2. Generate secure secrets:"
echo "   ruby scripts/generate_secrets.rb"
echo ""
echo "3. Install dependencies:"
echo "   bundle install"
echo ""
echo "4. Set up database:"
echo "   rails db:create"
echo "   rails db:migrate"
echo "   rails db:seed"
echo ""
echo "5. Test email configuration:"
echo "   rails console"
echo "   # Then run: EmailVerificationMailer.send_otp(verification).deliver_now"
echo ""
echo "📚 For detailed setup instructions, see:"
echo "   ENVIRONMENT_SETUP.md"
echo ""
echo "🔐 Security Reminder:"
echo "   - Never commit .env files to version control"
echo "   - Use different secrets for development and production"
echo "   - Keep your SMTP credentials secure"
echo ""
echo "✅ Setup script complete!"



