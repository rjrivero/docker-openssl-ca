#!/bin/sh

# Change to CA top directory
mkdir -p "${CA_PATH}"
cd "${CA_PATH}"

# Create CA folders and files, if not exist
for SUBDIR in certs csr crl newcerts private; do
    mkdir -p "${SUBDIR}"
done
chmod 0700 private
touch index.txt
if [ ! -f serial ];    then echo 1000 > serial;    fi
if [ ! -f crlnumber ]; then echo 1000 > crlnumber; fi

# Copy config files, if not exist
for CNFFILE in openssl.cnf openssl.root.cnf; do
    if [ ! -f "${CNFFILE}" ]; then
        cp "/root/${CNFFILE}" .
    fi
done

# Add or remove CRL distribution points
for CNFFILE in openssl.cnf openssl.root.cnf; do
    # Remove the current CRL distribution points
    sed -i '/^crlDistributionPoints.*/d' "${CNFFILE}"
    if [ ! -z $CRL_URL ]; then
        # Add new CRL DPs to usr_cert and server_cert sections
	for MARKER in usr_cert server_cert; do
            sed -i "/${MARKER}/a crlDistributionPoints = URI:${CRL_URL}" \
                "${CNFFILE}"
	done
    fi
done

