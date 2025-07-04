# n8n Cloud Deployment Guide (Free Tier)

## Oracle Cloud Always Free Deployment (Recommended)

### Step 1: Create Oracle Cloud Account
1. Sign up at https://cloud.oracle.com/
2. Verify your account (requires credit card but won't be charged)
3. Navigate to Compute → Instances

### Step 2: Create VM Instance
```bash
# Instance Configuration
Shape: VM.Standard.A1.Flex (ARM-based)
OCPUs: 2 (can use up to 4 total across all instances)
Memory: 8GB (can use up to 24GB total)
OS: Ubuntu 22.04 LTS
```

### Step 3: Setup Docker on Oracle Cloud
```bash
# SSH into your instance
ssh -i your-key.pem ubuntu@your-instance-ip

# Install Docker
sudo apt update
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
```

### Step 4: Deploy n8n
```bash
# Create deployment directory
mkdir ~/n8n-deployment
cd ~/n8n-deployment

# Create docker-compose.yml (modified for cloud)
cat > docker-compose.yml << 'EOF'
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n
    container_name: n8n
    restart: unless-stopped
    ports:
      - "80:5678"
    environment:
      # Database configuration for Supabase PostgreSQL
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=postgres
      - DB_POSTGRESDB_HOST=${SUPABASE_DB_HOST}
      - DB_POSTGRESDB_PORT=${SUPABASE_DB_PORT}
      - DB_POSTGRESDB_USER=${SUPABASE_DB_USER}
      - DB_POSTGRESDB_PASSWORD=${SUPABASE_DB_PASSWORD}
      - DB_POSTGRESDB_SCHEMA=public 
      - DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false
      - N8N_RUNNERS_ENABLED=true
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
      # Cloud-specific settings
      - WEBHOOK_URL=http://your-instance-ip
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:
EOF

# Create environment file
cat > .env << 'EOF'
# Copy your existing Supabase configuration
SUPABASE_DB_HOST=aws-0-ap-southeast-1.pooler.supabase.com
SUPABASE_DB_USER=postgres.your_project_ref_here
SUPABASE_DB_PASSWORD=your_secure_database_password_here
SUPABASE_DB_PORT=5432

# Your existing encryption key
N8N_ENCRYPTION_KEY=your_24_character_base64_encryption_key
EOF

# Deploy
docker-compose up -d
```

## Alternative: Fly.io Deployment

### Step 1: Install Fly CLI
```bash
# Install flyctl
curl -L https://fly.io/install.sh | sh
fly auth login
```

### Step 2: Create Fly App
```bash
# Create fly.toml
cat > fly.toml << 'EOF'
app = "your-n8n-app"
primary_region = "lax"

[env]
  N8N_HOST = "0.0.0.0"
  N8N_PORT = "5678"
  DB_TYPE = "postgresdb"
  DB_POSTGRESDB_DATABASE = "postgres"
  DB_POSTGRESDB_SCHEMA = "public"
  DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED = "false"
  N8N_RUNNERS_ENABLED = "true"

[[services]]
  internal_port = 5678
  protocol = "tcp"

  [[services.ports]]
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443

[deploy]
  image = "docker.n8n.io/n8nio/n8n"
EOF

# Set secrets
fly secrets set SUPABASE_DB_HOST=your_host
fly secrets set SUPABASE_DB_USER=your_user
fly secrets set SUPABASE_DB_PASSWORD=your_password
fly secrets set SUPABASE_DB_PORT=5432
fly secrets set N8N_ENCRYPTION_KEY=your_key

# Deploy
fly deploy
```

## Security Considerations

### 1. Firewall Setup (Oracle Cloud)
```bash
# Allow HTTP traffic
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

### 2. SSL Setup (Optional but Recommended)
```bash
# Install Caddy for automatic SSL
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main" | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy

# Create Caddyfile
cat > /etc/caddy/Caddyfile << 'EOF'
your-domain.com {
    reverse_proxy localhost:5678
}
EOF

sudo systemctl reload caddy
```

## Monitoring & Maintenance

### Health Check Script
```bash
cat > ~/health-check.sh << 'EOF'
#!/bin/bash
if ! curl -f http://localhost:5678/healthz > /dev/null 2>&1; then
    echo "n8n is down, restarting..."
    cd ~/n8n-deployment
    docker-compose restart n8n
fi
EOF

chmod +x ~/health-check.sh

# Add to crontab (check every 5 minutes)
(crontab -l 2>/dev/null; echo "*/5 * * * * ~/health-check.sh") | crontab -
```

## Cost Estimation

- **Oracle Cloud Always Free**: $0/month (permanent)
- **Fly.io**: $0/month for small usage
- **Railway**: ~$5/month credit covers most small deployments
- **AWS EC2**: $0 for first 12 months, then ~$8-15/month

## Migration from Local

1. **Backup Current Setup**: Your data is already in Supabase ✅
2. **Copy Configuration**: Use your existing `.env` values
3. **Deploy to Cloud**: Follow steps above
4. **Update Webhooks**: Point integrations to new cloud URL
5. **Test Workflows**: Verify everything works

## Benefits Over Local Hosting

- ✅ **Always Available**: No downtime when your computer is off
- ✅ **Better Webhooks**: Reliable public IP for integrations
- ✅ **Automatic Backups**: Your Supabase data is already backed up
- ✅ **Scalable**: Can upgrade resources as needed
- ✅ **SSL Support**: Secure HTTPS access
