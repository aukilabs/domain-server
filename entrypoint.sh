#!/bin/sh

set -o allexport
source ./.env.secret
set +o allexport

sleep 8
rm tunnels
wget -o- ngrok:4040/api/tunnels
NGROK_URL=$(cat tunnels | grep -o "https://.*ngrok.io")
DS_REGISTRATION_CREDENTIALS=$(echo -n "$SERVER_ID:$SERVER_REGISTRATION_SECRET" | base64 -w 0)
./ds --registration-credentials=$DS_REGISTRATION_CREDENTIALS --public-url=$NGROK_URL
