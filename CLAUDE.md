# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a containerized FTP server project providing two complete solutions:
1. **ProFTPD** - Allows anonymous uploads to root directory (`/`)
2. **vsftpd** - Allows anonymous uploads to `/pub` subdirectory

Both solutions are production-ready with Docker Compose orchestration.

## Development Setup

### Quick Start
```bash
# ProFTPD server (root uploads)
docker compose --profile proftpd up -d --build

# vsftpd server (pub uploads)  
docker compose --profile vsftpd up -d --build

# Test client
docker compose up ftp-test -d
```

### Testing Commands
```bash
# Test ProFTPD
docker exec ftp-test-client sh -c "apk add --no-cache lftp && lftp -c 'open ftp://ftp-server-proftpd:21; user anonymous \"\"; put /test-files/test.txt; ls; quit'"

# Test vsftpd
docker exec ftp-test-client sh -c "apk add --no-cache lftp && lftp -c 'open ftp://ftp-server-vsftpd:21; user anonymous \"\"; cd pub; put /test-files/test.txt; ls; quit'"
```

## Architecture

### File Structure
- `Dockerfile.proftpd` - ProFTPD server image
- `Dockerfile.vsftpd` - vsftpd server image
- `proftpd.conf` - ProFTPD configuration
- `vsftpd.conf` - vsftpd configuration
- `docker-compose.yml` - Orchestration with profiles
- `ftp-data/` - Upload destination (host-mounted)

### Key Differences
- **ProFTPD**: Direct root uploads, flexible configuration
- **vsftpd**: Subdirectory uploads, traditional security model

Both solutions support anonymous FTP access without authentication.

## Development History

See `DEVELOPMENT_TASKS.md` for complete task progression and implementation details from initial development through dual solution implementation.