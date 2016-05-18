#!/bin/sh

# Usage instructions
if [ -z $1 ]; then
    echo "USAGE: ${0} <client alias> <path to the .csr.pem file>"
    echo "--"
    echo "Provide the CSR provider's alias"
    exit 1
fi

if [ -z $2 ]; then
    echo "USAGE: ${0} <client alias> <path to the .csr.pem file>"
    echo "--"
    echo "Provide the path to the client's .csr.pem file"
    exit 2
fi

# Get the input file full path before calling common.sh,
# which changes to the CA_PATH dir.
REALPATH=`readlink -f "${2}"`

. /root/scripts/common.sh

# Check if the certificate already exists
if [ -f "newcerts/${1}.cert.pem" ]; then
    echo "Certificate ${CA_PATH}/newcerts/${1}.cert.pem already exists"
    echo "--"
    echo "If you want to overwrite it, then remove it first."
    exit 3
fi

# Sign the subordinate certificate
openssl ca -config openssl.cnf -extensions server_cert \
    -days 375 -notext -md sha256 \
    -in "${REALPATH}" -out "newcerts/${1}.cert.pem"

# Chain the certificates
cat "newcerts/${1}.cert.pem" "certs/ca-chain.cert.pem" \
    > "newcerts/${1}-chain.cert.pem"

# Set proper permissions
chmod 0444 "newcerts/${1}.cert.pem"
chmod 0444 "newcerts/${1}-chain.cert.pem"

echo "Signed certificate at ${CA_PATH}/newcerts/${1}.cert.pem"
