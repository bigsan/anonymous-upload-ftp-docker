# Containerized FTP Server

This project provides two containerized FTP server solutions with anonymous upload capabilities.

## Quick Start

### ProFTPD Server (Root Directory Uploads)
```bash
# Start server that allows uploads to root directory (/)
docker compose --profile proftpd up -d --build

# Connect with any FTP client:
# Host: localhost:21
# User: anonymous
# Password: (empty)
# Upload to: / (root directory)
```

### vsftpd Server (Subdirectory Uploads)
```bash
# Start server that allows uploads to /pub subdirectory
docker compose --profile vsftpd up -d --build

# Connect with any FTP client:
# Host: localhost:21  
# User: anonymous
# Password: (empty)
# Upload to: /pub directory
```

## File Structure

```
├── Dockerfile.proftpd      # ProFTPD server image
├── Dockerfile.vsftpd       # vsftpd server image  
├── docker-compose.yml      # Orchestration with profiles
├── proftpd.conf           # ProFTPD configuration
├── vsftpd.conf            # vsftpd configuration
├── ftp-data/              # Uploaded files appear here
├── test-files/            # Test files for upload
├── FTP_SERVER_SETUP.md    # Detailed setup guide
└── WORKING_SOLUTION.md    # Technical solution details
```

## Key Differences

| Feature | ProFTPD | vsftpd |
|---------|---------|--------|
| Upload Location | Root directory (`/`) | Subdirectory (`/pub`) |
| Security Model | Configurable | Chroot-based |
| Configuration | Flexible | Traditional |
| Use Case | Direct root access | Standard FTP structure |

## Testing

Both solutions include a test client for verification:

```bash
# Test either server
docker compose up ftp-test -d
docker exec ftp-test-client sh -c "apk add --no-cache lftp && lftp -c 'open ftp://[server]:21; user anonymous \"\"; put /test-files/test.txt; ls; quit'"
```

## Documentation

- **[FTP_SERVER_SETUP.md](FTP_SERVER_SETUP.md)** - Complete setup and usage guide
- **[WORKING_SOLUTION.md](WORKING_SOLUTION.md)** - Technical details and troubleshooting

## Security Note

These configurations allow unrestricted anonymous uploads and are intended for development/testing environments. For production use, implement proper authentication and access controls.