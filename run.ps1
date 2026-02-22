# Run this script to start both the FastAPI backend and Flutter frontend simultaneously on Windows.

Write-Host "Starting Out of Harms Way..." -ForegroundColor Cyan

# Start the Backend in a new PowerShell window
Write-Host "Starting FastAPI Backend..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit -Command `"cd agent_backend; python main.py`""

# Start the Frontend in the current window
Write-Host "Starting Flutter Web Frontend..." -ForegroundColor Green
flutter run -d chrome
