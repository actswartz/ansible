# SDWAN Lab 2: Catalyst WAN Fabric Status and Health Monitoring

## Objective
Monitor and analyze Catalyst WAN fabric health including control plane connections, BFD sessions, and data plane tunnel status using Ansible automation.

## Prerequisites
- Completed SDWAN Lab 1 (Basic Connectivity and Device Discovery)
- Understanding of Catalyst WAN control and data plane concepts
- Access to Catalyst WAN sandbox environment

## Lab Environment
- **vManage URL**: https://sandbox-sdwan-2.cisco.com
- **Username**: devnetuser
- **Password**: [Provided by instructor]

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: Check Control Plane Connections
Monitor control connections between devices:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/device/control/connections method=GET validate_certs=false"
```

### Step 2: Check BFD Sessions Status
Get BFD (Bidirectional Forwarding Detection) session information:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/device/bfd/sessions method=GET validate_certs=false"
```

### Step 3: Monitor OMP (Overlay Management Protocol) Status
Check OMP peer relationships:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/device/omp/peers method=GET validate_certs=false"
```

### Step 4: Check Tunnel Health
Monitor IPsec tunnel status:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/device/tunnel/statistics method=GET validate_certs=false"
```

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the Fabric Health Monitoring Playbook
Execute the comprehensive fabric health playbook:
```bash
ansible-playbook -i SDWAN-inventory.txt SDWAN-lab2-fabric-health.yml
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