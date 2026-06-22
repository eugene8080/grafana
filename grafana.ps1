# Start Docker Desktop if not already running
$dockerRunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
if (-not $dockerRunning) {
    Write-Host "Starting Docker Desktop..."
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
}

# Wait for Docker daemon to be ready
Write-Host "Waiting for Docker to be ready..."
$timeout = 120
$elapsed = 0
while ($elapsed -lt $timeout) {
    $result = docker info 2>$null
    if ($LASTEXITCODE -eq 0) { break }
    Start-Sleep -Seconds 3
    $elapsed += 3
    Write-Host "  ...still waiting ($elapsed s)"
}

if ($elapsed -ge $timeout) {
    Write-Host "Docker did not start in time. Exiting."
    exit 1
}

Write-Host "Docker is ready."

# Start containers
Write-Host "Starting Garmin Grafana containers..."
Set-Location "C:\dev\garmin-grafana"
docker compose up -d

# Wait for Grafana to respond
Write-Host "Waiting for Grafana..."
$elapsed = 0
while ($elapsed -lt 60) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200) { break }
    } catch {}
    Start-Sleep -Seconds 2
    $elapsed += 2
}

# Open Grafana in Chrome
Write-Host "Opening Grafana in Chrome..."
Start-Process "chrome.exe" "http://localhost:3000"
