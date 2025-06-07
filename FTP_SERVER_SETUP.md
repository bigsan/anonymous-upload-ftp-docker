# FTP Server Setup Guide

This document outlines the steps completed to create containerized FTP servers with anonymous upload capabilities.

## Overview

Created two Docker-based FTP server solutions:
1. **vsftpd** - Allows anonymous uploads to `/pub` subdirectory
2. **ProFTPD** - Allows anonymous uploads directly to root directory (`/`)

## Available Solutions

### Solution 1: vsftpd (Traditional)
- **Upload Directory**: `/pub` subdirectory
- **Security**: Uses vsftpd's built-in chroot security
- **Best For**: Standard FTP setups with directory structure

### Solution 2: ProFTPD (Flexible)
- **Upload Directory**: Root directory (`/`)
- **Security**: Configurable security policies
- **Best For**: Direct root uploads without subdirectories

## Files Created

### 1. Dockerfile.vsftpd
- Base image: Alpine Linux
- Installed vsftpd FTP server
- Created FTP user and directory structure
- Configured permissions for anonymous uploads to `/pub`

### 2. Dockerfile.proftpd
- Base image: Alpine Linux
- Installed ProFTPD server
- Created FTP directories and runtime environment
- Configured permissions for anonymous uploads to root

### 3. docker-compose.yml
- Two FTP server services using Docker profiles
- Port mappings (21, 21100-21110)
- Volume mapping for persistent storage
- Test client container for verification

### 4. Configuration Files
- **vsftpd.conf**: vsftpd server configuration
- **proftpd.conf**: ProFTPD server configuration

## Setup Steps

1. **Create project structure**
   ```bash
   mkdir -p ftp-data test-files
   echo "Test file for FTP upload" > test-files/test.txt
   ```

2. **Choose and start a solution**

### Option A: Start ProFTPD server (root uploads)
```bash
docker compose --profile proftpd up -d --build
```

### Option B: Start vsftpd server (pub uploads)
```bash
docker compose --profile vsftpd up -d --build
```

## Usage

### Starting servers
```bash
# ProFTPD (uploads to root directory)
docker compose --profile proftpd up -d

# vsftpd (uploads to /pub subdirectory)
docker compose --profile vsftpd up -d

# Start test client (optional)
docker compose up ftp-test -d
```

### Stopping servers
```bash
docker compose down
```

### Connecting to FTP servers

#### ProFTPD Server
- **Host**: localhost
- **Port**: 21
- **Username**: anonymous
- **Password**: (leave empty)
- **Upload directory**: `/` (root)

#### vsftpd Server
- **Host**: localhost
- **Port**: 21
- **Username**: anonymous
- **Password**: (leave empty)
- **Upload directory**: `/pub`

### File storage
Uploaded files are stored in the local `ftp-data/` directory on the host machine.

## Configuration Details

- **Anonymous uploads**: Enabled
- **Passive mode**: Ports 21100-21110
- **Upload directory**: /var/ftp/pub (mapped to ./ftp-data)
- **File permissions**: 644 (readable by all, writable by owner)

## Testing

The setup includes a test client container that can be used to verify FTP functionality:

### Testing ProFTPD (root uploads)
```bash
# Start ProFTPD and test client
docker compose --profile proftpd up -d --build
docker compose up ftp-test -d

# Test upload to root directory
docker exec ftp-test-client sh -c "apk add --no-cache lftp && lftp -c 'open ftp://ftp-server-proftpd:21; user anonymous \"\"; ls; put /test-files/test.txt; ls; quit'"
```

### Testing vsftpd (pub uploads)
```bash
# Start vsftpd and test client
docker compose --profile vsftpd up -d --build
docker compose up ftp-test -d

# Test upload to /pub directory
docker exec ftp-test-client sh -c "apk add --no-cache lftp && lftp -c 'open ftp://ftp-server-vsftpd:21; user anonymous \"\"; ls; cd pub; put /test-files/test.txt; ls; quit'"
```

## Security Notes

- This configuration allows anonymous uploads without authentication
- Intended for development/testing purposes
- Consider implementing authentication for production use
- Files uploaded are world-readable with 644 permissions