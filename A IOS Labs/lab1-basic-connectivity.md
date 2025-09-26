# Lab 1: Basic Connectivity Test

## Objective
Test Ansible connection to CSR1000v router and gather basic device information using the `ios_facts` module.

## Prerequisites
- CSR1000v router accessible at `csr1000v-pod-01.localdomain`
- Ansible installed on control machine
- SSH connectivity to the router

## Lab Setup
Your inventory file should contain:
```
csr1000v-pod-01.localdomain ansible_user=admin ansible_password=Cisco123 

[csr]
csr1000v-pod-01.localdomain
```

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: Test Basic Connectivity
Test if Ansible can reach the CSR1000v:
```bash
ansible csr -i inventory.txt -m ping
```

### Step 2: Gather Basic Facts
Use the ios_facts module from command line:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_facts
```

### Step 3: Get Specific Information
Gather only hardware and interface facts:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_facts -a "gather_subset=hardware,interfaces"
```

### Step 4: Display Formatted Output
Get facts with better formatting:
```bash
ansible csr -i inventory.txt -m cisco.ios.ios_facts -a "gather_subset=default" --tree /tmp/facts
```

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the Playbook
Execute the comprehensive connectivity test playbook:
```bash
ansible-playbook -i inventory.txt lab1-connectivity-test.yml
```

### Step 2: Review Output
The playbook will:
- Test SSH connectivity to the CSR1000v
- Gather device facts including:
  - IOS version
  - Hostname
  - Serial number
  - Memory information
  - Interface list

### Step 3: Verify Results
Check that the following information is displayed:
- Device is reachable
- IOS version is shown
- Hostname matches expected value
- Interface information is collected

## Expected Output

### CLI Method Output
```bash
$ ansible csr -i inventory.txt -m ping
csr1000v-pod-01.localdomain | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

$ ansible csr -i inventory.txt -m cisco.ios.ios_facts -a "gather_subset=default"
csr1000v-pod-01.localdomain | SUCCESS => {
    "ansible_facts": {
        "ansible_net_hostname": "csr1000v-pod-01",
        "ansible_net_version": "16.09.03",
        "ansible_net_model": "CSR1000V"
    }
}
```

### Playbook Method Output
```
TASK [Gather device facts] *****************************************************
ok: [csr1000v-pod-01.localdomain]

TASK [Display device information] *********************************************
ok: [csr1000v-pod-01.localdomain] => {
    "msg": "Device: csr1000v-pod-01, IOS Version: 16.09.03, Serial: XXXXXXXXX"
}
```

## Troubleshooting
- **Connection timeout**: Verify IP address and SSH access
- **Authentication failed**: Check username/password in inventory
- **Host key verification**: Ensure `host_key_checking = False` in ansible.cfg

## Learning Objectives
- Understand Ansible inventory structure
- Learn to use `ios_facts` module with CLI ad-hoc commands
- Practice basic Ansible playbook execution
- Compare CLI vs YAML approaches
- Verify network device connectivity
- Understand different fact gathering options

## Next Steps
Proceed to Lab 2: Interface Configuration to build on this foundation.