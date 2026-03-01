# Start SQL Server container using Docker Compose
Write-Host "Starting SQL Server container..." -ForegroundColor Green

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "Warning: .env file not found. Creating from .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "Please update the .env file with a secure password!" -ForegroundColor Yellow
}

docker compose up -d

# Wait for SQL Server to be healthy
Write-Host "Waiting for SQL Server to be ready..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0

while ($attempt -lt $maxAttempts) {
    $health = docker inspect --format='{{.State.Health.Status}}' sqlserver-dev 2>$null
    if ($health -eq "healthy") {
        Write-Host "SQL Server is ready!" -ForegroundColor Green
        Write-Host "Connection string: Server=127.0.0.1,1433;User Id=sa;Password=<your_password>;TrustServerCertificate=True" -ForegroundColor Cyan

        # Check if AdventureWorks should be installed
        $installAdventureWorks = $false
        Get-Content ".env" | ForEach-Object {
            if ($_ -match '^INSTALL_ADVENTUREWORKS=true$') {
                $installAdventureWorks = $true
            }
        }

        if ($installAdventureWorks) {
            Write-Host "`nChecking AdventureWorks installation..." -ForegroundColor Cyan
            & "$PSScriptRoot\install-adventureworks.ps1"
        }

        exit 0
    }
    Start-Sleep -Seconds 2
    $attempt++
    Write-Host "." -NoNewline
}

Write-Host ""
Write-Host "SQL Server is starting... check logs with: docker compose logs -f" -ForegroundColor Yellow
