#!/bin/sh

cd "${CA_PATH}"

if ! [ -f openssl.cnf ]; then
    # Container not started in the regular way.
    # let's execute the init script.
    /etc/my_init.d/layout.sh
fi
