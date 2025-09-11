# SDWAN Lab 3: Policy and Template Analysis

## Objective
Analyze Catalyst WAN centralized policies, device templates, and feature templates to understand network configuration and policy enforcement using Ansible automation.

## Prerequisites
- Completed SDWAN Lab 2 (Fabric Health Monitoring)
- Understanding of Catalyst WAN policy concepts
- Familiarity with centralized policy management

## Lab Environment
- **vManage URL**: https://10.10.20.90:443
- **Username**: admin
- **Password**: C1sco12345
- **Inventory**: ansible-collection-sdwan/inventory.ini
- **Host**: vmanage1

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: Get Centralized Policies

**Purpose:**
To retrieve a complete list of all centralized policies that govern the traffic flow, topology, and services across the entire SD-WAN fabric.

**What it means:**
- Centralized policies are the brain of the SD-WAN. They control routing decisions, access control, and path selection.
- This command allows you to audit all the high-level rules that are applied to your network from a single point.
- Understanding these policies is crucial for troubleshooting routing issues or validating security and application performance configurations.

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/template/policy/vedge method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"policyId"**: A unique identifier for the policy.
- **"policyName"**: The human-readable name of the policy (e.g., "Branch_Guest_WiFi_Policy").
- **"policyType"**: The type of policy, such as "Control", "Data", "AppRoute", or "Cflowd".
- **"isActivated"**: A boolean indicating if the policy is currently active and being enforced in the fabric.
- **"devicesAttached"**: The number of devices to which this policy is currently applied.

### Step 2: Get Device Templates

**Purpose:**
To list all the device templates, which are the master blueprints for configuring entire devices in a consistent and scalable manner.

**What it means:**
- Instead of configuring each router individually, you attach a device to a template. The template pushes the entire configuration to the device.
- This command helps you understand how your devices are standardized and what base configurations are being used across different sites or roles.
- It's essential for configuration management and ensuring compliance.

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/template/device method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"templateName"**: The name of the device template (e.g., "Dual_ISP_Branch_Template").
- **"deviceType"**: The hardware or virtual platform the template is designed for (e.g., "vedge-CSR-1000v", "vedge-ISR4331").
- **"devicesAttached"**: The number of devices currently using this template.
- **"lastUpdatedOn"**: A timestamp indicating the last time the template was modified.
- **"templateId"**: The unique ID for the template.

### Step 3: Get Feature Templates

**Purpose:**
To retrieve all the modular and reusable "building blocks" of configuration, known as feature templates.

**What it means:**
- A device template is made up of multiple feature templates. For example, you might have a feature template for NTP, one for OSPF, and one for a specific VPN.
- This command allows you to see all the individual feature configurations available in your vManage instance.
- This is useful for understanding how specific features are configured and where they are being reused.

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/template/feature method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"templateName"**: The name of the feature template (e.g., "Corporate_VPN_512").
- **"templateType"**: The specific feature this template configures (e.g., "vpn-bridge", "aaa", "banner").
- **"deviceType"**: The device models this feature template is compatible with.
- **"devicesAttached"**: The number of devices that have this specific feature template applied to them (via a device template).
- **"factoryDefault"**: A boolean indicating if it is a default, out-of-the-box template or a custom one.

### Step 4: Get Application-Aware Routing Policies

**Purpose:**
To specifically inspect the Application-Aware Routing (AAR) policies that enable intelligent, performance-based path selection for your applications.

**What it means:**
- AAR is a key SD-WAN feature. It allows the network to automatically steer traffic (e.g., move VoIP traffic from a degraded MPLS link to a healthy internet link) based on real-time performance.
- This command lets you see exactly how that intelligence is defined: what applications are being monitored and what Service Level Agreements (SLAs) they must meet.

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/template/policy/definition/app-route method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"name"**: The name of the AAR policy.
- **"sequences"**: The ordered rules within the policy.
- **"match"**: The criteria used to identify the application traffic (e.g., DSCP value, protocol, source/destination IP).
- **"action"**: What to do with the matched traffic, often including SLA parameters.
- **"slaClassList"**: A reference to an SLA Class definition, which specifies the acceptable loss, latency, and jitter for the traffic.

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the Policy Analysis Playbook
Execute the comprehensive policy analysis playbook:
```bash
ansible-playbook -i ansible-collection-sdwan/inventory.ini SDWAN-lab3-policy-analysis.yml
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
