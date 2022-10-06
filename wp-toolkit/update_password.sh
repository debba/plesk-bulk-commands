#!/bin/bash

if [ -z "$1" ]
  then
    echo "No argument supplied, use: ./update_password.sh email"
    exit
fi

EMAIL=$1
DOMAIN_IDS=$(plesk ext wp-toolkit list | sed 1d | awk '{print $1}')

read -p "Digita la nuova password:"
PASSWORD="$REPLY"

for DOMAIN_ID in $DOMAIN_IDS
do

      SITE_URL=$(plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- option get siteurl)

      echo "Domain ID: $DOMAIN_ID"
      echo "Website: $SITE_URL"

      USERS=$(plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- user list --fields=user_email | sed 1d | grep $EMAIL)
      USERS_COUNT=$(echo -n "$USERS" | grep -c '^')

      if [ "$USERS_COUNT" -gt 0 ]; then
            echo "Email trovata: $EMAIL, aggiorno la password"
            plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- user update "$EMAIL" --user_pass="$PASSWORD" --skip-email
      fi

      echo "_____"
done
