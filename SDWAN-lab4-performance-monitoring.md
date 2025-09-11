# SDWAN Lab 4: Network Performance and Statistics Monitoring

## Objective
Monitor and analyze Catalyst WAN network performance metrics including interface statistics, application-aware routing data, and quality of experience measurements using Ansible automation.

## Prerequisites
- Completed SDWAN Lab 3 (Policy and Template Analysis)
- Understanding of network performance metrics
- Familiarity with Catalyst WAN application-aware routing

## Lab Environment
- **vManage URL**: https://10.10.20.90:443
- **Username**: admin
- **Password**: C1sco12345
- **Inventory**: ansible-collection-sdwan/inventory.ini
- **Host**: vmanage1

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: Get Interface Statistics

**Purpose:**
To collect real-time utilization, bandwidth, and error statistics for all network interfaces on the SD-WAN devices.

**What it means:**
- This is the fundamental check for network performance, equivalent to `show interface` on a traditional router.
- It allows you to see how much traffic is flowing through each WAN and LAN port, check for physical errors, and identify potential bottlenecks.
- This is the first place to look when troubleshooting a "slow network" complaint.

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/device/interface/stats method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"ifname"**: The name of the interface (e.g., "GigabitEthernet0/0/0").
- **"tx_kbps" / "rx_kbps"**: The current transmit and receive bandwidth in kilobits per second.
- **"tx_pkts" / "rx_pkts"**: The total number of packets transmitted and received.
- **"tx_errors" / "rx_errors"**: The number of errors on the interface. This value should ideally be zero.
- **"utilization"**: The percentage of the interface's capacity that is currently being used.

### Step 2: Monitor Application-Aware Routing Metrics

**Purpose:**
To get detailed performance data specifically related to Application-Aware Routing (AAR), showing how traffic is being classified and steered across the available WAN paths.

**What it means:**
- This command provides visibility into the intelligence of the SD-WAN. It shows you which applications vManage has identified on the network.
- It also shows the measured performance metrics (loss, latency, jitter) for those applications across different WAN links (e.g., MPLS vs. Internet).
- This helps you validate that your AAR policies are working as expected.

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/device/app-route/statistics method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"remote-system-ip"**: The destination of the traffic path being measured.
- **"local-color" / "remote-color"**: The type of WAN transport being used for the path (e.g., "mpls", "biz-internet").
- **"loss"**: The measured packet loss percentage on the path.
- **"latency"**: The measured latency in milliseconds on the path.
- **"jitter"**: The measured jitter in milliseconds on the path.
- **"app"**: The application that was identified and measured.

### Step 3: Check Tunnel Utilization

**Purpose:**
To monitor the bandwidth consumption and performance of the IPsec tunnels that form the data plane between sites.

**What it means:**
- While interface statistics show the performance of the physical links, this command focuses on the overlay tunnels that carry the actual user traffic.
- It helps you understand how much of your WAN capacity is being used by the encrypted SD-WAN traffic.
- This is useful for capacity planning and identifying which tunnels are carrying the most traffic.

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/device/tunnel/interface method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"tunnel-name"**: The identifier for the IPsec tunnel.
- **"tx_bytes" / "rx_bytes"**: The total amount of data transmitted and received through the tunnel.
- **"tx_pkts" / "rx_pkts"**: The total number of packets transmitted and received.
- **"encap_bytes" / "decap_bytes"**: Shows the amount of traffic being encapsulated (sent) and decapsulated (received) by the tunnel.

### Step 4: Get Quality of Experience Data

**Purpose:**
To retrieve a high-level Quality of Experience (QoE) score, which translates raw performance metrics into a simple 0-10 rating of user experience for different applications.

**What it means:**
- QoE is the ultimate measure of network performance because it directly reflects what the end-user is experiencing.
- It combines complex metrics like loss, latency, and jitter into a single, intuitive score (like a Mean Opinion Score or MOS for voice).
- A low QoE score for an application like Microsoft 365 immediately tells you that users are having a poor experience, even if the underlying links are "up".

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/device/app-route/stats method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"application"**: The name of the application being scored.
- **"qoe"**: The Quality of Experience score, typically on a scale of 0 to 10, where higher is better.
- The raw metrics (loss, latency, jitter) that were used to calculate the QoE score are also typically included, allowing you to see *why* the score is high or low.

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the Performance Monitoring Playbook
Execute the comprehensive performance monitoring playbook:
```bash
ansible-playbook -i ansible-collection-sdwan/inventory.ini SDWAN-lab4-performance-monitoring.yml
```

### Step 2: Review Performance Metrics
The playbook will:
- Collect interface utilization and error statistics
- Analyze application-aware routing performance
- Monitor tunnel bandwidth and latency metrics
- Examine quality of experience measurements
- Generate performance trend analysis report

### Step 3: Validate Results
Check that the following performance data is collected:
- Interface bandwidth utilization percentages
- Application response times and loss metrics
- Tunnel throughput and availability statistics
- QoE scores for critical applications
- Performance trend analysis and alerts

## Expected Output

### CLI Method Output
```bash
$ ansible catalyst_wan -i SDWAN-inventory.txt -m cisco.catalystwan.devices_info -a '{"manager_authentication": {"url": "https://sandbox-sdwan-2.cisco.com", "username": "devnetuser", "password": "[password]"}}'
sandbox-sdwan-2.cisco.com | SUCCESS => {
    "json": {
        "data": [
            {
                "system-ip": "1.1.1.1",
                "interface": "GigabitEthernet1",
                "rx-bandwidth": "45.2",
                "tx-bandwidth": "32.1",
                "utilization": "12.3"
            }
        ]
    }
}
```

### Playbook Method Output
```
TASK [Collect interface statistics] ************************************
ok: [sandbox-sdwan-2.cisco.com]

TASK [Analyze application performance] *********************************
ok: [sandbox-sdwan-2.cisco.com]

TASK [Display performance summary] *************************************
ok: [sandbox-sdwan-2.cisco.com] => {
    "msg": "Average utilization: 15.4%, Top application: HTTP (23ms latency)"
}
```

## Troubleshooting
- **No performance data**: Check if devices are generating traffic
- **Incomplete metrics**: Some statistics require time to accumulate
- **High latency queries**: Performance APIs may take time to respond
- **Missing applications**: Not all applications may be visible in AAR

## Key Catalyst WAN Performance Concepts
- **Interface Utilization**: Bandwidth usage percentage on WAN interfaces
- **Application-Aware Routing**: Performance-based path selection metrics
- **Quality of Experience (QoE)**: End-user application performance scoring
- **Tunnel Statistics**: IPsec tunnel performance and reliability metrics
- **SLA Monitoring**: Service Level Agreement compliance tracking
- **Path Performance**: Latency, loss, and jitter measurements per path

## Learning Objectives
- Monitor Catalyst WAN network performance metrics
- Analyze application-aware routing effectiveness
- Understand quality of experience measurements
- Use performance data for network optimization
- Generate automated performance reports
- Identify performance bottlenecks and issues

## Next Steps
Proceed to SDWAN Lab 5: Security and Compliance Reporting to examine security posture and compliance status.
