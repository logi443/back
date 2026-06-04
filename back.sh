#!/bin/bash

echo "1) Iran"
echo "2) Kharej"
read -p "Select: " choice

case $choice in
  1)
    sed -i 's/transport = "wsmux"/transport = "wssmux"/' /root/backhaul-core/iran443.toml
    sed -i '/^mtu = /a tls_cert = "/root/cert/ip/fullchain.pem"\ntls_key = "/root/cert/ip/privkey.pem"' /root/backhaul-core/iran443.toml
    systemctl restart backhaul-iran443.service
    echo "Iran updated and restarted."
    ;;
  2)
    sed -i 's/transport = "wsmux"/transport = "wssmux"/' /root/backhaul-core/kharej443.toml
    systemctl restart backhaul-kharej443.service
    echo "Kharej updated and restarted."
    ;;
  *)
    echo "Invalid option."
    exit 1
    ;;
esac
