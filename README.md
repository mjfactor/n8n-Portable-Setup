# n8n Portable Setup

> **Workflow automation platform with cloud persistence**

A portable n8n Docker setup using Supabase PostgreSQL for true cross-device portability.

## ⚡ Quick Start

1. **Copy environment file**:
   ```bash
   cp .env.example .env
   ```

2. **Configure Supabase credentials** in `.env`:
   - Get database credentials from [Supabase Dashboard](https://supabase.com/dashboard)
   - Generate encryption key: `node -e "console.log(require('crypto').randomBytes(24).toString('base64'))"`

3. **Start n8n**:
   ```bash
   docker-compose up -d
   ```

4. **Access**: http://localhost:5678

## ✨ Features

- 🌐 **Cloud Database**: Workflows stored in Supabase PostgreSQL
- 📱 **Portable**: Works on any computer with Docker
- 🔒 **Secure**: Encrypted credentials and settings
- 💰 **Free**: Uses Supabase free tier (500MB storage)

## 🔄 Moving to Another Computer

Just copy `docker-compose.yml` and `.env` to the new computer and run `docker-compose up -d`.

## 📚 Documentation

- **Detailed Setup**: [PORTABLE_SETUP_GUIDE.md](PORTABLE_SETUP_GUIDE.md)
- **Environment Variables**: [.env.example](.env.example)

## 🛠️ Common Commands

```bash
# View logs
docker-compose logs -f n8n

# Restart
docker-compose restart n8n

# Update
docker-compose pull && docker-compose up -d

# Stop
docker-compose down
```

---
**n8n**: Fair-code workflow automation | **Supabase**: Open source Firebase alternative
