#!/bin/bash
echo "Creating n8n portable backup..."

# Create backup directory with timestamp
timestamp=$(date +"%Y%m%d_%H%M%S")
backup_dir="n8n_backup_$timestamp"
mkdir -p "$backup_dir"

echo "Backing up Docker image..."
docker save docker.n8n.io/n8nio/n8n:latest > "$backup_dir/n8n_image.tar"

echo "Backing up Docker volumes..."
docker run --rm -v n8n_data:/data -v "$(pwd)/$backup_dir":/backup alpine tar czf /backup/n8n_volume.tar.gz -C /data .

echo "Backing up configuration files..."
cp docker-compose.yml "$backup_dir/"
cp .env "$backup_dir/"

echo "Creating restore script..."
cat > "$backup_dir/restore.sh" << 'EOF'
#!/bin/bash
echo "Restoring n8n from backup..."
docker load < n8n_image.tar
docker volume create n8n_data
docker run --rm -v n8n_data:/data -v "$(pwd)":/backup alpine tar xzf /backup/n8n_volume.tar.gz -C /data
docker-compose up -d
echo "✅ n8n restored and started!"
EOF

chmod +x "$backup_dir/restore.sh"

echo
echo "✅ Backup created in: $backup_dir"
echo "📁 To restore on another computer:"
echo "   1. Copy the $backup_dir folder"
echo "   2. Run ./restore.sh in that folder"
echo "   3. Make sure Docker is installed and running"
echo
