# Lab 2: Interface Configuration

## Objective
Configure GigabitEthernet interfaces with IP addresses, descriptions, and administrative settings using both CLI and YAML playbook methods.

## Prerequisites
- Completed Lab 1 (Basic Connectivity Test)
- CSR1000v router accessible and responding to Ansible
- Understanding of basic Cisco interface configuration

## Lab Setup
Your inventory file should contain:
```
csr1000v-pod-01.localdomain ansible_user=admin ansible_password=Cisco123 

[csr]
csr1000v-pod-01.localdomain
```

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: View Current Interface Status
Check current interface configuration:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show ip interface brief'"
```

### Step 2: Configure Interface with CLI
Configure GigabitEthernet2 interface:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='ip address 192.168.10.1 255.255.255.0,description Lab2-Interface,no shutdown' parents='interface GigabitEthernet2'"
```

### Step 3: Set Interface Description Only
Add description to GigabitEthernet3:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='description Management-Interface' parents='interface GigabitEthernet3'"
```

### Step 4: Verify Configuration
Check the interface configuration:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show running-config interface GigabitEthernet2'"
```

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the Interface Configuration Playbook
Execute the comprehensive interface configuration playbook:
```bash
ansible-playbook -i inventory.txt lab2-interface-config.yml
```

### Step 2: Review Configuration
The playbook will:
- Display current interface status
- Configure multiple interfaces with IP addresses
- Set interface descriptions
- Enable interfaces (no shutdown)
- Verify the configuration changes

### Step 3: Validate Results
Check that the following configurations are applied:
- GigabitEthernet2: IP 192.168.10.1/24, description "Lab2-Interface"
- GigabitEthernet3: IP 192.168.20.1/24, description "Lab2-Secondary"
- Both interfaces are in "up" status

## Expected Output

### CLI Method Output
```bash
$ ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show ip interface brief'"
csr1000v-pod-01.localdomain | SUCCESS => {
    "changed": false,
    "stdout": [
        "Interface              IP-Address      OK? Method Status                Protocol\nGigabitEthernet1       unassigned      YES unset  up                    up      \nGigabitEthernet2       192.168.10.1    YES manual up                    up      \nGigabitEthernet3       192.168.20.1    YES manual up                    up"
    ]
}

$ ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='ip address 192.168.10.1 255.255.255.0,description Lab2-Interface,no shutdown' parents='interface GigabitEthernet2'"
csr1000v-pod-01.localdomain | CHANGED => {
    "changed": true,
    "commands": [
        "interface GigabitEthernet2",
        "ip address 192.168.10.1 255.255.255.0",
        "description Lab2-Interface",
        "no shutdown"
    ]
}
```

### Playbook Method Output
```
TASK [Display current interface status] ************************************
ok: [csr1000v-pod-01.localdomain]

TASK [Configure GigabitEthernet2 interface] ********************************
changed: [csr1000v-pod-01.localdomain]

TASK [Configure GigabitEthernet3 interface] ********************************
changed: [csr1000v-pod-01.localdomain]

TASK [Verify interface configuration] **************************************
ok: [csr1000v-pod-01.localdomain]
```

## Troubleshooting
- **Configuration not applied**: Check interface names match device interfaces
- **IP address conflicts**: Ensure IP ranges don't conflict with existing networks
- **Interface down**: Verify "no shutdown" command is included
- **Permission denied**: Confirm user has configuration privileges

## Key Commands Reference
- `show ip interface brief` - Display interface status summary
- `show running-config interface <name>` - Show specific interface config
- `interface <name>` - Enter interface configuration mode
- `ip address <ip> <mask>` - Assign IP address to interface
- `description <text>` - Add interface description
- `no shutdown` - Enable interface administratively

## Learning Objectives
- Configure interface IP addresses using Ansible
- Set interface descriptions and administrative status
- Use `ios_config` module with parent/child configuration
- Use `ios_command` module for verification
- Compare CLI vs YAML approaches for interface management
- Understand configuration hierarchy in Cisco IOS

## Next Steps
Proceed to Lab 3: OSPF Routing Setup to configure dynamic routing protocols.