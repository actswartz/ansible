# Lab 6: Static and Default Routing

## Objective
Configure static routes and default gateway settings for traffic forwarding using both CLI and YAML playbook methods.

## Prerequisites
- Completed Lab 5 (VLANs and Subinterfaces)
- Understanding of routing concepts
- Familiarity with static route configuration

## Lab Setup
Your inventory file should contain:
```
csr1000v-pod-01.localdomain ansible_user=admin ansible_password=Cisco123 

[csr]
csr1000v-pod-01.localdomain
```

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: View Current Routing Table
Check existing routes:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show ip route,show ip route static'"
```

### Step 2: Add Static Route to Remote Network
Configure static route to 10.0.0.0/8 network:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='ip route 10.0.0.0 255.0.0.0 GigabitEthernet2'"
```

### Step 3: Configure Default Route
Set up default gateway:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='ip route 0.0.0.0 0.0.0.0 192.168.1.1'"
```

### Step 4: Add Administrative Distance
Create static route with custom administrative distance:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='ip route 172.16.0.0 255.255.0.0 192.168.10.254 200'"
```

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the Static Routing Playbook
Execute the comprehensive routing configuration playbook:
```bash
ansible-playbook -i inventory.txt lab6-static-routing-config.yml
```

### Step 2: Review Configuration
The playbook will:
- Display current routing table
- Configure multiple static routes
- Set up default gateway
- Configure backup routes with higher AD
- Verify routing table updates

### Step 3: Validate Results
Check that the following configurations are applied:
- Default route (0.0.0.0/0) pointing to ISP gateway
- Static routes for internal networks
- Backup routes with higher administrative distance
- All routes are properly installed in routing table

## Expected Output

### CLI Method Output
```bash
$ ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show ip route'"
csr1000v-pod-01.localdomain | SUCCESS => {
    "changed": false,
    "stdout": [
        "Gateway of last resort is 192.168.1.1 to network 0.0.0.0\n\nS*    0.0.0.0/0 [1/0] via 192.168.1.1\n     10.0.0.0/8 is variably subnetted, 1 subnets, 1 masks\nS       10.0.0.0/8 is directly connected, GigabitEthernet2"
    ]
}

$ ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='ip route 10.0.0.0 255.0.0.0 GigabitEthernet2'"
csr1000v-pod-01.localdomain | CHANGED => {
    "changed": true,
    "commands": [
        "ip route 10.0.0.0 255.0.0.0 GigabitEthernet2"
    ]
}
```

### Playbook Method Output
```
TASK [Display current routing table] ***********************************
ok: [csr1000v-pod-01.localdomain]

TASK [Configure default route] ****************************************
changed: [csr1000v-pod-01.localdomain]

TASK [Configure static routes] ****************************************
changed: [csr1000v-pod-01.localdomain]

TASK [Verify routing table] *******************************************
ok: [csr1000v-pod-01.localdomain]
```

## Troubleshooting
- **Route not appearing**: Check next-hop reachability and interface status
- **Traffic not forwarding**: Verify next-hop IP address is correct
- **Administrative distance**: Lower AD routes take precedence
- **Recursive routing**: Ensure next-hop is directly connected or resolvable

## Key Commands Reference
- `ip route <network> <mask> <next-hop>` - Configure static route
- `ip route <network> <mask> <interface>` - Route via interface
- `ip route <network> <mask> <next-hop> <AD>` - Route with administrative distance
- `ip route 0.0.0.0 0.0.0.0 <next-hop>` - Default route
- `show ip route` - Display routing table
- `show ip route static` - Show only static routes

## Learning Objectives
- Configure static routes using Ansible
- Set up default gateway configuration
- Understand administrative distance values
- Create backup routes with higher AD
- Use interface-based vs next-hop-based routing
- Verify and troubleshoot static routing
- Compare CLI vs YAML approaches for routing configuration

## Next Steps
Proceed to Lab 7: NTP and Logging Configuration to set up network management services.