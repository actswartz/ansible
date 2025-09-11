# SDWAN Lab 2: Catalyst WAN Fabric Status and Health Monitoring

## Objective
Monitor and analyze Catalyst WAN fabric health including control plane connections, BFD sessions, and data plane tunnel status using Ansible automation.

## Prerequisites
- Completed SDWAN Lab 1 (Basic Connectivity and Device Discovery)
- Understanding of Catalyst WAN control and data plane concepts
- Access to Catalyst WAN sandbox environment

## Lab Environment
- **vManage URL**: https://10.10.20.90:443
- **Username**: admin
- **Password**: C1sco12345
- **Inventory**: ansible-collection-sdwan/inventory.ini
- **Host**: vmanage1

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: Check Control Plane Connections

**Purpose:**
To verify that all edge devices (vEdges) and controllers (vSmarts, vBonds) have stable and active communication channels established. This is the backbone of the SD-WAN control plane.

**What it means:**
- We are querying the vManage API for the status of all control connections in the fabric.
- These connections are used to distribute policies, routing information, and device configurations.
- If a device has a "down" control connection, it cannot be managed by vManage or participate in the fabric's routing decisions.
- This is the first and most critical check for overall fabric health.

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/device/control/connections method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"state": "up"**: The most important field. "up" means the control connection is healthy. "down" indicates a problem.
- **"system-ip"**: The unique identifier of the device being checked.
- **"peer-type"**: The type of device on the other end of the connection (e.g., "vsmart", "vbond").
- **"site-id"**: The location of the device, helping you pinpoint geographical issues.
- **"uptime"**: How long the connection has been active, which can indicate stability.

### Step 2: Check BFD Sessions Status

**Purpose:**
To monitor the status of Bidirectional Forwarding Detection (BFD) sessions, which are used to rapidly detect failures in the data plane paths between vEdge routers.

**What it means:**
- BFD provides sub-second failure detection over the IPsec tunnels.
- If a BFD session goes down, it means the data path between two devices is no longer viable, and traffic will be rerouted to an alternate path if one is available.
- This command gives us a real-time view of the stability of all data plane tunnels.

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/device/bfd/sessions method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"state": "up"**: Indicates the BFD session is active and the path is healthy.
- **"src-ip" / "dst-ip"**: The source and destination IP addresses of the tunnel endpoints.
- **"color"**: The type of WAN transport being used for the tunnel (e.g., "mpls", "biz-internet").
- **"uptime"**: How long the BFD session has been up.
- **"tx_packets" / "rx_packets"**: Shows if BFD control packets are being successfully exchanged.

### Step 3: Monitor OMP (Overlay Management Protocol) Status

**Purpose:**
To verify that the Overlay Management Protocol (OMP) peerings between vEdge routers and vSmart controllers are established and stable.

**What it means:**
- OMP is the routing protocol of the Catalyst WAN fabric, similar to BGP in a traditional network.
- It is responsible for advertising routes, policies, and encryption keys across the overlay network.
- If OMP peering is down, a vEdge router cannot learn routes to other sites and cannot participate in the SD-WAN fabric.

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/device/omp/peers method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"peer-type": "vsmart"**: Shows the vEdge is peered with a vSmart controller.
- **"state": "up"**: The OMP session is established and running correctly.
- **"site-id"**: The site ID of the OMP peer.
- **"routes-received" / "routes-sent"**: The number of OMP routes being exchanged, indicating routing information is flowing.

### Step 4: Check Tunnel Health

**Purpose:**
To get detailed statistics and performance metrics for the IPsec data plane tunnels between sites.

**What it means:**
- This goes beyond simple up/down status and provides performance data for the tunnels that carry user traffic.
- It allows you to check for issues like packet loss, high latency, or jitter that could be impacting application performance.
- This is key for troubleshooting end-user complaints about slow applications.

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/device/tunnel/statistics method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"loss_percentage"**: The percentage of packets being lost over the tunnel. Should be 0%.
- **"latency"**: The round-trip time for packets, measured in milliseconds. High latency can impact application performance.
- **"jitter"**: The variation in latency. High jitter is particularly bad for real-time applications like voice and video.
- **"tx_octets" / "rx_octets"**: The amount of data being sent and received over the tunnel, showing how much it's being utilized.
- **"uptime"**: How long the tunnel has been established.

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the Fabric Health Monitoring Playbook
Execute the comprehensive fabric health playbook:
```bash
ansible-playbook -i ansible-collection-sdwan/inventory.ini SDWAN-lab2-fabric-health.yml
```

### Step 2: Review Health Metrics
The playbook will:
- Check control plane connectivity status
- Monitor BFD session health and statistics
- Analyze OMP peer relationships
- Examine data plane tunnel status
- Generate fabric health summary report

### Step 3: Validate Results
Check that the following health metrics are collected:
- Control connections: UP/DOWN status per device
- BFD sessions: Active session count and state
- OMP peers: Established peer relationships
- IPsec tunnels: Active tunnel count and throughput
- Overall fabric health score

## Expected Output

### CLI Method Output
```bash
$ ansible catalyst_wan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/device/control/connections method=GET"
sandbox-sdwan-2.cisco.com | SUCCESS => {
    "json": {
        "data": [
            {
                "system-ip": "1.1.1.1",
                "site-id": "1",
                "state": "up",
                "peer-type": "vsmart"
            }
        ]
    }
}
```

### Playbook Method Output
```
TASK [Check control plane connections] **********************************
ok: [sandbox-sdwan-2.cisco.com]

TASK [Monitor BFD sessions] *********************************************
ok: [sandbox-sdwan-2.cisco.com]

TASK [Display fabric health summary] ***********************************
ok: [sandbox-sdwan-2.cisco.com] => {
    "msg": "Fabric Health: 8/8 control connections UP, 24/24 BFD sessions active, 12 IPsec tunnels established"
}
```

## Troubleshooting
- **API endpoint not found**: Check Catalyst WAN software version compatibility
- **Empty response data**: Some devices may not have active sessions
- **Permission denied**: Verify read access to monitoring APIs
- **Timeout errors**: Check network connectivity to sandbox environment

## Key Catalyst WAN Health Concepts
- **Control Connections**: Links between vEdge and vSmart controllers
- **BFD Sessions**: Fast failure detection between Catalyst WAN devices
- **OMP Peers**: Routing information exchange relationships
- **IPsec Tunnels**: Encrypted data plane connections between sites
- **Health Score**: Overall fabric operational status percentage

## Learning Objectives
- Understand Catalyst WAN fabric health components
- Monitor control and data plane connectivity
- Analyze BFD session health and performance
- Use REST API endpoints for health monitoring
- Generate automated health reports
- Identify fabric connectivity issues

## Next Steps
Proceed to SDWAN Lab 3: Policy and Template Analysis to examine Catalyst WAN policies and configurations.
