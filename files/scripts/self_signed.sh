#!/bin/sh

. /root/scripts/common.sh

# If private key does not exist, create it
if [ ! -f private/ca.key.pem ]; then
    openssl genrsa -aes256 -out private/ca.key.pem 4096
fi
chmod 0400 private/ca.key.pem

# Check if the certificate already exists
if [ -f "certs/ca.cert.pem" ]; then
    echo "Certificate ${CA_PATH}/certs/ca.cert.pem already exists"
    echo "--"
    echo "If you want to overwrite it, then remove it first."
    exit 1
fi

# Generate a self-signed certificate for a root CA
openssl req -config openssl.root.cnf \
    -key private/ca.key.pem \
    -new -x509 -days 7300 -sha512 -extensions v3_ca \
    -out certs/ca.cert.pem

# Fix file permissions
chmod 0444 certs/ca.cert.pem

echo "Self-signed certificate at ${CA_PATH}/cert/ca.cert.pem"
