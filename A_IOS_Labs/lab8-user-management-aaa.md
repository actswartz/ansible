# Lab 8: User Management and AAA

## Objective
Configure user accounts, privilege levels, and basic AAA (Authentication, Authorization, and Accounting) services using both CLI and YAML playbook methods.

## Prerequisites
- Completed Lab 7 (NTP and Logging Configuration)
- Understanding of user privilege levels
- Familiarity with AAA concepts

## Lab Setup
Your inventory file should contain:
```
csr1000v-pod-01.localdomain ansible_user=admin ansible_password=Cisco123 

[csr]
csr1000v-pod-01.localdomain
```

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: View Current User Configuration
Check existing users and privilege levels:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show running-config | section username,show privilege'"
```

### Step 2: Create Local Users
Add users with different privilege levels:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='username netadmin privilege 15 secret NetworkAdmin123,username support privilege 5 secret Support456'"
```

### Step 3: Configure AAA
Enable AAA and set authentication methods:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='aaa new-model,aaa authentication login default local,aaa authorization exec default local'"
```

### Step 4: Configure Console and VTY Authentication
Set up line authentication:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='login authentication default' parents='line vty 0 15'"
```

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the User Management Playbook
Execute the comprehensive user management playbook:
```bash
ansible-playbook -i inventory.txt lab8-user-aaa-config.yml
```

### Step 2: Review Configuration
The playbook will:
- Display current user configuration
- Create multiple user accounts with different privilege levels
- Configure AAA services
- Set up line authentication for console and VTY
- Configure password policies and security settings

### Step 3: Validate Results
Check that the following configurations are applied:
- Multiple users created with appropriate privilege levels
- AAA authentication and authorization configured
- Console and VTY lines secured with authentication
- Password policies enforced

## Expected Output

### CLI Method Output
```bash
$ ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show running-config | section username'"
csr1000v-pod-01.localdomain | SUCCESS => {
    "changed": false,
    "stdout": [
        "username netadmin privilege 15 secret 5 $1$hash$encrypted\nusername support privilege 5 secret 5 $1$hash$encrypted"
    ]
}

$ ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='username netadmin privilege 15 secret NetworkAdmin123'"
csr1000v-pod-01.localdomain | CHANGED => {
    "changed": true,
    "commands": [
        "username netadmin privilege 15 secret NetworkAdmin123"
    ]
}
```

### Playbook Method Output
```
TASK [Display current user configuration] ******************************
ok: [csr1000v-pod-01.localdomain]

TASK [Create administrative users] ************************************
changed: [csr1000v-pod-01.localdomain]

TASK [Configure AAA services] ******************************************
changed: [csr1000v-pod-01.localdomain]

TASK [Configure line authentication] **********************************
changed: [csr1000v-pod-01.localdomain]
```

## Troubleshooting
- **Locked out of device**: Ensure console access remains available
- **Authentication failures**: Verify username/password combinations
- **Privilege level issues**: Check command authorization for specific levels
- **AAA not working**: Verify AAA new-model is enabled

## Key Commands Reference
- `username <name> privilege <level> secret <password>` - Create user account
- `aaa new-model` - Enable AAA services
- `aaa authentication login <list> <method>` - Configure authentication
- `aaa authorization exec <list> <method>` - Configure authorization
- `login authentication <list>` - Apply authentication to line
- `privilege exec level <level> <command>` - Set command privilege level
- `show users` - Display logged-in users

## Learning Objectives
- Create and manage local user accounts
- Configure different privilege levels for users
- Implement AAA authentication and authorization
- Secure console and VTY line access
- Understand privilege level hierarchy (0-15)
- Configure password policies and security settings
- Compare CLI vs YAML approaches for user management

## Next Steps
Proceed to Lab 9: Configuration Backup and Restore to implement configuration management.