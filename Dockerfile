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