Certification Authority server
==============================

A simple ssh server with openssl and some scripts that let it behave as a poor man's certification authority.

The container is based on [rjrivero/baseimage-ssh](https://hub.docker.com/r/rjrivero/baseimage-ssh/), so it supports and requires certificate-based SSH login.

To build the container:

```
git clone https://github.com/rjrivero/docker-openssl-ca
cd docker-openssl-ca

# To build
docker build --rm -t rjrivero/openssl-ca .
```

To run:

```
docker run --rm -p 2222:22 -v /opt/ca/role:/opt/ca --name ca rjrivero/openssl-ca
```

Volumes
-------

The CA files are stored in the volume **/opt/ca**. This path is owned by root. The container expects the following folder structure under /opt/ca (and creates it, if not found):

  - /opt/ca/openssl.cnf: openssl config file (for subordinate CA tasks).
  - /opt/ca/openssl.root.cnf: openssl config file (for root CA tasks).
  - /opt/ca/private: folder for private keys.
  - /opt/ca/certs: folder for ca cert and subordinate ca cert chains.
  - /opt/ca/csr: folder for csrs to be signed.
  - /opt/ca/crl: folder for certificate revocation list
  - /opt/ca/newcerts: folder for certs signed by the CA.

Then some other book-keeping files like *crlnumber*, *serial*, etc, used by openssl ca.

The most important files are:

  - **/opt/ca/private/ca.key.pem**: The CA private key file.
  - **/opt/ca/certs/ca.cert.pem**: The CA certificate.
  - **/opt/ca/certs/ca-chain.key.pem**: The CA certificate chain.

Environment Variables
---------------------

The container uses the environment variable **CRL_URL** to set the CRL distribution point to be set in the certificates.

**Important!**: if the variable is missing, any CRL distribution points configured in existing *openssl.cnf* and *openssl.root.cnf* are **removed**.

If you configure a CRL, make sure you create at least an empty one initially. Otherwise, any client that fails to check the CRL will refuse the certificate. You can run:

```
/root/scripts/crl.sh
```

And then copy the generated **/opt/ca/crl/latest.crl.pem** the your distribution point.

Ports
-----

The container exposes SSH port **22**.

Usage
-----

  - Start the container with an ssh certificate, and the volume assigned to the root CA. To create a ssh certificate, see https://github.com/rjrivero/docker-baseimage-ssh

```
# Let's assume your CA files will live under /opt/ca. We will create
# two volumes:
# - /opt/ca/root for the root CA files
# - /opt/ca/sub  for the subordinate CA files

sudo mkdir -p /opt/ca/root
sudo mkdir -p /opt/ca/sub

# Run the container with the root CA volume
# Replace <path/to/your/users_ca.pub> with the path to your users_ca.pub file
docker run -d --name root-ca -p 2222:22 \
    -v /opt/ca/root:/opt/ca \
    -v </path/to/your/users_ca.pub>:/etc/ssh/users_ca.pub \
    rjrivero/openssh-ca
```

  - Log into the container as root, and create a self-signed certificate for your root CA.

```
/root/scripts/self_signed.sh
```

  - Run another instance as your subordinate CA

```
sudo mkdir -p /opt/ca/sub

docker run -d --name sub-ca -p 2222:22 \
    -v /opt/ca/sub:/opt/ca \
    -v </path/to/your/users_ca.pub>:/etc/ssh/users_ca.pub \
    rjrivero/openssh-ca
```

  - Log into the subordinate CA container as root, and generate a CSR to be signed by your root CA.

```
/root/scripts/csr.sh
```

  - Transfer the CSR to the root CA's container (via scp or copying the file to the root CA container volume), log into the root CA container, and sign it:

```
/root/scripts/sign_subordinate.sh sub </path/to/subordinate.csr.pem>
```

  - Copy the certificate and certificate chains back to the subordinate CA container. rename them to **/opt/ca/certs/ca.cert.pem** and **/opt/ca/certs/ca-chain.cert.pem**

That's all, you are now ready to offline the root CA (stop the container and move the /opt/ca/root volume somewhere safe), and begin signing certificates with your subordinate CA.
