#!/bin/bash

if [ -z "$1" ]
  then
    echo "No argument supplied, use: ./delete_user.sh query [field]"
    exit
fi

FIELD="user_email"

if [ ! -z "$2" ]
  then
    FIELD=$2
fi

QUERY=$1
DOMAIN_IDS=$(plesk ext wp-toolkit list | sed 1d | awk '{print $1}')

for DOMAIN_ID in $DOMAIN_IDS
do
      SITE_URL=$(plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- option get siteurl)
      USERS=$(plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- user list --fields="$FIELD" | sed 1d | grep $QUERY)
      USERS_COUNT=$(echo -n "$USERS" | grep -c '^')

      if [ "$USERS_COUNT" -gt 0 ]; then
          read -p "Vuoi eliminare $USERS_COUNT utenti?"
          plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- user delete $USERS
      fi

      echo "Domain ID: $DOMAIN_ID"
      echo "Website: $SITE_URL"
      echo "Utenti trovati: $USERS_COUNT"
      echo "_____"
done
