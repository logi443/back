#!/bin/bash

echo "1) Iran"
echo "2) Kharej"
read -p "Select: " choice

case $choice in
  1) PREFIX="iran" ;;
  2) PREFIX="kharej" ;;
  *)
    echo "Invalid option."
    exit 1
    ;;
esac

CONFIG_DIR="/root/backhaul-core"

mapfile -t FILES < <(find "$CONFIG_DIR" -maxdepth 1 -name "${PREFIX}*.toml" | sort)

if [ ${#FILES[@]} -eq 0 ]; then
  echo "No config files found for: $PREFIX"
  exit 1
fi

if [ ${#FILES[@]} -eq 1 ]; then
  SELECTED="${FILES[0]}"
  echo "Found: $SELECTED"
else
  echo "Multiple config files found:"
  for i in "${!FILES[@]}"; do
    echo "  $((i+1))) ${FILES[$i]}"
  done
  echo "  0) All"
  read -p "Select file number (0 for all): " file_choice

  if [ "$file_choice" == "0" ]; then
    SELECTED_FILES=("${FILES[@]}")
  elif [[ "$file_choice" =~ ^[0-9]+$ ]] && [ "$file_choice" -ge 1 ] && [ "$file_choice" -le ${#FILES[@]} ]; then
    SELECTED_FILES=("${FILES[$((file_choice-1))]}")
  else
    echo "Invalid selection."
    exit 1
  fi
fi

[ -n "$SELECTED" ] && SELECTED_FILES=("$SELECTED")

for FILE in "${SELECTED_FILES[@]}"; do
  BASENAME=$(basename "$FILE" .toml)
  PORT="${BASENAME#$PREFIX}"

  echo "--- Processing: $FILE ---"

  sed -i 's/transport = "wsmux"/transport = "wssmux"/' "$FILE"

  if [ "$PREFIX" == "iran" ]; then
    if ! grep -q 'tls_cert' "$FILE"; then
      sed -i '/^mtu = /a tls_cert = "/root/cert/ip/fullchain.pem"\ntls_key = "/root/cert/ip/privkey.pem"' "$FILE"
    fi
  fi

  SERVICE="backhaul-${BASENAME}.service"
  if systemctl list-units --full -all 2>/dev/null | grep -q "$SERVICE"; then
    systemctl restart "$SERVICE"
    echo "Restarted: $SERVICE"
  else
    echo "Service not found, skipped: $SERVICE"
  fi
done

echo "Done."
