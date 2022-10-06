#!/bin/bash

DOMAIN_IDS=$(plesk ext wp-toolkit list | sed 1d | awk '{print $1}')
CHECK_CHECKSUM=1
CHECK_MENUS=1

print_usage() {
  echo "==="
  echo "Usage: $0 [-c] [-m]"
  echo "-c : check checksum for plugins and core (possible values: 1, 0)"
  echo "-m : check menus (possible values: 1, 0)"
  echo "==="
}

while getopts 'c:m:h' flag; do
  case "${flag}" in
    c) CHECK_CHECKSUM="${OPTARG}" ;;
    c) CHECK_MENUS="${OPTARG}" ;;
    h) print_usage
       exit 1 ;;
  esac
done

for DOMAIN_ID in $DOMAIN_IDS 
do
      SITE_URL=$(plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- option get siteurl)
      echo "Domain ID: $DOMAIN_ID"
      echo "Website: $SITE_URL"
      echo "Aggiorno il core..."
      plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- core update

      plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- plugin is-installed wordfence
      if [[ $? -eq 1 ]]; then
        echo "Installo WordFence..."
        plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- plugin install wordfence --activate
      fi

      if [[ $CHECK_MENUS -eq 1 ]]; then
        plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- plugin is-installed best-restaurant-menu-by-pricelisto
        if [[ $? -eq 0 ]]; then
                echo "Questo dominio contiene il plugin dei menus..."
                echo "Aggiorno plugin user-role-editor:"
                plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- plugin update user-role-editor
                echo "Reinstallo il plugin del ristorante:"
                plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- plugin install --force  best-restaurant-menu-by-pricelisto
        fi
      fi

      if [[ $CHECK_CHECKSUM -eq 1 ]]; then

        echo "Verifica checksum del core in corso..."
        plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- core verify-checksums
        echo "Verifica checksum dei plugin in corso..."
        plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- plugin --all verify-checksums
        echo "Per fare modifiche esegui: plesk ext wp-toolkit --wp-cli -instance-id \"$DOMAIN_ID\" -- command "
        read -p "Controlla e riprendi..."
      fi
done
