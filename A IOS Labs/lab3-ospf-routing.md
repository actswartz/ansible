# Lab 3: OSPF Routing Setup

## Objective
Configure OSPF routing protocol with router ID, process configuration, and network advertisements using both CLI and YAML playbook methods.

## Prerequisites
- Completed Lab 2 (Interface Configuration)
- Interfaces configured with IP addresses from previous lab
- Understanding of OSPF fundamentals

## Lab Setup
Your inventory file should contain:
```
csr1000v-pod-01.localdomain ansible_user=admin ansible_password=Cisco123 

[csr]
csr1000v-pod-01.localdomain
```

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: View Current Routing Table
Check current routing configuration:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show ip route'"
```

### Step 2: Configure OSPF Process and Router ID
Configure OSPF process 1 with router ID:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='router-id 1.1.1.1' parents='router ospf 1'"
```

### Step 3: Add Network Statements
Advertise networks in OSPF:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='network 192.168.10.0 0.0.0.255 area 0,network 192.168.20.0 0.0.0.255 area 0' parents='router ospf 1'"
```

### Step 4: Verify OSPF Configuration
Check OSPF configuration and neighbors:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show ip ospf,show ip ospf interface,show ip ospf neighbor'"
```

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the OSPF Configuration Playbook
Execute the comprehensive OSPF configuration playbook:
```bash
ansible-playbook -i inventory.txt lab3-ospf-config.yml
```

### Step 2: Review Configuration
The playbook will:
- Display current routing table
- Configure OSPF process with router ID
- Add network statements for areas
- Set interface OSPF parameters
- Verify OSPF neighbor relationships

### Step 3: Validate Results
Check that the following configurations are applied:
- OSPF process 1 is running
- Router ID is set to 1.1.1.1
- Networks 192.168.10.0/24 and 192.168.20.0/24 are advertised
- OSPF is enabled on configured interfaces

## Expected Output

### CLI Method Output
```bash
$ ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show ip route'"
csr1000v-pod-01.localdomain | SUCCESS => {
    "changed": false,
    "stdout": [
        "Gateway of last resort is not set\n\n     192.168.10.0/24 is variably subnetted, 2 subnets, 2 masks\nC       192.168.10.0/24 is directly connected, GigabitEthernet2\nL       192.168.10.1/32 is directly connected, GigabitEthernet2"
    ]
}

$ ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='router-id 1.1.1.1' parents='router ospf 1'"
csr1000v-pod-01.localdomain | CHANGED => {
    "changed": true,
    "commands": [
        "router ospf 1",
        "router-id 1.1.1.1"
    ]
}
```

### Playbook Method Output
```
TASK [Display current routing table] ***********************************
ok: [csr1000v-pod-01.localdomain]

TASK [Configure OSPF process and router ID] ****************************
changed: [csr1000v-pod-01.localdomain]

TASK [Add OSPF network statements] *************************************
changed: [csr1000v-pod-01.localdomain]

TASK [Verify OSPF configuration] ***************************************
ok: [csr1000v-pod-01.localdomain]
```

## Troubleshooting
- **OSPF not starting**: Check interface IP addresses are configured
- **No OSPF neighbors**: Verify network statements match interface subnets
- **Router ID conflicts**: Ensure unique router IDs in multi-device labs
- **Area mismatches**: Confirm all interfaces in correct OSPF areas

## Key Commands Reference
- `router ospf <process-id>` - Enter OSPF configuration mode
- `router-id <ip-address>` - Set OSPF router ID
- `network <network> <wildcard> area <area-id>` - Advertise networks
- `show ip ospf` - Display OSPF process information
- `show ip ospf interface` - Show OSPF-enabled interfaces
- `show ip ospf neighbor` - Display OSPF neighbor relationships

## Learning Objectives
- Configure OSPF routing protocol using Ansible
- Set OSPF router ID and process parameters
- Understand network statements and wildcard masks
- Use OSPF verification commands
- Compare CLI vs YAML approaches for routing protocols
- Understand OSPF area concepts

## Next Steps
Proceed to Lab 4: Access Control Lists (ACLs) to implement traffic filtering.