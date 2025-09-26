#!/bin/bash
echo "ansible-playbook -i ansible-collection-sdwan/inventory.ini SDWAN-lab1-device-discovery.yml"
ansible-playbook -i SDWAN-inventory.txt SDWAN-lab1-device-discovery.yml
