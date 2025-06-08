# Anonymous FTP Server - vsftpd

A containerized vsftpd server configured for anonymous uploads to the `/pub` subdirectory with traditional security model.

## Features

- 🔓 Anonymous FTP access (no authentication required)
- 📁 Uploads to secure `/pub` subdirectory
- 🐳 Fully containerized with Docker
- 🔒 Traditional FTP security model
- 📝 Comprehensive logging

## Quick Start

```bash
# Run the server
docker run -d -p 21:21 -p 20000-20010:20000-20010 \
  -v $(pwd)/ftp-data:/ftp-data \
  bigsan/anonymous-ftp-vsftpd

# Test upload (note the /pub directory)
echo "Hello World" > test.txt
curl -T test.txt ftp://localhost/pub/
```

## Configuration

- **FTP Port**: 21 (control)
- **Passive Ports**: 20000-20010 (data transfer)
- **Upload Directory**: `/ftp-data/pub` (container) - mount to host volume
- **User**: Anonymous (no password required)
- **Upload Location**: `/pub` subdirectory only

## Docker Compose Example

```yaml
services:
  ftp-server:
    image: bigsan/anonymous-ftp-vsftpd
    ports:
      - "21:21"
      - "20000-20010:20000-20010"
    volumes:
      - ./ftp-data:/ftp-data
    restart: unless-stopped
```

## Key Differences from ProFTPD

- **Upload Path**: Files must be uploaded to `/pub/` (not root `/`)
- **Security Model**: Traditional vsftpd security with chroot jail
- **Directory Structure**: Enforces standard FTP directory layout

## Environment Variables

- `VSFTPD_USER_UID`: UID for FTP user (default: 1000)
- `VSFTPD_USER_GID`: GID for FTP user (default: 1000)

## Security Notes

⚠️ **This image is configured for anonymous access without authentication.** 
Use only in trusted environments or behind proper network security controls.

The vsftpd implementation provides a more traditional and secure FTP setup compared to the ProFTPD variant.

## Source Code

Full source code and documentation available at: 
[https://github.com/bigsan/anonymous-upload-ftp-docker](https://github.com/bigsan/anonymous-upload-ftp-docker)

## Tags

- `latest` - Latest stable build from main branch
- `main` - Latest build from main branch
- `v*` - Versioned releases