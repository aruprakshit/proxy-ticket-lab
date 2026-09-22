#!/bin/sh
set -eu

# Refuse to overwrite an existing lab identity.
if [ -n "$(ls -A /work/generated)" ]; then
  echo "generated/ is not empty; refusing to overwrite certificates." >&2
  exit 1
fi

umask 077

# A lab CA: its private key signs certificates.
openssl req -x509 -newkey rsa:2048 -noenc -sha256 \
  -days 365 \
  -keyout generated/ca.key \
  -out generated/ca.crt \
  -subj "/CN=Proxy Lab CA" \
  -addext "basicConstraints=critical,CA:TRUE,pathlen:0" \
  -addext "keyUsage=critical,keyCertSign,cRLSign"

# Nginx gets its own key and a certificate request.
openssl req -new -newkey rsa:2048 -noenc -sha256 \
  -keyout generated/server.key \
  -out generated/server.csr \
  -subj "/CN=approved.test"

# The SAN defines the hostname the client will verify.
cat > generated/server.ext <<'EXT'
basicConstraints=critical,CA:FALSE
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=DNS:approved.test
EXT

openssl x509 -req \
  -in generated/server.csr \
  -CA generated/ca.crt \
  -CAkey generated/ca.key \
  -CAcreateserial \
  -days 30 -sha256 \
  -extfile generated/server.ext \
  -out generated/server.crt

# Certificates are public; private keys remain owner-readable only.
chmod 644 generated/ca.crt generated/server.crt

openssl verify \
  -CAfile generated/ca.crt \
  -verify_hostname approved.test \
  generated/server.crt
