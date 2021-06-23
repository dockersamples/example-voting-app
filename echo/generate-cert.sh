#!/bin/sh
# source : https://raw.githubusercontent.com/Daplie/nodejs-self-signed-certificate-example/master/make-root-ca-and-certificates.sh

set -e

# Create your very own Root Certificate Authority
openssl genrsa \
  -out root-ca.key.pem \
  2048

# Self-sign your Root Certificate Authority
# Since this is private, the details can be as bogus as you like
openssl req \
  -x509 \
  -new \
  -nodes \
  -key root-ca.key.pem \
  -days 9999 \
  -out root-ca.crt.pem \
  -subj "/C=US/ST=Utah/L=Provo/O=ACME Signing Authority Inc/CN=example.com"

# Create a Device Certificate
openssl genrsa \
  -out privkey.pem \
  2048

# Create a request from your Device, which your Root CA will sign
openssl req -new \
  -key privkey.pem \
  -out device-csr.pem \
  -subj "/C=US/ST=Utah/L=Provo/O=ACME Tech Inc/CN=my.example.com"

# Sign the request from Device with your Root CA
# -CAserial certs/ca/my-root-ca.srl
openssl x509 \
  -req -in device-csr.pem \
  -CA root-ca.crt.pem \
  -CAkey root-ca.key.pem \
  -CAcreateserial \
  -out cert.pem \
  -days 9999

# Put things in their proper place
cat cert.pem root-ca.crt.pem > fullchain.pem