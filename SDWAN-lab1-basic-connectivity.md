# SDWAN Lab 1: Basic Catalyst WAN Connectivity and Device Discovery

## Objective
Connect to Cisco Catalyst WAN vManage controller via REST API and discover all Catalyst WAN devices in the fabric using Ansible automation.

## Prerequisites
- Access to Cisco Catalyst WAN Sandbox environment
- Ansible installed with `cisco.catalystwan` collection
- Basic understanding of Catalyst WAN architecture
- Read-only access credentials

## Lab Environment
- **vManage URL**: https://sandbox-sdwan-2.cisco.com
- **Username**: devnetuser
- **Password**: [Provided by instructor]
- **Version**: Cisco Catalyst WAN v20.10

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: Test Basic API Connectivity
Test connection to vManage API:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m cisco.catalystwan.devices_info -a '{"manager_authentication": {"url": "https://sandbox-sdwan-2.cisco.com", "username": "devnetuser", "password": "[password]"}, "device_category": "controllers"}'
```

### Step 2: Discover All Devices
Get complete device inventory:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m cisco.catalystwan.devices_info -a '{"manager_authentication": {"url": "https://sandbox-sdwan-2.cisco.com", "username": "devnetuser", "password": "[password]"}}'
```

### Step 3: Get Device Status Information
Check device operational status:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m cisco.catalystwan.devices_info -a '{"manager_authentication": {"url": "https://sandbox-sdwan-2.cisco.com", "username": "devnetuser", "password": "[password]"}, "device_category": "vedges"}'
```

### Step 4: Query Specific Device Types
Get controller information:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m cisco.catalystwan.devices_info -a '{"manager_authentication": {"url": "https://sandbox-sdwan-2.cisco.com", "username": "devnetuser", "password": "[password]"}, "device_type": "vmanage"}'
```

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the Device Discovery Playbook
Execute the comprehensive device discovery playbook:
```bash
ansible-playbook -i SDWAN-inventory.txt SDWAN-lab1-device-discovery.yml
```

### Step 2: Review Discovery Results
The playbook will:
- Test API connectivity to vManage
- Discover all devices in the Catalyst WAN fabric
- Categorize devices by type (vManage, vSmart, vBond, vEdge)
- Display device status and reachability
- Generate device inventory report

### Step 3: Validate Results
Check that the following information is collected:
- Complete device inventory with system IPs
- Device status (up/down/unreachable)
- Device types and models
- Site IDs and hostnames
- Certificate status

## Expected Output

### CLI Method Output
```bash
$ ansible catalyst_wan -i SDWAN-inventory.txt -m cisco.catalystwan.devices_info -a '{"manager_authentication": {"url": "https://sandbox-sdwan-2.cisco.com", "username": "devnetuser", "password": "[password]"}}'
sandbox-sdwan-2.cisco.com | SUCCESS => {
    "changed": false,
    "devices": [
        {
            "device_type": "vmanage",
            "hostname": "vmanage",
            "system_ip": "1.1.1.1",
            "site_id": "1",
            "status": "normal"
        }
    ]
}
```

### Playbook Method Output
```
TASK [Test vManage API connectivity] ************************************
ok: [sandbox-sdwan-2.cisco.com]

TASK [Discover all Catalyst WAN devices] **************************************
ok: [sandbox-sdwan-2.cisco.com]

TASK [Display device summary] *******************************************
ok: [sandbox-sdwan-2.cisco.com] => {
    "msg": "Found 12 devices: 2 Controllers, 8 vEdges, 2 vSmarts"
}
```

## Troubleshooting
- **API connection timeout**: Check network connectivity and firewall rules
- **Authentication failed**: Verify username/password provided by instructor
- **SSL certificate errors**: Ensure `ansible_httpapi_validate_certs=false` is set
- **Module not found**: Install cisco.catalystwan collection: `ansible-galaxy collection install cisco.catalystwan`

## Key Catalyst WAN Concepts
- **vManage**: Centralized network management system
- **vSmart**: Catalyst WAN control plane controller
- **vBond**: Catalyst WAN orchestration plane
- **vEdge**: Catalyst WAN data plane routers
- **System IP**: Unique identifier for each Catalyst WAN device

## Learning Objectives
- Connect to Catalyst WAN vManage using REST API
- Understand Catalyst WAN device hierarchy and roles
- Use Ansible for Catalyst WAN device discovery
- Navigate vManage API endpoints
- Generate device inventory reports
- Understand Catalyst WAN fabric topology

## Next Steps
Proceed to SDWAN Lab 2: Catalyst WAN Fabric Status and Health Monitoring to analyze control and data plane health.