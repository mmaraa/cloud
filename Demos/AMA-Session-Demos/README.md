# AMA-Session-Demos
This is basic infrastructure deployment for Azure Monitor Agent Session.

# Infrastructure Overview

## Resources Created by main.bicep
The Bicep template deploys the following resources:
- **Log Analytics Workspace** (`log-ama-{uniq}`)
- **Data Collection Rule (DCR)** (`dcr-ama-{uniq}`) configured for:
  - Performance counters (CPU, Memory, Disk, Network metrics)
  - Syslog collection (all facilities and log levels)
- **Virtual Network** with subnet `10.0.0.0/24`
- **2 Linux VMs** (Ubuntu 20.04 LTS):
  - **VM0** (`vm0-ama-{uniq}`) - Without AMA client
  - **VM1** (`vm1-ama-{uniq}`) - Pre-configured with AMA and DCR association

# How to run
## Deployment
Deploy infrastructure with this
```bash
az deployment group create -f main.bicep -g 'rg-euw-amademo' --parameters adminPass='RandomPass%123456'
```

### Required Parameters
- `adminPass` - VM admin password (required, no default)

### Optional Parameters
- `deplLocation` - Azure region (defaults to resource group location)
- `adminUser` - VM admin username (default: 'notadmin')
s
## Resources during demo
- VM0 is without AMA-client
- VM1 is already on-boarded with AMA and DCR.

Use this to deploy AMA on VM0:
```bash
az vm extension set --name AzureMonitorLinuxAgent --publisher Microsoft.Azure.Monitor --ids <vm_resource_id>
```

# CEF Log Simulator Script

## simulateCefFortiAnalyzer.py
Python script that generates and sends fake FortiGate-like CEF (Common Event Format) syslog messages. Useful for testing syslog ingestion in Azure Monitor.

### Features
- Generates realistic FortiGate web filter log entries in CEF format
- Supports both UDP and TCP transport
- Configurable message count and interval
- Random source IPs (private range) and destination IPs (public range)
- Includes all standard CEF fields and FortiGate-specific extensions

### Usage
```bash
python simulateCefFortiAnalyzer.py <server> [options]
```

### Options
- `server` - Syslog server IP or hostname (required)
- `--port, -p` - Syslog server port (default: 514)
- `--protocol, -P` - Transport protocol: udp or tcp (default: udp)
- `--include-pri` - Include PRI header prefix
- `--pri-header` - PRI header to include (e.g. '<13>')
- `--dvchost` - Device hostname to use (default: 'firewall1')
- `--count, -c` - Number of messages to send (default: 1)
- `--interval, -i` - Seconds between messages (default: 0)

### Examples
```bash
# Send single UDP message to localhost
python simulateCefFortiAnalyzer.py localhost

# Send 10 TCP messages with 1 second interval
python simulateCefFortiAnalyzer.py 10.0.0.5 -P tcp -c 10 -i 1

# Send messages with PRI header
python simulateCefFortiAnalyzer.py syslog.example.com --include-pri --pri-header '<13>'
```

### Generated Log Format
The script generates CEF-formatted logs that simulate FortiGate web filter events with fields like:
- Source/destination IPs and ports
- Policy IDs and UUIDs
- Web filter actions and categories
- Request URLs and
