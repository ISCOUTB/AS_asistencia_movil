@echo off
echo Iniciando backend con ambiente virtual...
cd /d "%~dp0"
call venv\Scripts\activate.bat
cd src\backend\api
uvicorn app:app --reload --host 0.0.0.0 --port 8000
pause
