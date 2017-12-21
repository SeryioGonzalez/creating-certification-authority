#!/bin/bash

CA_config="1_CA_config.ini"

#CrypFolder for storing potentially sensitive file
crypFolder="cryp/"
mkdir -p $crypFolder

CA_name=$(grep organizationalUnitName $CA_config | awk '{ print $3 }')

#Certificates are about key pairs
#The sacred private key
CA_keyFile=$crypFolder$CA_name".key"
#The certificate file containing the public key
CA_cerFile=$crypFolder$CA_name".crt"

#Create an RSA key of 2048 bytes
openssl genrsa -out $CA_keyFile 2048

#The PKI is safe as far as the key is safe. Please do not share it with anyone
chmod 400 $CA_keyFile

#Self sign the certificate, we are a root CA
#The crt file is what has to be shared and trusted for issued certificates to be accepted
openssl req -x509 -new -nodes -key $CA_keyFile -sha256 -days 1024 -out $CA_cerFile -config 1_CA_config.ini
