#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Netlify Domain Configuration Checker ===${NC}"
echo ""

# Get the custom domain from user
read -p "Enter your custom domain (e.g., example.com): " CUSTOM_DOMAIN

if [ -z "$CUSTOM_DOMAIN" ]; then
    echo -e "${RED}No domain provided. Exiting.${NC}"
    exit 1
fi

# Validate domain format
if ! echo "$CUSTOM_DOMAIN" | grep -E '^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.[a-zA-Z]{2,}$' > /dev/null; then
    echo -e "${RED}Invalid domain format. Please enter a valid domain.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Checking domain: ${YELLOW}$CUSTOM_DOMAIN${NC}"
echo ""

# Function to check command availability
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed. Please install it to run this script.${NC}"
        exit 1
    fi
}

# Check required commands
check_command "nslookup"
check_command "dig"
check_command "curl"
check_command "openssl"

# Check if domain resolves
echo -e "${BLUE}1. DNS Resolution Check:${NC}"
if nslookup "$CUSTOM_DOMAIN" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Domain resolves successfully${NC}"
    # Show the actual IP addresses
    echo -e "${BLUE}   IP addresses:${NC}"
    dig "$CUSTOM_DOMAIN" +short | sed 's/^/   /'
else
    echo -e "${RED}❌ Domain does not resolve${NC}"
    echo -e "${YELLOW}   This could mean:${NC}"
    echo "   - Domain doesn't exist"
    echo "   - DNS records not configured"
    echo "   - DNS server issues"
fi

echo ""
echo -e "${BLUE}2. HTTP Response Check:${NC}"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://$CUSTOM_DOMAIN" 2>/dev/null)
if [ "$HTTP_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Site is accessible (HTTP 200)${NC}"
elif [ "$HTTP_STATUS" = "000" ]; then
    echo -e "${RED}❌ Site is not accessible (connection failed)${NC}"
    echo -e "${YELLOW}   Trying HTTP instead of HTTPS...${NC}"
    HTTP_STATUS_PLAIN=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "http://$CUSTOM_DOMAIN" 2>/dev/null)
    if [ "$HTTP_STATUS_PLAIN" = "200" ] || [ "$HTTP_STATUS_PLAIN" = "301" ] || [ "$HTTP_STATUS_PLAIN" = "302" ]; then
        echo -e "${YELLOW}⚠️  HTTP works but HTTPS doesn't - SSL issue${NC}"
    else
        echo -e "${RED}❌ HTTP also fails${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Site returned HTTP $HTTP_STATUS${NC}"
    case $HTTP_STATUS in
        301|302) echo -e "${BLUE}   → Redirect detected${NC}" ;;
        403) echo -e "${YELLOW}   → Access forbidden${NC}" ;;
        404) echo -e "${YELLOW}   → Page not found${NC}" ;;
        500) echo -e "${RED}   → Server error${NC}" ;;
        *) echo -e "${YELLOW}   → Unexpected response${NC}" ;;
    esac
fi

echo ""
echo -e "${BLUE}3. SSL Certificate Check:${NC}"
if timeout 10 openssl s_client -connect "$CUSTOM_DOMAIN:443" -servername "$CUSTOM_DOMAIN" < /dev/null 2>/dev/null | openssl x509 -noout -dates > /dev/null 2>&1; then
    echo -e "${GREEN}✅ SSL certificate is valid${NC}"
    echo -e "${BLUE}   Certificate details:${NC}"
    timeout 10 openssl s_client -connect "$CUSTOM_DOMAIN:443" -servername "$CUSTOM_DOMAIN" < /dev/null 2>/dev/null | openssl x509 -noout -dates 2>/dev/null | sed 's/^/   /'
    
    # Check certificate issuer
    CERT_ISSUER=$(timeout 10 openssl s_client -connect "$CUSTOM_DOMAIN:443" -servername "$CUSTOM_DOMAIN" < /dev/null 2>/dev/null | openssl x509 -noout -issuer 2>/dev/null | sed 's/issuer=//')
    if echo "$CERT_ISSUER" | grep -i "let's encrypt" > /dev/null; then
        echo -e "${GREEN}   → Let's Encrypt certificate (Netlify managed)${NC}"
    fi
else
    echo -e "${RED}❌ SSL certificate issue or connection failed${NC}"
    echo -e "${YELLOW}   Common causes:${NC}"
    echo "   - SSL not yet provisioned (wait up to 24 hours)"
    echo "   - Domain not pointing to Netlify"
    echo "   - Invalid SSL configuration"
fi

echo ""
echo -e "${BLUE}4. Netlify Load Balancer Check:${NC}"
NETLIFY_IPS=$(dig "$CUSTOM_DOMAIN" +short | grep -E '^(75\.2\.|52\.|3\.)')
if [ -n "$NETLIFY_IPS" ]; then
    echo -e "${GREEN}✅ Domain points to Netlify load balancer${NC}"
    echo -e "${BLUE}   Netlify IP addresses:${NC}"
    echo "$NETLIFY_IPS" | sed 's/^/   /'
else
    echo -e "${RED}❌ Domain does not point to Netlify load balancer${NC}"
    echo -e "${BLUE}   Current IP addresses:${NC}"
    dig "$CUSTOM_DOMAIN" +short | sed 's/^/   /'
    echo -e "${YELLOW}   Expected IP ranges: 75.2.x.x, 52.x.x.x, or 3.x.x.x${NC}"
fi

echo ""
echo -e "${BLUE}5. WWW Subdomain Check:${NC}"
WWW_DOMAIN="www.$CUSTOM_DOMAIN"
if nslookup "$WWW_DOMAIN" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ WWW subdomain is configured${NC}"
    WWW_IPS=$(dig "$WWW_DOMAIN" +short)
    if echo "$WWW_IPS" | grep -E '^(75\.2\.|52\.|3\.|.*\.netlify\.app)' > /dev/null; then
        echo -e "${GREEN}   → Points to Netlify${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Does not point to Netlify${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  WWW subdomain not configured${NC}"
    echo -e "${BLUE}   Consider adding CNAME: www → your-site.netlify.app${NC}"
fi

echo ""
echo -e "${BLUE}6. DNS Propagation Check:${NC}"
# Check multiple DNS servers
declare -A DNS_SERVERS=(
    ["Google"]="8.8.8.8"
    ["Cloudflare"]="1.1.1.1"
    ["OpenDNS"]="208.67.222.222"
)

for server_name in "${!DNS_SERVERS[@]}"; do
    server_ip="${DNS_SERVERS[$server_name]}"
    result=$(dig "@$server_ip" "$CUSTOM_DOMAIN" +short 2>/dev/null | head -1)
    if [ -n "$result" ]; then
        echo -e "${GREEN}   ✅ $server_name DNS: $result${NC}"
    else
        echo -e "${RED}   ❌ $server_name DNS: No response${NC}"
    fi
done

echo ""
echo -e "${BLUE}=== Troubleshooting Steps ===${NC}"
echo -e "${YELLOW}If any checks failed:${NC}"
echo "1. Go to Netlify Dashboard > Site Settings > Domain Management"
echo "2. Add your custom domain if not already added"
echo "3. Update your DNS records:"
echo -e "${GREEN}   - A record: @ → 75.2.60.5${NC}"
echo -e "${GREEN}   - CNAME record: www → your-site-name.netlify.app${NC}"
echo "4. Wait up to 24 hours for DNS propagation and SSL certificate"
echo ""
echo -e "${BLUE}Additional Resources:${NC}"
echo "• Netlify Docs: https://docs.netlify.com/domains-https/custom-domains/"
echo "• DNS Propagation Checker: https://www.whatsmydns.net/"
echo "• SSL Labs Test: https://www.ssllabs.com/ssltest/"