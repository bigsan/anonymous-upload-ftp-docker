FROM alpine:latest

# Install vsftpd
RUN apk add --no-cache vsftpd

# Create FTP user and directories
RUN adduser -D -s /bin/false ftpuser && \
    mkdir -p /var/ftp/pub && \
    chown -R ftpuser:ftpuser /var/ftp && \
    chmod 755 /var/ftp && \
    chmod 777 /var/ftp/pub

# Create vsftpd configuration
COPY vsftpd.conf /etc/vsftpd/vsftpd.conf

# Create directory for uploads
RUN mkdir -p /var/log/vsftpd

# Expose FTP ports
EXPOSE 20 21 21100-21110

# Start vsftpd
CMD ["/usr/sbin/vsftpd", "/etc/vsftpd/vsftpd.conf"]