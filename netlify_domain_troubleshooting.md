# Netlify Custom Domain Troubleshooting Guide

## Quick Diagnosis

Run the domain checker script:
```bash
./check-domain.sh
```

## Common Issues and Solutions

### 1. Domain Not Added to Netlify
**Symptoms:** Domain doesn't resolve or shows "Site not found"
**Solution:**
1. Go to Netlify Dashboard → Your Site → Site Settings → Domain Management
2. Click "Add custom domain"
3. Enter your domain (e.g., `example.com`)
4. Follow the DNS configuration instructions

### 2. Incorrect DNS Configuration
**Symptoms:** Domain resolves but site doesn't load
**Required DNS Records:**

#### For Root Domain (example.com):
```
Type: A
Name: @ (or leave blank)
Value: 75.2.60.5
TTL: 3600 (or default)
```

#### For WWW Subdomain (www.example.com):
```
Type: CNAME
Name: www
Value: your-site-name.netlify.app
TTL: 3600 (or default)
```

### 3. SSL Certificate Not Provisioned
**Symptoms:** HTTPS shows certificate errors or doesn't work
**Solution:**
- Wait up to 24 hours for automatic SSL provisioning
- Ensure DNS is correctly configured first
- Check Netlify dashboard for SSL status

### 4. DNS Propagation Delay
**Symptoms:** Works in some locations but not others
**Solution:**
- DNS changes can take 24-48 hours to propagate globally
- Use tools like https://www.whatsmydns.net/ to check propagation

## Verification Steps

### 1. Check Current DNS Configuration
```bash
dig yourdomain.com +short
dig www.yourdomain.com +short
```

### 2. Verify Netlify Load Balancer
Your domain should resolve to one of these IP ranges:
- 75.2.x.x
- 52.x.x.x  
- 3.x.x.x

### 3. Test HTTPS
```bash
curl -I https://yourdomain.com
```

## Netlify Dashboard Settings

1. **Domain Management:**
   - Site Settings → Domain Management
   - Verify custom domain is listed
   - Check for any error messages

2. **SSL/TLS:**
   - Site Settings → SSL/TLS
   - Should show "Certificate: Active"
   - If not, wait 24 hours or contact support

3. **Build & Deploy:**
   - Check that your latest deployment was successful
   - Verify the correct branch is being deployed

## Common DNS Providers

### Cloudflare
- Set DNS to "DNS only" (not proxied)
- Add A record: `@ → 75.2.60.5`
- Add CNAME record: `www → your-site.netlify.app`

### GoDaddy
- Add A record: `@ → 75.2.60.5`
- Add CNAME record: `www → your-site.netlify.app`

### Namecheap
- Add A record: `@ → 75.2.60.5`
- Add CNAME record: `www → your-site.netlify.app`

## Still Having Issues?

1. **Check Netlify Status:** https://status.netlify.com/
2. **Contact Netlify Support:** https://www.netlify.com/support/
3. **Community Forum:** https://community.netlify.com/

## Your Current Configuration

Based on your `netlify.toml`, your site is configured as a Single Page Application (SPA) with proper redirects. The configuration looks correct for a custom domain.

**Next Steps:**
1. Run the domain checker script
2. Verify DNS configuration with your domain provider
3. Check Netlify dashboard for domain status
4. Wait for DNS propagation and SSL certificate provisioning