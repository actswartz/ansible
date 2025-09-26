# Lab 7: NTP and Logging Configuration

## Objective
Configure Network Time Protocol (NTP) and system logging services for network management using both CLI and YAML playbook methods.

## Prerequisites
- Completed Lab 6 (Static and Default Routing)
- Understanding of NTP concepts
- Familiarity with syslog configuration

## Lab Setup
Your inventory file should contain:
```
csr1000v-pod-01.localdomain ansible_user=admin ansible_password=Cisco123 

[csr]
csr1000v-pod-01.localdomain
```

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: View Current Time and NTP Status
Check current time configuration:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show clock,show ntp status,show logging'"
```

### Step 2: Configure NTP Server
Set up NTP server for time synchronization:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='ntp server pool.ntp.org,ntp server 8.8.8.8'"
```

### Step 3: Configure Logging Hosts
Set up syslog servers:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='logging host 192.168.10.100,logging host 192.168.20.100 transport udp port 514'"
```

### Step 4: Set Logging Levels
Configure logging severity levels:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='logging trap informational,logging console warnings'"
```

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the NTP and Logging Playbook
Execute the comprehensive NTP and logging configuration playbook:
```bash
ansible-playbook -i inventory.txt lab7-ntp-logging-config.yml
```

### Step 2: Review Configuration
The playbook will:
- Display current time and NTP status
- Configure multiple NTP servers
- Set up system logging destinations
- Configure logging levels and facilities
- Verify NTP synchronization and logging functionality

### Step 3: Validate Results
Check that the following configurations are applied:
- NTP servers configured and synchronizing
- Syslog servers receiving log messages
- Appropriate logging levels set for console, buffer, and remote
- Time zone and NTP authentication (if configured)

## Expected Output

### CLI Method Output
```bash
$ ansible csr -i inventory.txt -m cisco.ios.ios_command -a "commands='show clock'"
csr1000v-pod-01.localdomain | SUCCESS => {
    "changed": false,
    "stdout": [
        "*15:23:45.123 UTC Mon Dec 11 2023"
    ]
}

$ ansible csr -i inventory.txt -m cisco.ios.ios_config -a "lines='ntp server pool.ntp.org,ntp server 8.8.8.8'"
csr1000v-pod-01.localdomain | CHANGED => {
    "changed": true,
    "commands": [
        "ntp server pool.ntp.org",
        "ntp server 8.8.8.8"
    ]
}
```

### Playbook Method Output
```
TASK [Display current time and NTP status] *****************************
ok: [csr1000v-pod-01.localdomain]

TASK [Configure NTP servers] *******************************************
changed: [csr1000v-pod-01.localdomain]

TASK [Configure logging destinations] **********************************
changed: [csr1000v-pod-01.localdomain]

TASK [Verify NTP synchronization] **************************************
ok: [csr1000v-pod-01.localdomain]
```

## Troubleshooting
- **NTP not synchronizing**: Check network connectivity to NTP servers
- **Time zone issues**: Configure appropriate timezone settings
- **Logs not appearing**: Verify syslog server configuration and network connectivity
- **High CPU from logging**: Adjust logging levels to reduce verbose output

## Key Commands Reference
- `ntp server <ip-address>` - Configure NTP server
- `clock timezone <name> <hours>` - Set timezone
- `logging host <ip-address>` - Configure syslog server
- `logging trap <level>` - Set logging level for remote syslog
- `logging console <level>` - Set console logging level
- `show ntp status` - Display NTP synchronization status
- `show logging` - Display logging configuration

## Learning Objectives
- Configure NTP for network time synchronization
- Set up centralized logging with syslog servers
- Understand logging severity levels and facilities
- Configure timezone and time-related settings
- Verify NTP synchronization and logging functionality
- Use logging for network monitoring and troubleshooting
- Compare CLI vs YAML approaches for management services

## Next Steps
Proceed to Lab 8: User Management and AAA to configure authentication and authorization.