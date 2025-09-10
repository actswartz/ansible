# Lab 5: VLANs and Subinterfaces

## Objective
Configure 802.1Q subinterfaces for VLAN segmentation and inter-VLAN routing using both CLI and YAML playbook methods.

## Prerequisites
- Completed Lab 4 (Access Control Lists)
- Understanding of VLAN concepts and 802.1Q trunking
- Familiarity with subinterface configuration

## Lab Setup
Your inventory file should contain:
```
csr1000v-pod-01.localdomain ansible_user=admin ansible_password=Cisco123 

[csr]
csr1000v-pod-01.localdomain
```

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: View Current Interface Configuration
Check existing interface and VLAN configuration:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show interfaces trunk,show ip interface brief'"
```

### Step 2: Configure Subinterface for VLAN 10
Create subinterface for VLAN 10:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='encapsulation dot1Q 10,ip address 192.168.110.1 255.255.255.0,description VLAN10-Users' parents='interface GigabitEthernet1.10'"
```

### Step 3: Configure Subinterface for VLAN 20
Create subinterface for VLAN 20:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='encapsulation dot1Q 20,ip address 192.168.120.1 255.255.255.0,description VLAN20-Servers' parents='interface GigabitEthernet1.20'"
```

### Step 4: Configure Trunk Interface
Enable the parent interface for trunking:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='no shutdown' parents='interface GigabitEthernet1'"
```

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the VLAN Configuration Playbook
Execute the comprehensive VLAN configuration playbook:
```bash
ansible-playbook -i inventory.txt lab5-vlan-config.yml
```

### Step 2: Review Configuration
The playbook will:
- Display current interface status
- Configure multiple subinterfaces for different VLANs
- Set up inter-VLAN routing
- Configure VLAN-specific settings
- Verify subinterface connectivity

### Step 3: Validate Results
Check that the following configurations are applied:
- GigabitEthernet1.10 configured for VLAN 10 (192.168.110.1/24)
- GigabitEthernet1.20 configured for VLAN 20 (192.168.120.1/24)
- GigabitEthernet1.30 configured for VLAN 30 (192.168.130.1/24)
- All subinterfaces are operational

## Expected Output

### CLI Method Output
```bash
$ ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show interfaces trunk'"
csr1000v-pod-01.localdomain | SUCCESS => {
    "changed": false,
    "stdout": [
        "Port        Mode             Encapsulation  Status        Native vlan\nGi1          on               802.1q         trunking      1"
    ]
}

$ ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='encapsulation dot1Q 10,ip address 192.168.10.1 255.255.255.0,description VLAN10-Users' parents='interface GigabitEthernet1.10'"
csr1000v-pod-01.localdomain | CHANGED => {
    "changed": true,
    "commands": [
        "interface GigabitEthernet1.10",
        "encapsulation dot1Q 10",
        "ip address 192.168.110.1 255.255.255.0",
        "description VLAN10-Users"
    ]
}
```

### Playbook Method Output
```
TASK [Display current interface status] ********************************
ok: [csr1000v-pod-01.localdomain]

TASK [Configure VLAN 10 subinterface] **********************************
changed: [csr1000v-pod-01.localdomain]

TASK [Configure VLAN 20 subinterface] **********************************
changed: [csr1000v-pod-01.localdomain]

TASK [Verify subinterface configuration] *******************************
ok: [csr1000v-pod-01.localdomain]
```

## Troubleshooting
- **Subinterface not coming up**: Check parent interface is enabled (no shutdown)
- **VLAN encapsulation issues**: Verify 802.1Q encapsulation is configured
- **IP conflicts**: Ensure VLAN subnets don't overlap
- **Trunk not working**: Check trunk configuration on connected switch

## Key Commands Reference
- `interface <interface>.<vlan-id>` - Create subinterface
- `encapsulation dot1Q <vlan-id>` - Configure 802.1Q encapsulation
- `switchport mode trunk` - Configure interface as trunk (on switches)
- `show interfaces trunk` - Display trunk interface information
- `show vlans` - Show VLAN information
- `show ip interface brief` - Display interface IP status

## Learning Objectives
- Configure 802.1Q subinterfaces using Ansible
- Understand VLAN encapsulation and trunking
- Set up inter-VLAN routing on router subinterfaces
- Use subinterfaces for network segmentation
- Verify VLAN and subinterface functionality
- Compare CLI vs YAML approaches for VLAN configuration

## Next Steps
Proceed to Lab 6: Static and Default Routing to configure additional routing options.
