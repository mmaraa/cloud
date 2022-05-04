// Parameters

param deplLocation string = resourceGroup().location

param adminUser string = 'notadmin'

@secure()
param adminPass string
// Variables

var uniq = substring(uniqueString(resourceGroup().id), 0, 4)

// Resources

resource log 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: 'log-ama-${uniq}'
  location: deplLocation
  properties: {
    retentionInDays: 30
  }
}

resource dcr 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  name: 'dcr-ama-${uniq}'
  location: deplLocation
  kind: 'Linux'
  properties: {
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: log.id
          name: log.name
        }
      ]
      azureMonitorMetrics: {
        name: 'azureMonitorMetics-default'
      }
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-InsightsMetrics'
        ]
        destinations: [
          'azureMonitorMetics-default'
        ]
      }
      {
        streams: [
          'Microsoft-Syslog'
        ]
        destinations: [
          log.name
        ]
      }
    ]
    dataSources: {
      performanceCounters: [
        {
          streams: [
            'Microsoft-InsightsMetrics'
          ]
          samplingFrequencyInSeconds: 10
          counterSpecifiers: [
            'Processor(*)\\% Processor Time'
            'Processor(*)\\% Idle Time'
            'Processor(*)\\% User Time'
            'Processor(*)\\% Nice Time'
            'Processor(*)\\% Privileged Time'
            'Processor(*)\\% IO Wait Time'
            'Processor(*)\\% Interrupt Time'
            'Processor(*)\\% DPC Time'
            'Memory(*)\\Available MBytes Memory'
            'Memory(*)\\% Available Memory'
            'Memory(*)\\Used Memory MBytes'
            'Memory(*)\\% Used Memory'
            'Memory(*)\\Pages/sec'
            'Memory(*)\\Page Reads/sec'
            'Memory(*)\\Page Writes/sec'
            'Memory(*)\\Available MBytes Swap'
            'Memory(*)\\% Available Swap Space'
            'Memory(*)\\Used MBytes Swap Space'
            'Memory(*)\\% Used Swap Space'
            'Logical Disk(*)\\% Free Inodes'
            'Logical Disk(*)\\% Used Inodes'
            'Logical Disk(*)\\Free Megabytes'
            'Logical Disk(*)\\% Free Space'
            'Logical Disk(*)\\% Used Space'
            'Logical Disk(*)\\Logical Disk Bytes/sec'
            'Logical Disk(*)\\Disk Read Bytes/sec'
            'Logical Disk(*)\\Disk Write Bytes/sec'
            'Logical Disk(*)\\Disk Transfers/sec'
            'Logical Disk(*)\\Disk Reads/sec'
            'Logical Disk(*)\\Disk Writes/sec'
            'Network(*)\\Total Bytes Transmitted'
            'Network(*)\\Total Bytes Received'
            'Network(*)\\Total Bytes'
            'Network(*)\\Total Packets Transmitted'
            'Network(*)\\Total Packets Received'
            'Network(*)\\Total Rx Errors'
            'Network(*)\\Total Tx Errors'
            'Network(*)\\Total Collisions'
            'System(*)\\Processes'
            'System(*)\\Users'
            'Process(*)\\Pct User Time'
            'Process(*)\\Pct Privileged Time'
            'Process(*)\\Used Memory'
            'Process(*)\\Virtual Shared Memory'
            'System(*)\\Free Virtual Memory'
            'System(*)\\Free Physical Memory'
            'Physical Disk(*)\\Physical Disk Bytes/sec'
            'Physical Disk(*)\\Avg. Disk sec/Transfer'
            'Physical Disk(*)\\Avg. Disk sec/Read'
            'Physical Disk(*)\\Avg. Disk sec/Write'
            'System(*)\\Size Stored In Paging Files'
            'System(*)\\Free Space in Paging Files'
          ]
          name: 'perfCounterDataSource10'
        }
      ]
      syslog: [
        {
          streams: [
            'Microsoft-Syslog'
          ]
          facilityNames: [
            'auth'
            'authpriv'
            'cron'
            'daemon'
            'mark'
            'kern'
            'local0'
            'local1'
            'local2'
            'local3'
            'local4'
            'local5'
            'local6'
            'local7'
            'lpr'
            'mail'
            'news'
            'syslog'
            'user'
            'uucp'
          ]
          logLevels: [
            'Debug'
            'Info'
            'Notice'
            'Warning'
            'Error'
            'Critical'
            'Alert'
            'Emergency'
          ]
          name: 'sysLogsDataSource-1688419672'
        }
      ]
    }
  }
}

resource dcrAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2021-04-01' = {
  name: 'dcr-assoc-${uniq}'
  properties: {
    dataCollectionRuleId: dcr.id
  }
  scope: vms[1]
}

// VNET
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet-${uniq}'
  location: deplLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'sn-vm'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

// VM2 for AMA Only
resource vmNics 'Microsoft.Network/networkInterfaces@2021-05-01' = [for i in range(0, 2): {
  name: 'nic-vm${i}-${uniq}'
  location: deplLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconf-nic-vm${i}-${uniq}'
        properties: {
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${vnet.id}/subnets/sn-vm'
          }
        }
      }
    ]
  }
}]

resource vms 'Microsoft.Compute/virtualMachines@2021-11-01' = [for i in range(0, 2): {
  name: 'vm${i}-ama-${uniq}'
  location: deplLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1ms'
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        osType: 'Linux'
        diskSizeGB: 30
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
      }
      computerName: 'vm${i}-ama-${uniq}'
      adminUsername: adminUser
      adminPassword: adminPass
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: vmNics[i].id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}]

// AMA for VM2
resource vm2ama 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: '${vms[1].name}-ama'
  location: deplLocation
  parent: vms[1]
  properties: {
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.15'
  }
}
