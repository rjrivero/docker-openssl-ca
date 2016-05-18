#/bin/sh

. /root/scripts/common.sh

openssl ca -config openssl.cnf -gencrl -out crl/latest.crl.pem
