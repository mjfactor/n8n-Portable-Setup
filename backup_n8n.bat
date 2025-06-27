@echo off
echo Creating n8n portable backup...

REM Create backup directory with timestamp
set timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set timestamp=%timestamp: =0%
set backup_dir=n8n_backup_%timestamp%
mkdir %backup_dir%

echo Backing up Docker image...
docker save docker.n8n.io/n8nio/n8n:latest > %backup_dir%\n8n_image.tar

echo Backing up Docker volumes...
docker run --rm -v n8n_data:/data -v %cd%\%backup_dir%:/backup alpine tar czf /backup/n8n_volume.tar.gz -C /data .

echo Backing up configuration files...
copy docker-compose.yml %backup_dir%\
copy .env %backup_dir%\

echo Creating restore script...
echo @echo off > %backup_dir%\restore.bat
echo echo Restoring n8n from backup... >> %backup_dir%\restore.bat
echo docker load ^< n8n_image.tar >> %backup_dir%\restore.bat
echo docker volume create n8n_data >> %backup_dir%\restore.bat
echo docker run --rm -v n8n_data:/data -v %%cd%%:/backup alpine tar xzf /backup/n8n_volume.tar.gz -C /data >> %backup_dir%\restore.bat
echo docker-compose up -d >> %backup_dir%\restore.bat
echo echo n8n restored and started! >> %backup_dir%\restore.bat

echo.
echo ✅ Backup created in: %backup_dir%
echo 📁 To restore on another computer:
echo    1. Copy the %backup_dir% folder
echo    2. Run restore.bat in that folder
echo    3. Make sure Docker is installed and running
echo.
pause
