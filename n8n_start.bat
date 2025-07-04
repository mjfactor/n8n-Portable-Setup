@echo off
REM Sets the title of the command prompt window.
TITLE Docker Compose Starter

REM --- Configuration ---
REM Set the path to your Docker Desktop executable.
SET DOCKER_PATH="C:\Program Files\Docker\Docker\Docker Desktop.exe"

REM Set the number of seconds to wait for Docker Desktop to start.
REM Adjust this value based on your system's performance. 30-60 seconds is usually safe.
SET WAIT_SECONDS=20

REM Set the number of seconds to wait for containers to initialize before opening the browser.
SET BROWSER_WAIT_SECONDS=20

REM --- Script ---

echo ===================================
echo  Docker Compose Starter
echo ===================================
echo.

REM Check if Docker Desktop is already running.
tasklist /FI "IMAGENAME eq Docker Desktop.exe" | find "Docker Desktop.exe" > nul
if %errorlevel% == 0 (
    echo Docker Desktop is already running.
) else (
    echo Starting Docker Desktop...
    REM Use start "" to open the program without waiting for it to close.
    start "" %DOCKER_PATH%
    if not exist %DOCKER_PATH% (
        echo ERROR: Docker Desktop not found at the specified path.
        echo Please update the DOCKER_PATH variable in this script.
        pause
        exit /b
    )

    echo.
    echo Waiting %WAIT_SECONDS% seconds for Docker to initialize...
    REM Provides a countdown timer. /nobreak prevents users from skipping it.
    timeout /t %WAIT_SECONDS% /nobreak > nul
)


echo.
echo Checking for docker-compose.yml file...
if not exist "docker-compose.yml" (
    echo ERROR: docker-compose.yml not found in the current directory.
    echo Please run this script from your project's root folder.
    echo.
    pause
    exit /b
)

echo.
echo Running docker-compose up...
REM Runs docker-compose in detached mode (-d).
REM Remove the "-d" if you want to see the container logs in this window.
docker-compose up -d

echo.
echo Waiting %BROWSER_WAIT_SECONDS% seconds for containers to initialize...
timeout /t %BROWSER_WAIT_SECONDS% /nobreak > nul

echo.
echo Opening browser at http://localhost:5678/
REM Opens the specified URL in the default web browser.
start http://localhost:5678/

echo.
echo ===================================
echo  Script finished.
echo ===================================
echo.
pause
