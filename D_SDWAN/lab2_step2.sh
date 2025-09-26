#!/bin/bash
echo "ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a \"url=https://10.10.20.90:443/dataservice/device/bfd/sessions method=GET validate_certs=false\""
ansible vmanage1 -i SDWAN-inventory.txt -m uri -a "url=https://10.10.20.90:8443/dataservice/device/bfd/sessions method=GET validate_certs=false"
