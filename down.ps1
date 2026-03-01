# Stop SQL Server container using Docker Compose
Write-Host "Stopping SQL Server container..." -ForegroundColor Yellow

docker compose down

Write-Host "SQL Server container stopped." -ForegroundColor Green
Write-Host "Note: Data is preserved in the sqlserver_data volume." -ForegroundColor Cyan
Write-Host "To remove the volume as well, run: docker compose down -v" -ForegroundColor Gray
