# FTP Server Setup Guide

This document outlines the steps completed to create a containerized FTP server with anonymous upload capabilities.

## Overview

Created a Docker-based FTP server using vsftpd that allows anonymous users to upload files without authentication.

## Files Created

### 1. Dockerfile
- Base image: Alpine Linux
- Installed vsftpd FTP server
- Created FTP user and directory structure
- Configured permissions for anonymous uploads

### 2. docker-compose.yml
- FTP server service with port mappings (21, 21100-21110)
- Volume mapping for persistent storage
- Test client container for verification

### 3. vsftpd.conf
- Enabled anonymous access
- Configured upload permissions
- Set passive mode port range
- Disabled local user authentication

## Setup Steps

1. **Create project structure**
   ```bash
   mkdir -p ftp-data test-files
   echo "Test file for FTP upload" > test-files/test.txt
   ```

2. **Build and start containers**
   ```bash
   docker compose up -d --build
   ```

3. **Test FTP upload**
   ```bash
   docker exec ftp-test-client sh -c "apk add --no-cache lftp && lftp -c 'open ftp://ftpserver:21; user anonymous \"\"; cd pub; put /test-files/test.txt; ls; quit'"
   ```

## Usage

### Starting the FTP server
```bash
docker compose up -d
```

### Stopping the FTP server
```bash
docker compose down
```

### Connecting to FTP server
- **Host**: localhost
- **Port**: 21
- **Username**: anonymous
- **Password**: (leave empty)
- **Upload directory**: /pub

### File storage
Uploaded files are stored in the local `ftp-data/` directory on the host machine.

## Configuration Details

- **Anonymous uploads**: Enabled
- **Passive mode**: Ports 21100-21110
- **Upload directory**: /var/ftp/pub (mapped to ./ftp-data)
- **File permissions**: 644 (readable by all, writable by owner)

## Testing

The setup includes a test client container that can be used to verify FTP functionality:

```bash
# Install FTP client in test container
docker exec ftp-test-client apk add --no-cache lftp

# Test upload
docker exec ftp-test-client lftp -c 'open ftp://ftpserver:21; user anonymous ""; cd pub; put /test-files/test.txt; ls; quit'
```

## Security Notes

- This configuration allows anonymous uploads without authentication
- Intended for development/testing purposes
- Consider implementing authentication for production use
- Files uploaded are world-readable with 644 permissions