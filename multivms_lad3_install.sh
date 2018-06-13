#!/usr/bin/env

# Check the README.md file for instructions

# Setting the logfile location
logfile=/var/log/lad_install_output.log

# Logging all actions 
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$logfile 2>&1

# Logging the start date and time
date +"%F_%R"



# Configuration details for LAD 3.0
read -p 'Diagnostic Account: ' diagstgacct  
read -p 'Diagnostic Account Sas Token: ' accsastoken
read -p 'Event Hub Name Space: ' eventhubnamespace
read -p 'Event Hub publisher: ' eventhubpublisher
read -p 'Event Hub policy: ' ehpolicy

# Reconfigure the PrivateConfig.json file
sed -i "s#yourdiagstgacct#$diagstacct#g" PrivateConfig.json
sed -i "s#youraccsastoken#$accsastoken#g" PrivateConfig.json
sed -i "s#youreventhubnamespace#$eventhubnamespace#g" PrivateConfig.json
sed -i "s#youreventhubpublisher#$eventhubpublisher#g" PrivateConfig.json
sed -i "s#yourehpolicy#$ehpolicy#g" PrivateConfig.json

# Reconfigure the PublicConfig.json file
sed -i "s#yourdiagstgacct#$diagstacct#g" PublicConfig.json
sed -i "s#your_azure_subscription_id#$azure_subscription_id#g" PublicConfig.json

# Set the working subscription ID
az account list -o tsv
read -p 'Type (or copy/paste from above) the subscription ID you wish to use further: ' azure_subscription_id

# Switch to the desired subscription ID
az account set --subscription $azure_subscription_id

# List all Resource Groups
declare -a rgarray="$(az group list  --query '[].name' -o tsv)"

#check if array is empty
if [ -z "$rgarray" ]; then
    echo "No resource group in this subscription: $sID"
	exit
else
	for  i in ${rgarray[@]};  do
	rgName=$i;
	
	# List all VMs for RG $rgName
	declare -a vmarray="$(az vm list -g $rgName --query '[].name' -o tsv)"

	#check if array is empty
	if [ -z "$vmarray" ]; then
			echo "No VM in $rgName" 				
	else							
		for j in ${vmarray[@]}; do
		vmName=$j;	
		
		# Make sure the VM running
		vm_state="$(az vm show -g $rgName -n $vmName -d --query powerState -o tsv)"

		if [[ "$vm_state" != "VM running" ]] ; then
			echo "Starting VM: $vmName "
			az vm start -g $rgName -n $vmName
		else
			echo "VM $vmName is already in running state."	
		fi
				
		# Get the Operating System
		vm_os="$(az vm get-instance-view -g $rgName -n $vmName | grep -i osType| awk -F '"' '{printf $4 "\n"}')"
		
		if [[ "$vm_os" == "Linux" ]] ; then		
					
			# Create an array of installed extensions in the VM
			declare -a installedExt="$(az vm extension list  -g $rgName --vm-name $vmName --query "[].name" -o tsv)"		
			
			# Check if LAD2.0 is installed
			extname=LinuxDiagnostic
			if [[ " ${installedExt[@]} " =~ " $extName " ]]; then
			
			# Check version of it
			ext_vers="$(az vm extension list -g nmjumpboxaz --vm-name $vmName --query "[?contains(name, 'LinuxDiagnostic')].typeHandlerVersion" -o tsv)"
				if [[ "$extversion" < 3 ]] ;
					echo 'LAD 2.0 installed. Uninstalling it and installing LAD 3.0'	
					az vm extension delete --name LinuxDiagnostic -g $rgName --vm-name $vmName
					
					
					# Modify the PublicConfig.json file with the VM details
					sed -i "s#your_resource_group_name#$rgName#g" PublicConfig.json
					sed -i "s#your_vm_name#$vmName#g" PublicConfig.json

					# Install and configure the LAD 3.0 on each VM $vmName
					az vm extension set $rgName $vmName LinuxDiagnostic Microsoft.Azure.Diagnostics '3.*' --private-config-path PrivateConfig.json --public-config-path PublicConfig.json
					
					echo "$extName 3.0 installed on VM $vmName in RG $rgName."
				else
					echo "The extension $extName 3.0 is already installed on the VM $vmName"
				fi 
			else 
				echo "No version of LAD installed on this VM. Installing LAD 3.0"
				az vm extension set $rgName $vmName LinuxDiagnostic Microsoft.Azure.Diagnostics '3.*' --private-config-path PrivateConfig.json --public-config-path PublicConfig.json
			fi
			
		else 			
			echo "$vmName is running Windows. Skipping."
		fi
		done			
	fi
	done  
fi

date +"%F_%R"
exit 0
