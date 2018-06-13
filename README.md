# AzCli install LAD3.0
This script will use the details you input to install LAD 3.0 on all Linux VMs in a specific subscription ID.
## Requirements
* PrivateConfig.json and publicConfig files must be located in the same directory with this script.
* The details for LAD configuration must be set in advance in the Azure Portal.

## Script execution
* Save the script in a location of you choice, e.g: 
```shell
/home/you_username
```
* make the script executable: 
```shell
chmod +x script_name.sh
```
* execute the script:
```shell
./script_name.sh
```
## Note
* replace script_name.sh with the actual script name
* All VMs will be updated one by one, the script doesn't run any parallel tasks, therefore, for a large pool of VMs, expect to take a long time to complete. 
* Don't kill the script unless the script runs into errors.
 
## Documentation
* https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/diagnostics-linux#installing-and-configuring-lad-30-via-cli
* https://docs.microsoft.com/en-us/cli/azure/vm/extension?view=azure-cli-latest#az-vm-extension-list


## Disclaimer
* This script is provided "as it is" without any waranty. Please make sure you test it in a non production environment before using it in a production one.
* I or the company I work for won't take any responsability for the damage the use of this script may cause

# USE IT AT YOUR OWN RISK!
