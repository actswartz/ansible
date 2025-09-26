# Lab 10: Configuration Validation and Compliance

## Objective
Implement configuration validation, compliance checking, and automated verification workflows using Ansible to ensure network standards and policies.

## Prerequisites
- Completed Lab 9 (Configuration Backup and Restore)
- Understanding of network compliance requirements
- Familiarity with configuration validation concepts

## Lab Setup
Your inventory file should contain:
```
csr1000v-pod-01.localdomain ansible_user=admin ansible_password=Cisco123 

[csr]
csr1000v-pod-01.localdomain
```

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: Check Interface Status Compliance
Validate all interfaces are properly configured:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show ip interface brief'"
```

### Step 2: Verify Security Compliance
Check security settings compliance:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show running-config | include password,show running-config | include access-list'"
```

### Step 3: Validate Routing Configuration
Check routing table and protocol status:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show ip route summary,show ip protocols'"
```

### Step 4: Check Service Status
Verify critical services are running:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show ntp status,show logging'"
```

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the Configuration Validation Playbook
Execute the comprehensive validation and compliance playbook:
```bash
ansible-playbook -i inventory.txt lab10-config-validation-compliance.yml
```

### Step 2: Review Validation Results
The playbook will:
- Perform comprehensive configuration validation
- Check compliance against organizational standards
- Generate compliance reports
- Identify configuration drift
- Verify service status and functionality

### Step 3: Analyze Compliance Report
Check that the following validations pass:
- All interfaces have proper descriptions
- Security policies are enforced
- Routing protocols are functioning correctly
- Management services are properly configured
- No configuration drift detected

## Expected Output

### CLI Method Output
```bash
$ ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show ip interface brief'"
csr1000v-pod-01.localdomain | SUCCESS => {
    "changed": false,
    "stdout": [
        "Interface              IP-Address      OK? Method Status                Protocol\nGigabitEthernet1       unassigned      YES unset  up                    up\nGigabitEthernet2       192.168.10.1    YES manual up                    up"
    ]
}

$ ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show running-config | include password'"
csr1000v-pod-01.localdomain | SUCCESS => {
    "changed": false,
    "stdout": [
        "enable secret 5 $1$hash$encrypted\nusername admin secret 5 $1$hash$encrypted"
    ]
}
```

### Playbook Method Output
```
TASK [Validate interface configuration] ********************************
ok: [csr1000v-pod-01.localdomain]

TASK [Check security compliance] ***************************************
ok: [csr1000v-pod-01.localdomain]

TASK [Verify routing protocols] ****************************************
ok: [csr1000v-pod-01.localdomain]

TASK [Generate compliance report] **************************************
changed: [localhost]
```

## Troubleshooting
- **Validation failures**: Review specific compliance requirements
- **Service not running**: Check service configuration and dependencies
- **Configuration drift**: Compare with baseline configurations
- **Performance issues**: Validate resource utilization and capacity

## Key Commands Reference
- `show running-config` - Display current configuration
- `show ip interface brief` - Verify interface status
- `show ip route summary` - Check routing table health
- `show processes cpu` - Monitor CPU utilization
- `show memory` - Check memory usage
- `show version` - Verify software version compliance
- `show inventory` - Check hardware compliance

## Learning Objectives
- Implement automated configuration validation workflows
- Create compliance checking procedures
- Generate comprehensive compliance reports
- Monitor configuration drift and changes
- Verify network service functionality
- Use Ansible for continuous compliance monitoring
- Understand network security validation
- Compare CLI vs YAML approaches for validation

## Lab Series Summary
Congratulations! You have completed all 10 labs covering:
1. **Basic Connectivity** - Ansible fundamentals with Cisco devices
2. **Interface Configuration** - Layer 3 interface management
3. **OSPF Routing** - Dynamic routing protocol configuration
4. **Access Control Lists** - Traffic filtering and security
5. **VLANs and Subinterfaces** - Network segmentation
6. **Static and Default Routing** - Manual routing configuration
7. **NTP and Logging** - Network management services
8. **User Management and AAA** - Authentication and authorization
9. **Configuration Backup and Restore** - Configuration lifecycle management
10. **Configuration Validation and Compliance** - Automated verification

These labs provide a comprehensive foundation for network automation using Ansible with Cisco CSR1000V routers.