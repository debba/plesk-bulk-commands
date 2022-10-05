#!/bin/bash

function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

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

      echo "Domain ID: $DOMAIN_ID"
      echo "Website: $SITE_URL"

      USERS=$(plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- user list --fields="$FIELD" | sed 1d | grep $QUERY)
      USERS_COUNT=$(echo -n "$USERS" | grep -c '^')

      if [ "$USERS_COUNT" -gt 0 ]; then

          echo "->"
          echo "Utenti da eliminare:"
          plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- user list | grep $QUERY
          echo "->"

          if [[ "yes" == $(ask_yes_or_no "Vuoi eliminare $USERS_COUNT utenti?") ]]; then
            echo "Utenti a cui puoi riassegnare i contenuti:"
            plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- user list
            read -p "Digita l'ID dell'utente: "
            plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- user delete "$USERS" --reassign="$REPLY"
          fi

      fi


      echo "Utenti trovati: $USERS_COUNT"
      echo "_____"
done
