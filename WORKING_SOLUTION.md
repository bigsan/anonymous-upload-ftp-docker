# Working FTP Server Solution - Anonymous Upload to Root Directory

This document records the successful approach to create an FTP server that allows anonymous uploads directly to the root directory ('/').

## Problem Summary

The initial goal was to create a containerized FTP server that allows anonymous users to upload files directly to the root directory without authentication. Several challenges were encountered:

1. **vsftpd Security Restriction**: vsftpd refuses to run with writable root directories inside chroot environments (error: "OOPS: vsftpd: refusing to run with writable root inside chroot()")
2. **Configuration Complexity**: Multiple FTP servers have different approaches to anonymous access
3. **Alpine Linux Limitations**: Some vsftpd features like `allow_writable_chroot` are not available in Alpine's vsftpd package

## Failed Attempts

### 1. vsftpd with `allow_writable_chroot`
- **Issue**: Alpine's vsftpd doesn't support the `allow_writable_chroot=YES` parameter
- **Error**: `500 OOPS: vsftpd: refusing to run with writable root inside chroot()`
- **Conclusion**: vsftpd security model prevents writable root directories

### 2. Pure-FTPd
- **Issue**: Configuration complexity for anonymous access
- **Error**: `530 Login authentication failed`
- **Conclusion**: Requires more complex setup for anonymous uploads

## Working Solution: ProFTPD

### Why ProFTPD Works
- **Flexible Configuration**: Supports detailed anonymous access controls
- **No Chroot Restrictions**: Doesn't have the same security restrictions as vsftpd
- **Module Control**: Can disable problematic modules that cause runtime issues
- **Anonymous Upload Support**: Native support for anonymous uploads to any directory

### Implementation Details

#### Dockerfile
```dockerfile
FROM alpine:latest

# Install proftpd
RUN apk add --no-cache proftpd

# Create FTP directories and runtime directories
RUN mkdir -p /var/ftp && \
    mkdir -p /run/proftpd && \
    mkdir -p /var/log && \
    chown -R ftp:ftp /var/ftp && \
    chmod 777 /var/ftp

# Create proftpd configuration
COPY proftpd.conf /etc/proftpd/proftpd.conf

# Expose FTP ports
EXPOSE 20 21 21100-21110

# Start proftpd
CMD ["proftpd", "--nodaemon"]
```

#### Key Configuration (proftpd.conf)
```apache
ServerName "Anonymous FTP Server"
ServerType standalone
DefaultServer on
Port 21
User ftp
Group ftp

# Disable problematic modules
<IfModule mod_ctrls.c>
  ControlsEngine off
</IfModule>

<IfModule mod_delay.c>
  DelayEngine off
</IfModule>

# Anonymous FTP configuration
<Anonymous /var/ftp>
  User ftp
  Group ftp
  RequireValidShell off
  UserAlias anonymous ftp
  MaxClients 10
  
  # Allow uploads to root directory
  <Directory />
    <Limit WRITE>
      AllowAll
    </Limit>
    AllowOverwrite on
  </Directory>
  
  # Allow directory creation and file deletion
  <Limit MKD>
    AllowAll
  </Limit>
  
  <Limit DELE>
    AllowAll
  </Limit>
</Anonymous>

# Passive mode configuration
PassivePorts 21100 21110
MasqueradeAddress 0.0.0.0

# Other settings
UseReverseDNS off
DefaultRoot /var/ftp
Umask 022
AllowOverwrite on
```

#### Docker Compose
```yaml
services:
  ftpserver:
    build: .
    ports:
      - "21:21"
      - "21100-21110:21100-21110"
    volumes:
      - ./ftp-data:/var/ftp
    environment:
      - PASV_MIN_PORT=21100
      - PASV_MAX_PORT=21110
    restart: unless-stopped
    container_name: ftp-server

  ftp-test:
    image: alpine:latest
    command: sleep infinity
    depends_on:
      - ftpserver
    volumes:
      - ./test-files:/test-files
    container_name: ftp-test-client
```

## Testing Results

### Successful Test Commands
```bash
# Start the server
docker compose up -d --build

# Test anonymous upload
docker exec ftp-test-client sh -c "apk add --no-cache lftp && lftp -c 'open ftp://ftpserver:21; user anonymous \"\"; ls; put /test-files/test.txt; ls; quit'"
```

### Expected Output
```
-rw-r--r--   1 ftp      ftp            25 Jun  7 01:16 test.txt
```

### File Verification on Host
```bash
ls -la ftp-data/
# Shows uploaded files persisted on host system
```

## Key Success Factors

1. **ProFTPD over vsftpd**: More flexible configuration for anonymous access
2. **Runtime Directory Creation**: Created `/run/proftpd` and `/var/log` directories
3. **Module Disabling**: Disabled `mod_ctrls` and `mod_delay` to prevent runtime errors
4. **Proper Anonymous Block**: Used `<Anonymous>` directive with appropriate permissions
5. **Volume Mapping**: Direct mapping of `/var/ftp` to host `./ftp-data` directory

## Usage Instructions

1. **Start Server**: `docker compose up -d`
2. **Connect**: Use any FTP client with:
   - Host: `localhost` (or server IP)
   - Port: `21`
   - Username: `anonymous`
   - Password: (leave empty)
3. **Upload Files**: Files uploaded to root directory appear in `./ftp-data/` on host
4. **Stop Server**: `docker compose down`

## Security Considerations

- This configuration allows unrestricted anonymous uploads
- Intended for development/testing environments
- For production use, consider:
  - Adding authentication
  - Implementing upload quotas
  - Restricting file types
  - Adding logging and monitoring

## Troubleshooting

### Common Issues
1. **Port Conflicts**: Ensure port 21 and 21100-21110 are not in use
2. **Permission Errors**: Verify `./ftp-data` directory exists and is writable
3. **Container Restart Loops**: Check logs with `docker logs ftp-server`

### Useful Commands
```bash
# Check container status
docker ps

# View server logs
docker logs ftp-server

# Test from host machine
ftp localhost 21
# Username: anonymous
# Password: (press enter)
```

This solution successfully achieves the goal of anonymous FTP uploads directly to the root directory using a containerized approach with Docker Compose.