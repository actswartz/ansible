# Lab 4: Access Control Lists (ACLs)

## Objective
Create and apply standard and extended Access Control Lists (ACLs) for traffic filtering using both CLI and YAML playbook methods.

## Prerequisites
- Completed Lab 3 (OSPF Routing Setup)
- Understanding of IP addressing and traffic flow
- Familiarity with ACL concepts

## Lab Setup
Your inventory file should contain:
```
csr1000v-pod-01.localdomain ansible_user=admin ansible_password=Cisco123 

[csr]
csr1000v-pod-01.localdomain
```

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: View Current ACL Configuration
Check existing ACLs:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show access-lists'"
```

### Step 2: Create Standard ACL
Create a standard ACL to permit specific networks:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='permit 192.168.10.0 0.0.0.255,deny any' parents='ip access-list standard ALLOW_LAN'"
```

### Step 3: Create Extended ACL
Create an extended ACL for protocol-specific filtering:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='permit tcp 192.168.10.0 0.0.0.255 any eq 80,permit tcp 192.168.10.0 0.0.0.255 any eq 443,deny ip any any' parents='ip access-list extended WEB_TRAFFIC'"
```

### Step 4: Apply ACL to Interface
Apply the standard ACL to an interface:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='ip access-group ALLOW_LAN in' parents='interface GigabitEthernet2'"
```

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the ACL Configuration Playbook
Execute the comprehensive ACL configuration playbook:
```bash
ansible-playbook -i inventory.txt lab4-acl-config.yml
```

### Step 2: Review Configuration
The playbook will:
- Display current ACL configuration
- Create multiple standard and extended ACLs
- Apply ACLs to interfaces
- Verify ACL application and hit counters

### Step 3: Validate Results
Check that the following configurations are applied:
- Standard ACL "ALLOW_LAN" permits 192.168.10.0/24
- Extended ACL "WEB_TRAFFIC" allows HTTP/HTTPS traffic
- Extended ACL "DENY_TELNET" blocks Telnet traffic
- ACLs are properly applied to interfaces

## Expected Output

### CLI Method Output
```bash
$ ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show access-lists'"
csr1000v-pod-01.localdomain | SUCCESS => {
    "changed": false,
    "stdout": [
        "Standard IP access list ALLOW_LAN\n    10 permit 192.168.10.0, wildcard bits 0.0.0.255\n    20 deny   any"
    ]
}

$ ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='permit 192.168.10.0 0.0.0.255,deny any' parents='ip access-list standard ALLOW_LAN'"
csr1000v-pod-01.localdomain | CHANGED => {
    "changed": true,
    "commands": [
        "ip access-list standard ALLOW_LAN",
        "permit 192.168.10.0 0.0.0.255",
        "deny any"
    ]
}
```

### Playbook Method Output
```
TASK [Display current ACL configuration] *******************************
ok: [csr1000v-pod-01.localdomain]

TASK [Create standard ACL ALLOW_LAN] ***********************************
changed: [csr1000v-pod-01.localdomain]

TASK [Create extended ACL WEB_TRAFFIC] *********************************
changed: [csr1000v-pod-01.localdomain]

TASK [Apply ACL to interface] ******************************************
changed: [csr1000v-pod-01.localdomain]
```

## Troubleshooting
- **ACL not working**: Check ACL is applied to correct interface and direction
- **Traffic blocked unexpectedly**: Verify ACL order and implicit deny any
- **Permission denied**: Ensure user has configuration privileges
- **Syntax errors**: Check wildcard masks and protocol specifications

## Key Commands Reference
- `ip access-list standard <name>` - Create named standard ACL
- `ip access-list extended <name>` - Create named extended ACL  
- `permit/deny <source> <wildcard>` - Standard ACL entry
- `permit/deny <protocol> <source> <dest> <port>` - Extended ACL entry
- `ip access-group <acl> {in|out}` - Apply ACL to interface
- `show access-lists` - Display all ACLs and hit counters

## Learning Objectives
- Create standard and extended ACLs using Ansible
- Apply ACLs to interfaces with proper direction
- Understand wildcard masks and ACL logic
- Use named ACLs for better management
- Verify ACL functionality with hit counters
- Compare CLI vs YAML approaches for ACL management

## Next Steps
Proceed to Lab 5: VLANs and Subinterfaces to implement VLAN segmentation.