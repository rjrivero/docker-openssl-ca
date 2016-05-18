#!/bin/sh

. /root/scripts/common.sh

# If private key does not exist, create it
if [ ! -f private/ca.key.pem ]; then
    openssl genrsa -aes256 -out private/ca.key.pem 4096
fi
chmod 400 private/ca.key.pem

# Generate a CSR for this subordinate CA, to be signed by root
openssl req -config openssl.cnf -new -sha512 \
    -key private/ca.key.pem \
    -out csr/ca.csr.pem

echo "CSR generated at ${CA_PATH}/csr/ca.csr.pem"
