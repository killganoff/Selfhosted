#!/bin/bash

if [ -f "./.env" ]; then
	echo "Loading env values from .env file"
	source ./.env
else 
    DATA_DIR="/srv/data"
fi

TRAEFIK_CERTS_DIR="$DATA_DIR/traefik"

if [ ! -f "$TRAEFIK_CERTS_DIR/certs/selfhosted.key" ] || [ ! -f "$TRAEFIK_CERTS_DIR/certs/selfhosted.crt" ]; then

    echo "Generating new self-signed certificate in $TRAEFIK_CERTS_DIR/certs"

    [ ! -d "$TRAEFIK_CERTS_DIR/certs" ] && mkdir -p "$TRAEFIK_CERTS_DIR/certs"

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$TRAEFIK_CERTS_DIR/certs/selfhosted.key" \
        -out "$TRAEFIK_CERTS_DIR/certs/selfhosted.crt" \
        -subj "/CN=SELFHOSTED CERT"
else
    echo "Skipping generation of self-signed certificate"
    echo "...Certificate already exist in $TAREFIK_CERTS_DIR/certs/"
fi

if [ ! -f "$TRAEFIK_CERTS_DIR/auth.passwd" ]; then
    echo "Generating dashboard basic auth file in $TRAEFIK_CERTS_DIR"
    read -p 'Login: ' DASH_LOGIN
    read -sp 'Password: ' DASH_PASSWD
    echo $(htpasswd -nb $DASH_LOGIN $DASH_PASSWD) > $TRAEFIK_CERTS_DIR/auth.passwd
else
    echo "Skipping generation of dashboard auth file"
    echo "... auth.passwd already exist in $TRAEFIK_CERTS_DIR"
fi
