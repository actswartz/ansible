#!/bin/bash
echo "ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m cisco.catalystwan.devices_info -a '{\"manager_credentials\": {\"url\": \"https://10.10.20.90:443\", \"username\": \"admin\", \"password\": \"C1sco12345\"}}'"
#!/bin/bash
echo "ansible vmanage1 -i SDWAN-inventory.txt -m cisco.catalystwan.devices_info -a '{\"manager_credentials\": {\"url\": \"https://10.10.20.90:8443\", \"username\": \"admin\", \"password\": \"C1sco12345\"}}'"
ansible vmanage1 -i SDWAN-inventory.txt -m cisco.catalystwan.devices_info -a '{"manager_credentials": {"url": "https://10.10.20.90:8443", "username": "admin", "password": "C1sco12345"}}'
