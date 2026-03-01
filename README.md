# SQL Server Docker Development Environmentdock

This setup provides a local SQL Server 2022 instance running in Docker with persistent data storage.

## Quick Start

1. **First time setup:**

   ```powershell
   # The .env file is created automatically from .env.example
   # Optionally, edit .env to set a custom password
   .\up.ps1
   ```

2. **Stop the server:**
   ```powershell
   .\down.ps1
   ```

## Configuration

- **Image:** SQL Server 2022 Latest
- **User:** `sa`
- **Default Password:** `Monday@1` (change in `.env` file)
- **Port:** `1433` (localhost only)
- **Data Volume:** `sqlserver_data` (persistent)

## AdventureWorks Sample Database

The setup can optionally install the AdventureWorks2022 sample database:

1. **Enable in `.env` file:**

   ```
   INSTALL_ADVENTUREWORKS=true
   ```

2. **Install automatically:** When you run `.\up.ps1`, it will automatically download and restore AdventureWorks if the flag is true.

3. **Install manually:**
   ```powershell
   .\install-adventureworks.ps1
   ```

The AdventureWorks backup file (~200MB) is downloaded once and cached in the `backups/` folder for future use.

## Connection String

```
Server=127.0.0.1,1433;User Id=sa;Password=<your_password>;TrustServerCertificate=True
```

## Docker Compose Commands

```powershell
# Start container
docker compose up -d

# Stop container (keeps data)
docker compose down

# Stop container and remove data
docker compose down -v

# View logs
docker compose logs -f

# Restart container
docker compose restart
```

## Features

✓ Persistent data storage with named volume
✓ SQL Server Agent enabled
✓ Health checks for reliable startup
✓ Auto-restart unless stopped manually
✓ Localhost-only binding for security
✓ Environment variable configuration
✓ Optional AdventureWorks2022 sample database

## Files

- `docker-compose.yml` - Service configuration
- `.env` - Environment variables (passwords, settings) - **not in git**
- `.env.example` - Template for `.env` file
- `up.ps1` - Start the server with health check
- `down.ps1` - Stop the server
- `reset.ps1` - Reset container and volume (deletes all data)
- `install-adventureworks.ps1` - Install AdventureWorks sample database
- `create_server.ps1` - Legacy script (use Docker Compose instead)
- `backups/` - Cached database backup files (git-ignored)

## Security Notes

- The `.env` file is git-ignored to keep passwords secure
- Port is bound to `127.0.0.1` only (not accessible from network)
- Change the default password in `.env` before using in production
