# Deep Hull Marine Website

Professional diving service offering 24/7 emergency marine assistance in Jacksonville & St. Augustine, Florida. Not just hull cleaning.

## 🚀 Live Site

- **Production**: [https://deephull.netlify.app/](https://deephull.netlify.app/)
- **Custom Domain**: Coming soon (deephull.com)

## 📋 Overview

This is a modern, responsive React-based website built for Deep Hull Marine, a professional diving service company. The site features:

- ⚡ Fast loading times with optimized bundles
- 📱 Mobile-first responsive design  
- 🔒 Secure HTTPS with SSL certificates
- 📝 Contact and quote request forms
- 🎨 Professional maritime-themed design
- 🔍 SEO optimized for local search

## 🛠️ Tech Stack

- **Frontend**: React 18 with modern hooks
- **Bundler**: Vite (production build)
- **Hosting**: Netlify with CDN
- **Styling**: CSS-in-JS with responsive design
- **Forms**: Netlify Forms with spam protection

## 📁 Project Structure

```
deephull/
├── index.html              # Main app entry point
├── index-bdrpnltx.js      # React app bundle (production)
├── index-pgpn7qvg.css     # Styles bundle (production)
├── forms.html             # Contact & quote forms
├── success.html           # Form submission success page
├── netlify.toml          # Netlify configuration
├── check-domain.sh       # Domain troubleshooting script
├── robots.txt            # SEO robots configuration
├── favicon.ico           # Site favicon
└── README.md             # This file
```

## 🚀 Deployment

The site is automatically deployed to Netlify when changes are pushed to the main branch.

### Build Configuration

The site is configured in `netlify.toml` with:

- **Publish Directory**: `.` (root directory)
- **SPA Routing**: All routes redirect to `index.html`
- **Form Handling**: Netlify Forms with honeypot protection
- **Caching**: Optimized cache headers for static assets
- **Security**: CSP, XSS protection, and other security headers

### Performance Optimizations

- ✅ Minified and compressed JavaScript/CSS bundles
- ✅ Long-term caching for static assets (1 year)
- ✅ Gzip compression enabled
- ✅ Modern ES6+ with efficient tree-shaking
- ✅ Optimized images and icons

## 📝 Forms

The site includes two forms handled by Netlify Forms:

### Contact Form (`forms.html`)
- General inquiries and communications
- Spam protection with honeypot field
- Required fields: name, email, phone, subject, message

### Quote Request Form (`forms.html`)  
- Service quotes and booking requests
- Vessel-specific fields (type, length, location)
- Service type selection (hull cleaning, prop polishing, etc.)
- Urgency levels for scheduling

Both forms redirect to `/success` upon successful submission.

## 🔧 Domain Setup

Use the included `check-domain.sh` script to troubleshoot custom domain configuration:

```bash
chmod +x check-domain.sh
./check-domain.sh
```

The script checks:
- DNS resolution and propagation
- SSL certificate status  
- Netlify load balancer configuration
- WWW subdomain setup
- Multiple DNS server responses

### DNS Configuration

For custom domains, configure these DNS records:

```
Type    Name    Value
A       @       75.2.60.5
CNAME   www     your-site-name.netlify.app
```

## 🔒 Security Features

- **HTTPS Only**: Automatic SSL certificates via Let's Encrypt
- **Security Headers**: CSP, XSS protection, content type sniffing prevention
- **Form Protection**: Honeypot spam filtering
- **Access Control**: Proper CORS and referrer policies

## 🎨 Design Features

- **Professional Branding**: Maritime blue color scheme
- **Responsive Layout**: Mobile-first design approach
- **Accessibility**: ARIA labels, semantic HTML, keyboard navigation
- **Loading States**: Smooth transitions and user feedback
- **Form Validation**: Real-time validation with clear error messages

## 📊 SEO Optimization

- **Structured Data**: JSON-LD schema for local business
- **Meta Tags**: Complete Open Graph and Twitter Card support
- **Canonical URLs**: Proper URL canonicalization
- **Sitemap**: Auto-generated via Netlify
- **Robots.txt**: Search engine crawling configuration

## 🚀 Performance Metrics

- **Bundle Size**: ~525KB (JavaScript) + ~64KB (CSS)
- **Load Time**: < 2 seconds on 3G
- **Lighthouse Score**: 95+ across all categories
- **Core Web Vitals**: All metrics in green

## 🔄 Development Workflow

1. **Local Development**: Use any static server for testing
2. **Testing**: Forms can be tested locally (will show debug info)
3. **Deployment**: Push to main branch for automatic deployment
4. **Monitoring**: Check Netlify dashboard for build status

## 📞 Contact Information

**Deep Hull Marine**
- 📞 Phone: (904) 570-0910
- 📧 Email: info@deephulldiving.com
- 📍 Location: Jacksonville, FL
- 🌐 Website: https://deephull.netlify.app/

## 🛠️ Maintenance

### Regular Tasks
- Monitor Netlify build logs
- Check domain and SSL certificate status
- Review form submissions in Netlify dashboard
- Update contact information as needed

### Troubleshooting
- Use `check-domain.sh` for domain issues
- Check Netlify deploy logs for build failures
- Review browser console for JavaScript errors
- Test forms with both real and test submissions

---

*Built with ❤️ by the Deep Hull Marine team*

---

## 👩‍💻 Developer Guide

This section describes how to run tests, linters, and developer helpers locally.


Prerequisites

- Linux / macOS shell or Windows WSL
- bash, curl, dig (dnsutils), openssl
- Optional: Python 3 to create a virtualenv for pre-commit

Run the domain checker (interactive):

```bash
chmod +x check-domain.sh
./check-domain.sh
```

Run the domain checker non-interactively (useful in CI or scripts):

```bash
./check-domain.sh example.com
# or pipe a domain:
printf 'nonexistent.example\n' | ./check-domain.sh
```

Run the project's tests (shell tests):

```bash
bash tests/check-domain-test.sh
```

Run shellcheck across shell scripts (helper provided):

```bash
# install shellcheck on Ubuntu/Debian: sudo apt-get install -y shellcheck
./scripts/run-shellcheck.sh
```

Pre-commit hooks

- A `.pre-commit-config.yaml` is included. In some CI/dev environments fetching remote hook repos may be blocked. To enable hooks locally:

```bash
# create a venv (optional) and install pre-commit
python -m venv .venv
source .venv/bin/activate
pip install --upgrade pip pre-commit
pre-commit install
pre-commit run --all-files
```

CI

- GitHub Actions CI is configured in `.github/workflows/ci.yml`. The CI job installs `shellcheck` and `dnsutils` (`dig`) and runs the shell tests. Pushes and pull requests to `main` will run the workflow.

Notes and troubleshooting

- If `dig` is missing on your machine, install `dnsutils` (Debian/Ubuntu): `sudo apt-get install -y dnsutils`.
- If pre-commit fails to fetch hooks in CI or restricted environments, rely on the CI-provided shellcheck step and the local `scripts/run-shellcheck.sh` helper.

