# Anonymous FTP Server - ProFTPD

A containerized ProFTPD server configured for anonymous uploads directly to the root directory (`/`).

## Features

- 🔓 Anonymous FTP access (no authentication required)
- 📁 Direct uploads to root directory (`/`)
- 🐳 Fully containerized with Docker
- 🔧 Production-ready configuration
- 📝 Comprehensive logging

## Quick Start

```bash
# Run the server
docker run -d -p 21:21 -p 20000-20010:20000-20010 \
  -v $(pwd)/ftp-data:/ftp-data \
  bigsan/anonymous-ftp-proftpd

# Test upload
echo "Hello World" > test.txt
curl -T test.txt ftp://localhost/
```

## Configuration

- **FTP Port**: 21 (control)
- **Passive Ports**: 20000-20010 (data transfer)
- **Upload Directory**: `/ftp-data` (container) - mount to host volume
- **User**: Anonymous (no password required)
- **Upload Location**: Root directory (`/`)

## Docker Compose Example

```yaml
services:
  ftp-server:
    image: bigsan/anonymous-ftp-proftpd
    ports:
      - "21:21"
      - "20000-20010:20000-20010"
    volumes:
      - ./ftp-data:/ftp-data
    restart: unless-stopped
```

## Environment Variables

- `PROFTPD_USER_UID`: UID for FTP user (default: 1000)
- `PROFTPD_USER_GID`: GID for FTP user (default: 1000)

## Security Notes

⚠️ **This image is configured for anonymous access without authentication.** 
Use only in trusted environments or behind proper network security controls.

## Source Code

Full source code and documentation available at: 
[https://github.com/bigsan/anonymous-upload-ftp-docker](https://github.com/bigsan/anonymous-upload-ftp-docker)

## Tags

- `latest` - Latest stable build from main branch
- `main` - Latest build from main branch
- `v*` - Versioned releases