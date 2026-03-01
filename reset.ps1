# Reset SQL Server container and volume
# WARNING: This will DELETE ALL DATA in the SQL Server database!

Write-Host "WARNING: This will remove the container and ALL DATA!" -ForegroundColor Red
$confirm = Read-Host "Type 'YES' to continue"

if ($confirm -ne "YES") {
    Write-Host "Reset cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host "`nStopping and removing container..." -ForegroundColor Yellow
docker compose down -v

Write-Host "`nStarting fresh container with password from .env..." -ForegroundColor Green
docker compose up -d

# Wait for SQL Server to be healthy
Write-Host "Waiting for SQL Server to initialize (this may take 30-60 seconds)..." -ForegroundColor Yellow
$maxAttempts = 60
$attempt = 0

while ($attempt -lt $maxAttempts) {
    $health = docker inspect --format='{{.State.Health.Status}}' sqlserver-dev 2>$null
    if ($health -eq "healthy") {
        Write-Host "`nSQL Server is ready with the new password!" -ForegroundColor Green
        Write-Host "Connection: Server=127.0.0.1,1433;User Id=sa;Password=Monday@123;TrustServerCertificate=True" -ForegroundColor Cyan
        exit 0
    }
    Start-Sleep -Seconds 2
    $attempt++
    Write-Host "." -NoNewline
}

Write-Host "`nSQL Server is starting... check logs with: docker compose logs -f" -ForegroundColor Yellow
