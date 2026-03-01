# Install AdventureWorks sample database
# This script downloads and restores the AdventureWorks2022 database

param(
    [string]$Password = $env:SA_PASSWORD
)

# Load .env file if Password not provided
if (-not $Password) {
    if (Test-Path ".env") {
        Get-Content ".env" | ForEach-Object {
            if ($_ -match '^SA_PASSWORD=(.+)$') {
                $Password = $matches[1]
            }
            if ($_ -match '^INSTALL_ADVENTUREWORKS=(.+)$') {
                $installFlag = $matches[1]
            }
        }
    }
}

# Check if installation is enabled
if ($installFlag -eq "false") {
    Write-Host "AdventureWorks installation is disabled in .env (INSTALL_ADVENTUREWORKS=false)" -ForegroundColor Yellow
    exit 0
}

Write-Host "Installing AdventureWorks sample database..." -ForegroundColor Green

# Create backups directory if it doesn't exist
$backupDir = Join-Path $PSScriptRoot "backups"
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}

# Download AdventureWorks backup file if not already present
$backupFile = Join-Path $backupDir "AdventureWorks2022.bak"
if (-not (Test-Path $backupFile)) {
    Write-Host "Downloading AdventureWorks2022.bak (approximately 200MB)..." -ForegroundColor Yellow
    $url = "https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2022.bak"
    try {
        Invoke-WebRequest -Uri $url -OutFile $backupFile -UseBasicParsing
        Write-Host "Download complete!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error downloading AdventureWorks: $_" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "Using existing AdventureWorks2022.bak file" -ForegroundColor Cyan
}

# Wait for SQL Server to be ready
Write-Host "Waiting for SQL Server to be ready..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0

while ($attempt -lt $maxAttempts) {
    $testResult = docker exec sqlserver-dev /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$Password" -Q "SELECT 1" -C 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SQL Server is ready!" -ForegroundColor Green
        break
    }
    Start-Sleep -Seconds 2
    $attempt++
}

if ($attempt -eq $maxAttempts) {
    Write-Host "SQL Server is not ready. Please ensure the container is running with .\up.ps1" -ForegroundColor Red
    exit 1
}

# Copy backup file into container
Write-Host "Copying backup file to container..." -ForegroundColor Yellow
docker cp $backupFile sqlserver-dev:/var/opt/mssql/data/AdventureWorks2022.bak

# Restore the database
Write-Host "Restoring AdventureWorks2022 database..." -ForegroundColor Yellow
$restoreCommand = @"
RESTORE DATABASE AdventureWorks2022
FROM DISK = '/var/opt/mssql/data/AdventureWorks2022.bak'
WITH MOVE 'AdventureWorks2022' TO '/var/opt/mssql/data/AdventureWorks2022.mdf',
MOVE 'AdventureWorks2022_log' TO '/var/opt/mssql/data/AdventureWorks2022_log.ldf',
REPLACE
"@

$result = docker exec sqlserver-dev /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$Password" -Q "$restoreCommand" -C 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "AdventureWorks2022 database installed successfully!" -ForegroundColor Green
    Write-Host "You can now connect and query the AdventureWorks2022 database." -ForegroundColor Cyan

    # Clean up backup file from container
    docker exec sqlserver-dev rm /var/opt/mssql/data/AdventureWorks2022.bak 2>$null
}
else {
    Write-Host "Error restoring database:" -ForegroundColor Red
    Write-Host $result
    exit 1
}
