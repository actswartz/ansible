    # SDWAN Lab 1: Basic Catalyst WAN Connectivity and Device Discovery

## Objective
Connect to Cisco Catalyst WAN vManage controller via REST API and discover all Catalyst WAN devices in the fabric using Ansible automation.

## Prerequisites
- Access to Cisco Catalyst WAN Sandbox environment
- Ansible installed with `cisco.catalystwan` collection
- Basic understanding of Catalyst WAN architecture
- Read-only access credentials

## Lab Environment
- **vManage URL**: https://10.10.20.90:443
- **Username**: admin
- **Password**: C1sco12345
- **Inventory**: ansible-collection-sdwan/inventory.ini
- **Host**: vmanage1

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: Test Basic API Connectivity

**Purpose:** 
Establish initial connection to the Catalyst WAN vManage controller and verify that our Ansible automation can successfully authenticate and communicate with the management system.

**What it means:**
- We're using the `cisco.catalystwan.devices_info` module to connect to vManage
- The `manager_credentials` parameter contains our authentication details (URL, username, password)
- The `device_category: "controllers"` filters results to show only controller devices (vManage, vSmart, vBond)
- This is the most basic test to ensure our API connectivity is working

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m cisco.catalystwan.devices_info -a '{"manager_credentials": {"url": "https://10.10.20.90:443", "username": "admin", "password": "C1sco12345"}, "device_category": "controllers"}'
```

**Expected Output Explanation:**
- **"changed": false** - This is a read-only operation, no changes were made
- **"devices"** - Array containing controller device information
- **"device_type": "vmanage"** - Identifies this as a vManage controller
- **"hostname"** - The device's configured hostname
- **"system_ip"** - Unique IP address identifying this device in the Catalyst WAN fabric
- **"site_id"** - The site where this controller is located
- **"status": "normal"** - Device is operational and healthy

### Step 2: Discover All Devices

**Purpose:**
Retrieve a complete inventory of all devices in the Catalyst WAN fabric to understand the network topology and see every device that vManage is managing.

**What it means:**
- By omitting the `device_category` parameter, we get ALL devices in the fabric
- This includes controllers (vManage, vSmart, vBond) and edge devices (vEdge routers)
- This gives us the complete "network map" of what's connected to our Catalyst WAN deployment
- Essential for understanding the scope and scale of the network we're working with

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m cisco.catalystwan.devices_info -a '{"manager_credentials": {"url": "https://10.10.20.90:443", "username": "admin", "password": "C1sco12345"}}'
```

**Expected Output Explanation:**
- **Multiple device objects** - You'll see an array with potentially dozens of devices
- **Mixed device_types** - vmanage, vsmart, vbond, vedge-cloud, vedge-CSR-1000v, etc.
- **Various site_ids** - Shows how devices are distributed across different locations
- **Different status values** - "normal", "unreachable", "partial" indicating device health
- **version information** - Software versions running on each device
- **certificate_validity** - Whether device certificates are valid and not expired

### Step 3: Get Device Status Information

**Purpose:**
Focus specifically on the edge devices (vEdge routers) to understand the operational status of the devices that are handling actual network traffic at branch locations.

**What it means:**
- `device_category: "vedges"` filters to show only edge routers, not controllers
- vEdge devices are the "workhorses" of Catalyst WAN - they handle data forwarding, encryption, and user traffic
- These devices are typically located at branch offices, data centers, and remote sites
- Their status is critical for understanding if remote locations have connectivity

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m cisco.catalystwan.devices_info -a '{"manager_credentials": {"url": "https://10.10.20.90:443", "username": "admin", "password": "C1sco12345"}, "device_category": "vedges"}'
```

**Expected Output Explanation:**
- **Only vEdge devices** - Results filtered to show vedge-cloud, vedge-CSR-1000v, vedge-ISR, etc.
- **site_id values** - Each vEdge represents a different site/location in your network
- **reachability** - Critical indicator: can vManage communicate with this branch?
- **device_model** - Shows physical/virtual platform (ISR4000, CSR1000v, vEdge Cloud, etc.)
- **local_system_ip** - IP address used for internal Catalyst WAN routing
- **status indicators** - "normal" means site is fully operational, "unreachable" means site is down
- **uptime** - How long each site has been operational
- **control_connections** - Whether the site can reach vSmart controllers

### Step 4: Query Specific Device Types

**Purpose:**
Demonstrate how to query for very specific device types, in this case focusing only on vManage controllers to understand the management infrastructure.

**What it means:**
- `device_type: "vmanage"` is more specific than `device_category: "controllers"`
- This shows only vManage devices, excluding vSmart and vBond controllers
- Useful for understanding management capacity and redundancy
- In production environments, you might have multiple vManage instances for high availability
- This technique can be used for any specific device type (vsmart, vbond, vedge-cloud, etc.)

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m cisco.catalystwan.devices_info -a '{"manager_credentials": {"url": "https://10.10.20.90:443", "username": "admin", "password": "C1sco12345"}, "device_type": "vmanage"}'
```

**Expected Output Explanation:**
- **Only vManage devices** - Results show just the management controllers
- **cluster_id** - If multiple vManage instances exist, shows cluster membership
- **is_installed** - Whether the device software is properly installed
- **is_active** - In multi-vManage deployments, shows which is the active manager
- **personality** - Role in the cluster (management, standby, etc.)
- **services** - What management services this vManage instance provides
- **cpu_load** and **memory_usage** - Resource utilization of management system
- **device_groups** - What device templates and policies this vManage manages
- **total_devices** - How many devices this vManage instance is responsible for

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the Device Discovery Playbook
Execute the comprehensive device discovery playbook:
```bash
ansible-playbook -i ansible-collection-sdwan/inventory.ini SDWAN-lab1-device-discovery.yml
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
$ ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m cisco.catalystwan.devices_info -a '{"manager_credentials": {"url": "https://10.10.20.90:443", "username": "admin", "password": "C1sco12345"}, "device_category": "controllers"}'
vmanage1 | SUCCESS => {
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
