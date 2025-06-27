# n8n Portable Setup Guide

## 🎯 What This Setup Provides
- ✅ **Cloud Database**: All workflows, credentials, and settings stored in Supabase PostgreSQL
- ✅ **Portable**: Works on any computer with Docker
- ✅ **Persistent**: Data survives computer changes and Docker restarts
- ✅ **Secure**: Encrypted credentials and settings
- ✅ **Free**: Uses Supabase free tier

## 🔄 How to Move n8n to Another Computer

### Method 1: Quick Setup (Recommended)
Since your data is in Supabase, you just need the configuration files:

1. **Install Docker** on the new computer
2. **Copy these files** to the new computer:
   - `docker-compose.yml`
   - `.env`
3. **Run**: `docker-compose up -d`
4. **Access**: http://localhost:5678

### Method 2: Complete Backup & Restore
For a full backup including the Docker image:

1. **On old computer**: Run `backup_n8n.bat` (Windows) or `./backup_n8n.sh` (Linux/Mac)
2. **Copy the backup folder** to the new computer
3. **On new computer**: Run `restore.bat` or `./restore.sh` in the backup folder

## 🗂️ What Gets Stored Where

### Supabase PostgreSQL (Cloud):
- ✅ Workflows and workflow history
- ✅ Credentials (encrypted)
- ✅ User accounts and settings
- ✅ Execution data and logs
- ✅ Tags and workflow metadata

### Local Docker Volume:
- 🔧 Encryption keys
- 🔧 Temporary files
- 🔧 Local cache

## 🔐 Security Notes

- **Encryption Key**: Keep your `.env` file secure - it contains the encryption key
- **Database Password**: Your Supabase password is in the `.env` file
- **Credentials**: All n8n credentials are encrypted before storing in the database

## 🌐 Accessing n8n

- **Local**: http://localhost:5678
- **Network**: Replace `localhost` with your computer's IP address

## 🔧 Troubleshooting

### If n8n won't start:
1. Check Docker is running: `docker ps`
2. Check logs: `docker-compose logs n8n`
3. Verify database connection: Check `.env` file password

### If workflows are missing:
1. Verify you're using the same `.env` file
2. Check Supabase project is accessible
3. Ensure encryption key matches

### To reset everything:
1. Stop n8n: `docker-compose down`
2. Remove volume: `docker volume rm n8n_data`
3. Start fresh: `docker-compose up -d`

## 📊 Database Management

### Supabase Dashboard:
- **Project URL**: https://zfjucglxijhxizbcpkoq.supabase.co
- **Database Settings**: https://supabase.com/dashboard/project/zfjucglxijhxizbcpkoq/settings/database

### Useful Commands:
```bash
# View n8n logs
docker-compose logs -f n8n

# Restart n8n
docker-compose restart n8n

# Update n8n to latest version
docker-compose pull && docker-compose up -d

# Create backup
./backup_n8n.sh   # or backup_n8n.bat on Windows
```

## 🎉 Benefits of This Setup

1. **True Portability**: Your entire n8n setup can move to any computer
2. **Cloud Persistence**: Data survives hardware failures
3. **Easy Scaling**: Can run multiple n8n instances with shared data
4. **Professional Setup**: Similar to production deployments
5. **Cost Effective**: Free with Supabase limits (500MB storage, 2GB bandwidth)

## 📈 Upgrading to Paid Plans

If you exceed free limits:
- **Supabase Pro**: $25/month for larger databases
- **Multiple Regions**: Deploy n8n closer to your location
- **Advanced Features**: Point-in-time recovery, advanced monitoring
