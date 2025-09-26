# SDWAN Lab 5: Security and Compliance Reporting

## Objective
Analyze Catalyst WAN security posture and compliance status including certificate management, security policies, and audit reporting using Ansible automation.

## Prerequisites
- Completed SDWAN Lab 4 (Network Performance and Statistics Monitoring)
- Understanding of Catalyst WAN security architecture
- Familiarity with PKI and certificate management

## Lab Environment
- **vManage URL**: https://10.10.20.90:443
- **Username**: admin
- **Password**: C1sco12345
- **Inventory**: ansible-collection-sdwan/inventory.ini
- **Host**: vmanage1

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: Check Certificate Status

**Purpose:**
To audit the validity and expiration status of the digital certificates installed on all devices across the SD-WAN fabric.

**What it means:**
- The identity and trust model of the Catalyst WAN fabric is built on a Public Key Infrastructure (PKI). Every device (vEdge, vSmart, vManage) must have a valid certificate to authenticate and communicate securely.
- An expired or invalid certificate will cause a device to be rejected from the fabric, leading to a site outage.
- This command is a proactive check to ensure the entire foundation of trust is healthy.

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/certificate/stats method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"certificate-status": "valid"**: The most critical field. It should be "valid". Other states like "expired" or "invalid" require immediate attention.
- **"days-to-expiry"**: The number of days remaining before the certificate expires. This allows for proactive renewal.
- **"serial-number"**: The unique serial number of the certificate.
- **"system-ip"**: The IP address of the device the certificate belongs to.

### Step 2: Get Security Policy Status

**Purpose:**
To check the status and enforcement of centralized security policies, such as Zone-Based Firewalls, Intrusion Prevention Systems (IPS), and URL filtering.

**What it means:**
- Beyond just connectivity, SD-WAN can provide integrated security services.
- This command allows you to verify that your security policies are correctly applied to the devices and to see high-level statistics about their operation.
- It helps you answer the question, "Is my network security posture being enforced as I designed it?"

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/template/policy/security method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"policyName"**: The name of the security policy.
- **"policyType"**: The specific type of security policy (e.g., "Firewall", "IPS").
- **"isActivated"**: Shows whether the policy is currently active in the fabric.
- **"devicesAttached"**: The number of devices that have this security policy applied.

### Step 3: Monitor Authentication Events

**Purpose:**
To review a log of security-related events, with a focus on user authentication and system access attempts.

**What it means:**
- This is the equivalent of checking the security event log on a server. It provides an audit trail of who has tried to log in to the vManage system.
- It is crucial for security monitoring and for detecting potential unauthorized access attempts or brute-force attacks.

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/device/security/events method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"event-name"**: The type of event (e.g., "user-login", "user-logout", "authentication-failure").
- **"username"**: The username associated with the event.
- **"src-ip"**: The source IP address from which the attempt was made.
- **"timestamp"**: The time the event occurred.
- **"status"**: The outcome of the event (e.g., "success", "failure").

### Step 4: Check Compliance Status

**Purpose:**
To perform an audit of all devices to ensure their running configurations have not drifted from the official configuration defined in their assigned device templates.

**What it means:**
- vManage operates on a "single source of truth" model. The templates are the intended state, and the devices should reflect that state exactly.
- If a device's configuration is changed locally or doesn't match the template for any reason, it is considered "out of compliance."
- This command is essential for maintaining configuration consistency and preventing unauthorized changes.

**Command:**
```bash
ansible vmanage1 -i ansible-collection-sdwan/inventory.ini -m uri -a "url=https://10.10.20.90:443/dataservice/system/audit method=GET validate_certs=false"
```

**Expected Output Explanation:**
- **"config-status"**: The compliance status of the device. "in_sync" means the device configuration matches the template. "out_of_sync" indicates a compliance violation.
- **"system-ip"**: The IP of the device being checked.
- **"hostname"**: The hostname of the device.
- If a device is out of sync, the output may also contain a "diff" showing the specific lines of configuration that do not match the template.


## Troubleshooting
- **Certificate data unavailable**: Some sandbox environments may have limited certificate info
- **Empty security events**: May require time for events to accumulate
- **Policy data missing**: Check if security policies are configured
- **Audit log access**: Some audit APIs may require elevated permissions

## Key Catalyst WAN Security Concepts
- **PKI (Public Key Infrastructure)**: Certificate-based device authentication
- **Certificate Lifecycle**: Automatic certificate provisioning and renewal
- **Security Policies**: Centralized firewall and access control rules
- **Audit Logging**: Comprehensive logging of security events
- **Compliance Monitoring**: Automated compliance checking and reporting
- **Zero Trust Architecture**: Default-deny security posture

## Learning Objectives
- Understand Catalyst WAN security architecture and components
- Monitor certificate lifecycle and PKI health
- Analyze security policy effectiveness
- Generate automated compliance reports
- Identify security vulnerabilities and risks
- Implement security best practices and recommendations

## Lab Series Summary
Congratulations! You have completed all 5 Catalyst WAN labs covering:
1. **Basic Connectivity** - API access and device discovery
2. **Fabric Health** - Control and data plane monitoring  
3. **Policy Analysis** - Configuration and template management
4. **Performance Monitoring** - Network metrics and optimization
5. **Security Compliance** - Security posture and audit reporting

These labs provide comprehensive experience with Catalyst WAN automation using Ansible for monitoring, analysis, and reporting in read-only environments.
