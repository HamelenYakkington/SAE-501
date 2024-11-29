@echo off
echo "Closing Docker containers..."
cd /d "%~dp0\api" || (echo "The folder 'api' does not exist." && exit /b 1)
docker compose down || (echo "Failed to close containers." && exit /b 2)
cd ..
echo "Containers have been closed!"