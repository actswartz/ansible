# SDWAN Lab 3: Policy and Template Analysis

## Objective
Analyze Catalyst WAN centralized policies, device templates, and feature templates to understand network configuration and policy enforcement using Ansible automation.

## Prerequisites
- Completed SDWAN Lab 2 (Fabric Health Monitoring)
- Understanding of Catalyst WAN policy concepts
- Familiarity with centralized policy management

## Lab Environment
- **vManage URL**: https://sandbox-sdwan-2.cisco.com
- **Username**: devnetuser
- **Password**: [Provided by instructor]

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: Get Centralized Policies
Retrieve all centralized policies:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/template/policy/vedge method=GET validate_certs=false"
```

### Step 2: Get Device Templates
List all device templates:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/template/device method=GET validate_certs=false"
```

### Step 3: Get Feature Templates
Retrieve feature template information:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/template/feature method=GET validate_certs=false"
```

### Step 4: Get Application-Aware Routing Policies
Check AAR (Application-Aware Routing) policies:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/template/policy/definition/app-route method=GET validate_certs=false"
```

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the Policy Analysis Playbook
Execute the comprehensive policy analysis playbook:
```bash
ansible-playbook -i SDWAN-inventory.txt SDWAN-lab3-policy-analysis.yml
```

### Step 2: Review Policy Configuration
The playbook will:
- Inventory all centralized policies
- Analyze device and feature templates
- Examine security policies and access lists
- Review QoS and traffic engineering policies
- Generate policy compliance report

### Step 3: Validate Results
Check that the following policy information is collected:
- Complete policy inventory with names and types
- Device template assignments and configurations
- Feature template usage and parameters
- Security policy rules and enforcement
- QoS policy definitions and classifications

## Expected Output

### CLI Method Output
```bash
$ ansible catalyst_wan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/template/policy/vedge method=GET"
sandbox-sdwan-2.cisco.com | SUCCESS => {
    "json": {
        "data": [
            {
                "policyId": "12345",
                "policyName": "Branch_Policy",
                "policyType": "feature",
                "activated": true
            }
        ]
    }
}
```

### Playbook Method Output
```
TASK [Analyze centralized policies] ************************************
ok: [sandbox-sdwan-2.cisco.com]

TASK [Display policy summary] ******************************************
ok: [sandbox-sdwan-2.cisco.com] => {
    "msg": "Found 5 centralized policies, 12 device templates, 28 feature templates"
}

TASK [Generate policy compliance report] *******************************
changed: [localhost]
```

## Troubleshooting
- **Empty policy data**: Check if policies are configured in the sandbox
- **Template not found**: Some templates may be system-generated
- **Access denied**: Verify read permissions for policy APIs
- **Large response**: Some environments may have many templates

## Key Catalyst WAN Policy Concepts
- **Centralized Policy**: Global policies applied across the fabric
- **Device Templates**: Complete device configuration templates
- **Feature Templates**: Modular configuration components
- **Application-Aware Routing**: Traffic steering based on application requirements
- **Security Policies**: Access control and threat protection rules
- **QoS Policies**: Traffic prioritization and bandwidth management

## Learning Objectives
- Understand Catalyst WAN policy architecture and hierarchy
- Analyze centralized vs localized policy configuration
- Examine device and feature template structures
- Review security and QoS policy implementations
- Generate policy documentation and compliance reports
- Identify policy conflicts and optimization opportunities

## Next Steps
Proceed to SDWAN Lab 4: Network Performance and Statistics Monitoring to analyze network performance metrics.