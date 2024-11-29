@echo off
echo "Démarrage de l'application..."

REM Naviguer dans le répertoire `api`
cd /d "%~dp0\api" || (echo "Le dossier 'api' n'existe pas." && exit /b 1)

REM Lancer Docker Compose en arrière-plan
docker compose up -d || (echo "Échec du démarrage de Docker Compose." && exit /b 2)

REM Revenir au répertoire précédent
cd ..

echo "Application démarrée avec succès."
