# AMA-Session-Demos
This is basic infrastructure deployment for Azure Monitor Agent Session.

# How to run
## Deployment
Deploy infrastructure with this
```bash
az deployment group create -f main.bicep -g 'rg-euw-amademo' --parameters adminPass='RandomPass%123456'
```

## Resouces during demo
- VM0 is without AMA-client
- VM1 is already on-boarded with AMA and DCR.

  
Use this to deploy AMA

```bash
az vm extension set --name AzureMonitorLinuxAgent --publisher Microsoft.Azure.Monitor --ids <vm_resource_id>
```
