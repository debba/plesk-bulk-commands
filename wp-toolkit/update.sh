#!/bin/bash

DOMAIN_IDS=$(plesk ext wp-toolkit list | sed 1d | awk '{print $1}')

for DOMAIN_ID in $DOMAIN_IDS 
do
      SITE_URL=$(plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- option get siteurl)
      echo "Domain ID: $DOMAIN_ID"
      echo "Website: $SITE_URL"
      echo "Verifica checksum del core in corso..."
      plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- core verify-checksums
      plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- plugin is-installed best-restaurant-menu-by-pricelisto
      if [[ $? -eq 0 ]]; then
              echo "Questo dominio contiene il plugin dei menus..."
              echo "Aggiorno plugin user-role-editor:"
              plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- plugin update user-role-editor
              echo "Reinstallo il plugin del ristorante:"
              plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- plugin install --force  best-restaurant-menu-by-pricelisto
      fi
      echo "Verifica checksum dei plugin in corso..."
      plesk ext wp-toolkit --wp-cli -instance-id "$DOMAIN_ID" -- plugin --all verify-checksums
      echo "Per fare modifiche esegui: plesk ext wp-toolkit --wp-cli -instance-id \"$DOMAIN_ID\" -- command "
      read -p "Controlla e riprendi..."
done
