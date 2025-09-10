# SDWAN Lab 4: Network Performance and Statistics Monitoring

## Objective
Monitor and analyze SD-WAN network performance metrics including interface statistics, application-aware routing data, and quality of experience measurements using Ansible automation.

## Prerequisites
- Completed SDWAN Lab 3 (Policy and Template Analysis)
- Understanding of network performance metrics
- Familiarity with SD-WAN application-aware routing

## Lab Environment
- **vManage URL**: https://sandbox-sdwan-2.cisco.com
- **Username**: devnetuser
- **Password**: [Provided by instructor]

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: Get Interface Statistics
Collect interface utilization and statistics:
```bash
ansible sdwan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/device/interface/stats method=GET validate_certs=false"
```

### Step 2: Monitor Application-Aware Routing Metrics
Get AAR (Application-Aware Routing) performance data:
```bash
ansible sdwan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/device/app-route/statistics method=GET validate_certs=false"
```

### Step 3: Check Tunnel Utilization
Monitor IPsec tunnel bandwidth usage:
```bash
ansible sdwan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/device/tunnel/interface method=GET validate_certs=false"
```

### Step 4: Get Quality of Experience Data
Retrieve QoE (Quality of Experience) metrics:
```bash
ansible sdwan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/device/app-route/stats method=GET validate_certs=false"
```

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the Performance Monitoring Playbook
Execute the comprehensive performance monitoring playbook:
```bash
ansible-playbook -i SDWAN-inventory.txt SDWAN-lab4-performance-monitoring.yml
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
$ ansible sdwan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/device/interface/stats method=GET"
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

## Key SD-WAN Performance Concepts
- **Interface Utilization**: Bandwidth usage percentage on WAN interfaces
- **Application-Aware Routing**: Performance-based path selection metrics
- **Quality of Experience (QoE)**: End-user application performance scoring
- **Tunnel Statistics**: IPsec tunnel performance and reliability metrics
- **SLA Monitoring**: Service Level Agreement compliance tracking
- **Path Performance**: Latency, loss, and jitter measurements per path

## Learning Objectives
- Monitor SD-WAN network performance metrics
- Analyze application-aware routing effectiveness
- Understand quality of experience measurements
- Use performance data for network optimization
- Generate automated performance reports
- Identify performance bottlenecks and issues

## Next Steps
Proceed to SDWAN Lab 5: Security and Compliance Reporting to examine security posture and compliance status.