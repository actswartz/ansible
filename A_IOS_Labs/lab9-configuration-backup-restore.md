# Lab 9: Configuration Backup and Restore

## Objective
Implement configuration backup, restore, and versioning workflows using Ansible for network configuration management.

## Prerequisites
- Completed Lab 8 (User Management and AAA)
- Understanding of Cisco configuration files
- Access to file storage location for backups

## Lab Setup
Your inventory file should contain:
```
csr1000v-pod-01.localdomain ansible_user=admin ansible_password=Cisco123 

[csr]
csr1000v-pod-01.localdomain
```

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: Backup Running Configuration
Save current running configuration:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show running-config'" --tree /tmp/config-backup
```

### Step 2: Copy Configuration to TFTP/SCP
Backup configuration to remote server:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='copy running-config tftp://192.168.10.100/csr-backup-$(date +%Y%m%d-%H%M%S).cfg'"
```

### Step 3: Save Running to Startup
Save current configuration:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='copy running-config startup-config'"
```

### Step 4: View Configuration Archive
Check archived configurations:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show archive'"
```

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the Configuration Backup Playbook
Execute the comprehensive backup and restore playbook:
```bash
ansible-playbook -i inventory.txt lab9-config-backup-restore.yml
```

### Step 2: Review Configuration
The playbook will:
- Create timestamped configuration backups
- Store configurations in version control format
- Compare configurations between versions
- Demonstrate configuration restoration
- Set up automated backup scheduling

### Step 3: Validate Results
Check that the following operations are completed:
- Configuration backups created with timestamps
- Backup files stored in organized directory structure
- Configuration differences identified
- Restore capability demonstrated

## Expected Output

### CLI Method Output
```bash
$ ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show running-config'" --tree /tmp/config-backup
csr1000v-pod-01.localdomain | SUCCESS => {
    "changed": false,
    "stdout": [
        "Building configuration...\n\nCurrent configuration : 2048 bytes\n!\nversion 16.09\n..."
    ]
}

$ ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='copy running-config startup-config'"
csr1000v-pod-01.localdomain | SUCCESS => {
    "changed": false,
    "stdout": [
        "Building configuration...\n[OK]"
    ]
}
```

### Playbook Method Output
```
TASK [Create configuration backup] ************************************
ok: [csr1000v-pod-01.localdomain]

TASK [Save backup to file] ********************************************
changed: [localhost]

TASK [Compare configurations] *****************************************
ok: [csr1000v-pod-01.localdomain]

TASK [Demonstrate restore capability] *********************************
ok: [csr1000v-pod-01.localdomain]
```

## Troubleshooting
- **Backup fails**: Check file system space and permissions
- **TFTP/SCP issues**: Verify network connectivity and server configuration
- **Restore problems**: Ensure backup file format is correct
- **Archive not working**: Check archive configuration and storage

## Key Commands Reference
- `copy running-config startup-config` - Save running to startup
- `copy running-config tftp:` - Backup to TFTP server
- `copy tftp: running-config` - Restore from TFTP server
- `archive config` - Enable configuration archiving
- `show archive` - Display archived configurations
- `configure replace <url>` - Replace configuration from file
- `show configuration sessions` - Display config sessions

## Learning Objectives
- Implement automated configuration backup workflows
- Store configurations with version control and timestamps
- Compare configuration differences between versions
- Demonstrate configuration restoration procedures
- Use Ansible for configuration lifecycle management
- Set up automated backup scheduling
- Understand configuration rollback capabilities
- Compare CLI vs YAML approaches for backup/restore

## Next Steps
Proceed to Lab 10: Configuration Validation and Compliance to implement configuration monitoring.