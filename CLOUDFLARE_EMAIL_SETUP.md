# Cloudflare Workers Email Setup for Inventory Tracker

This guide shows how to set up Cloudflare Workers for email sending from your Phoenix application.

## Architecture Overview

```
Phoenix App → Cloudflare Worker → Cloudflare Email API → Email Delivery
```

Your Phoenix app sends email data to a Cloudflare Worker at `https://email.pondi.app/send`, which then uses Cloudflare's Email API to send the actual emails.

## Prerequisites

1. Domain (pondi.app) managed by Cloudflare
2. Cloudflare account with Workers enabled
3. Node.js and npm installed locally
4. Wrangler CLI: `npm install -g wrangler`

## Step 1: Enable Cloudflare Email Routing

1. Go to Cloudflare Dashboard → pondi.app → Email
2. Enable "Email Routing"
3. Add destination addresses (your email where emails should be forwarded)
4. Set up MX records (Cloudflare will auto-configure)
5. Verify email routing is working

## Step 2: Create API Token for Worker

1. Go to Cloudflare Dashboard → My Profile → API Tokens  
2. Click "Create Token"
3. Use "Custom token" template
4. Set permissions:
   - Account:Cloudflare Workers:Edit
   - Zone:Zone:Read (for pondi.app)
   - Account:Account Settings:Read
5. Set Account Resources: Include your account
6. Set Zone Resources: Include pondi.app
7. Copy the API token (save it securely)

## Step 3: Deploy the Cloudflare Worker

### 3.1 Navigate to Worker Directory
```bash
cd cloudflare-worker/
```

### 3.2 Install Wrangler (if not already installed)
```bash
npm install -g wrangler
```

### 3.3 Login to Cloudflare
```bash
wrangler login
```

### 3.4 Set Worker Secrets
```bash
# Set your Cloudflare Account ID
wrangler secret put CLOUDFLARE_ACCOUNT_ID
# Enter your account ID when prompted

# Set API token with email permissions  
wrangler secret put CLOUDFLARE_API_TOKEN
# Enter your API token when prompted

# Set a shared secret for Phoenix app authentication
wrangler secret put PHOENIX_API_KEY
# Enter a random secure string (save this for Phoenix config)
```

### 3.5 Deploy the Worker
```bash
# Deploy to production
wrangler deploy

# The worker will be available at: https://email.pondi.app/send
```

## Step 4: Configure Phoenix Environment Variables

Set these environment variables for your Phoenix production deployment:

```bash
# The shared secret you set in the Worker
CLOUDFLARE_WORKER_API_KEY=your_shared_secret_here

# Worker URL (defaults to https://email.pondi.app/send)
CLOUDFLARE_WORKER_URL=https://email.pondi.app/send
```

## Step 5: Test Email Functionality

1. Deploy your application
2. Try registering a new user
3. Check that confirmation emails are sent
4. Monitor Cloudflare Dashboard → Analytics → Email for delivery status

## Development vs Production

- **Development**: Uses `Swoosh.Adapters.Local` (emails at /dev/mailbox)
- **Production**: Uses `InventaryTraker.Mailer.CloudflareAdapter`

## Troubleshooting

### Common Issues:
1. **403 Forbidden**: Check API token permissions
2. **404 Not Found**: Verify Account ID and Destination Address ID
3. **Rate Limited**: Cloudflare has rate limits on email API

### Debugging:
- Check Phoenix logs for email delivery errors
- Verify environment variables are set correctly
- Test API token with Cloudflare API directly

## API Limits

Cloudflare Email Workers (Beta) limits:
- Check current limits in Cloudflare Dashboard
- Monitor usage in Analytics → Email

## Production Considerations

1. **Monitoring**: Set up alerts for email delivery failures
2. **Backup**: Consider secondary email service for critical emails
3. **Analytics**: Monitor email delivery rates and bounces
4. **Compliance**: Ensure GDPR/CAN-SPAM compliance for your use case

## Alternative Setup (SMTP)

If Cloudflare Workers email doesn't meet your needs, you can switch to traditional SMTP:

```elixir
# In runtime.exs
config :inventary_traker, InventaryTraker.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: "smtp.sendgrid.net",
  username: System.get_env("SENDGRID_USERNAME"),
  password: System.get_env("SENDGRID_PASSWORD"),
  port: 587,
  tls: :always
```

## Support

- Cloudflare Email Routing: https://developers.cloudflare.com/email-routing/
- Swoosh Documentation: https://hexdocs.pm/swoosh/
- Phoenix Email Guide: https://hexdocs.pm/phoenix/Phoenix.Swoosh.html