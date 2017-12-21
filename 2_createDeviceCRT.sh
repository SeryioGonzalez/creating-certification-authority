#!/bin/bash
CA_config="1_CA_config.ini"
CA_name=$(grep organizationalUnitName $CA_config | awk '{ print $3 }')

#CrypFolder for storing potentially sensitive file
crypFolder="cryp/"

CA_keyFile=$crypFolder$CA_name".key"
CA_cerFile=$crypFolder$CA_name".crt"

#Grab device name from CLI
if [ -z "$1" ]
then
    echo "ERROR: Please provide a device name as input parameter"
        echo "USAGE: $0 deviceName"
        exit
fi

deviceName=$1

#Name of the key, CSR (Certificate signing request) and certificate files
device_csrFile=$crypFolder$deviceName".csr"
device_cerFile=$crypFolder$deviceName".crt"
device_pfxFile=$crypFolder$deviceName".pfx"
device_keyFile=$crypFolder$deviceName".key"

country=$(grep countryName $CA_config | awk '{ print $3 }')
locality=$(grep localityName $CA_config | cut -d" " -f2-)
org=$(grep organizationalUnitName $CA_config | awk '{ print $3 }')

subject="/C=$country/L=$locality/O=$org/CN="$deviceName".$org"

#We create a private key of 2048 bytes
openssl genrsa -out $device_keyFile 2048

#We create a signature request to be elavated to the CA for signing
openssl req -new -key $device_keyFile -out $device_csrFile -subj "$subject"

#Using the private key of the CA, we sign the certificate request and generate a certificate
openssl x509 -req -in $device_csrFile -CA $CA_cerFile -CAkey $CA_keyFile -CAcreateserial -out $device_cerFile -days 500 -sha256

#We deliver a PFX wrapper with private, public key, certificate and CA certificate
openssl pkcs12 -export -out $device_pfxFile -inkey $device_keyFile -in $device_cerFile -certfile $CA_cerFile

chmod 400 $device_keyFile
chmod 400 $device_pfxFile
