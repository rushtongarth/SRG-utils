#!/bin/bash

printf "Enter the website (e.g. www.duckduckgo.com)\n"
read -p 'website name: ' WEBHOST
printf "Verifying host via ping test...\n"
PTEST=$(ping -q -W 5 -c 2 $WEBHOST 2>&1)
if [[ $? -ne 0 ]]
then
	printf "\nPing failed reporting the following:\n"
	printf "$PTEST"
	printf "\n\n"
else
	certname=$(echo $WEBHOST | sed 's/www\.//g')
	certname=${certname%.*}
	WEBHOST="${WEBHOST}:443"
	echo -n | openssl s_client -connect "${WEBHOST}" | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${HOME}/Desktop/${certname}.cert
fi
