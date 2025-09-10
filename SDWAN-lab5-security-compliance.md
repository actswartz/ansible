# SDWAN Lab 5: Security and Compliance Reporting

## Objective
Analyze Catalyst WAN security posture and compliance status including certificate management, security policies, and audit reporting using Ansible automation.

## Prerequisites
- Completed SDWAN Lab 4 (Network Performance and Statistics Monitoring)
- Understanding of Catalyst WAN security architecture
- Familiarity with PKI and certificate management

## Lab Environment
- **vManage URL**: https://sandbox-sdwan-2.cisco.com
- **Username**: devnetuser
- **Password**: [Provided by instructor]

## Method 1: Using Ansible CLI (Ad-hoc Commands)

### Step 1: Check Certificate Status
Monitor certificate validity and expiration:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/certificate/stats method=GET validate_certs=false"
```

### Step 2: Get Security Policy Status
Check security policy enforcement:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/template/policy/security method=GET validate_certs=false"
```

### Step 3: Monitor Authentication Events
Review authentication and access logs:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/device/security/events method=GET validate_certs=false"
```

### Step 4: Check Compliance Status
Get overall compliance and audit information:
```bash
ansible catalyst_wan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/system/audit method=GET validate_certs=false"
```

## Method 2: Using Ansible YAML Playbook

### Step 1: Run the Security and Compliance Playbook
Execute the comprehensive security audit playbook:
```bash
ansible-playbook -i SDWAN-inventory.txt SDWAN-lab5-security-compliance.yml
```

### Step 2: Review Security Assessment
The playbook will:
- Audit certificate status and expiration dates
- Analyze security policy configurations
- Monitor authentication and authorization events
- Generate compliance status reports
- Identify security vulnerabilities and recommendations

### Step 3: Validate Results
Check that the following security data is collected:
- Certificate validity status for all devices
- Security policy enforcement effectiveness
- Authentication success/failure rates
- Compliance violations and risk assessments
- Security recommendations and remediation steps

## Expected Output

### CLI Method Output
```bash
$ ansible catalyst_wan -i SDWAN-inventory.txt -m uri -a "url=https://sandbox-sdwan-2.cisco.com/dataservice/certificate/stats method=GET"
sandbox-sdwan-2.cisco.com | SUCCESS => {
    "json": {
        "data": [
            {
                "system-ip": "1.1.1.1",
                "certificate-status": "valid",
                "days-to-expiry": "365",
                "serial-number": "ABC123DEF456"
            }
        ]
    }
}
```

### Playbook Method Output
```
TASK [Check certificate status] ****************************************
ok: [sandbox-sdwan-2.cisco.com]

TASK [Analyze security policies] ***************************************
ok: [sandbox-sdwan-2.cisco.com]

TASK [Display security summary] ****************************************
ok: [sandbox-sdwan-2.cisco.com] => {
    "msg": "Security Score: 85% - 12/12 certificates valid, 3 security policies active"
}
```

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