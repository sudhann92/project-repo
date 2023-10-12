#!/bin/bash
# SSL Certificate install script for  node
# Download and Copy the Private SSL certificate and key under </file/folder/path>
# Verify Private SSL Certificate using command openssl x509 -noout -modulus -in [certificate-file.cert]
# Verify Private SSL Key using command openssl rsa -noout -modulus -in [key-file.key]

HOST=$(hostname)

if [ ! -d /app/AAP2 ]; then
        echo "/app/AAP2 directory not present. Creating it"
        mkdir /app/AAP2
else
        echo "/app/AAP2 present"
fi

if [ ! -d /app/AAP2/sslcert ]; then
        echo "/app/AAP2/sslcert directory not present for backup of current SSL certificate directory /etc/xxx. Creating it"
        mkdir /app/AAP2/sslcert
        chown -R root:awx /app/AAP2/sslcert
else
        echo "/app/AAP2/sslcert directory present"
fi

if [ ! -d /app/AAP2/sslcert/tower ]; then
        echo "Backup of current SSL certificate directory /etc/tower not present. Taking backup of it in /app/AAP2/sslcert/tower"
        cp -pr /etc/xxx /app/AAP2/sslcert/xxx
else
        echo "/etc/tower backup present in /app/AAP2/sslcert/tower directory"
fi

if [ ! -f /app/AAP2/sslcert/$HOST.cert ]; then
        echo "ERROR: Private SSL Certificate not found. Please download it from Bitbucket Repository and copy it under under /app/AAP2/sslcert as root:awx. Verify Private SSL Certificate using command openssl x509 -noout -modulus -in $HOST.cert"
        exit 1
else
        echo "Copying the Private SSL Certificate to /etc/tower/tower.cert"
        \cp /app/AAP2/sslcert/$HOST.cert /etc/tower/tower.cert
fi

if [ ! -f /app/AAP2/sslcert/$HOST.key ]; then
        echo "ERROR: Private SSL Key not found. . Verify Private SSL Key using command openssl rsa -noout -modulus -in $HOST.key"
        exit 1
else
        echo "Copying the Private SSL Key to <path of the application>/etc/xxx/xxx.key"
        \cp /app/AAP2/sslcert/$HOST.key <path of the application>
fi

echo "Restarting NGINX Service to take the new Provate SSL Certificate and Key"
        systemctl restart nginx
        systemctl status nginx
