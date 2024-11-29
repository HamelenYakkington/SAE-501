@echo off
echo "Starting Docker containers..."
cd /d "%~dp0\api" || (echo "The folder 'api' does not exist." && exit /b 1)
docker compose up -d || (echo "Failed to start containers." && exit /b 2)
cd ..
echo "Containers are running!"
