<#
.SYNOPSIS 
    Assigns a Static IP Address to an existing virtual machine. 

.DESCRIPTION
    This runbook assigns a static IP Address to an existing virtual machine.
    The runbook accepts virtula machine name, cloud service name and an IP address. It will retrieve the virtual
    machine based on its name and cloud service and update it after assigning the give IP address.

.PARAMETER AzureSubscriptionName
    Name of the Azure subscription to connect to
    
.PARAMETER VMName    
    Name of the virtual machine to whom you want to assign static IP addess.  

.PARAMETER ServiceName
     Name of the Cloud Service that hosts and contains the Virtual machine
 
.PARAMETER StaticIPAddress
    Static IP Address that is assigned to the Virtual machine. This should be a valid IP address within the 
    Network subnet to which the Virtual machine belongs.
    
.PARAMETER AzureCredentials
    A credential containing an Org Id username / password with access to this Azure subscription.

	If invoking this runbook inline from within another runbook, pass a PSCredential for this parameter.

	If starting this runbook using Start-AzureAutomationRunbook, or via the Azure portal UI, pass as a string the
	name of an Azure Automation PSCredential asset instead. Azure Automation will automatically grab the asset with
	that name and pass it into the runbook.

.EXAMPLE
    Set-StaticIPAddress -AzureSubscriptionName "Visual Studio Ultimate with MSDN" -VMName "Sample VM Name" -ServiceName "CloudServiceName" -StaticIPAddress "10.0.0.7" -AzureCredentials $cred

.NOTES
    AUTHOR:Ritesh Modi
    LASTEDIT: March 15, 2015 
    Blog: http://automationnext.wordpress.com
    email: callritz@hotmail.com
#>
workflow Set-StaticIPAddress {
    param
    (
        [parameter(Mandatory=$true)]
        [String]
        $AzureSubscriptionName,
     
        [parameter(Mandatory=$true)]
        [String]
        $VMName,
        
        [parameter(Mandatory=$true)]
        [String]
        $ServiceName,

        [parameter(Mandatory=$true)]
        [String]
        $StaticIPAddress,
                 
        [parameter(Mandatory=$true)]
        [String]
        $AzureCredentials
    )

    # Get the credential to use for Authentication to Azure and Azure Subscription Name 
    $Cred = Get-AutomationPSCredential -Name $AzureCredentials 
     
    # Connect to Azure and Select Azure Subscription 
    $AzureAccount = Add-AzureAccount -Credential $Cred 

    # Connect to Azure and Select Azure Subscription 
    $AzureSubscription = Select-AzureSubscription -SubscriptionName $AzureSubscriptionName 

     # Inline script for assignment of static IP to Virtual machine
     inlinescript {
          # Retrieve VM based on its name and Cloud Service
        $VM = Get-AzureVM -ServiceName $using:ServiceName -Name $using:VMName
            # Virtual machine is found
            if($VM) {
                    try{
                          # Assigning Static IP addess to Virtual Machine  
                          Set-AzureStaticVNetIP -IPAddress $using:StaticIPAddress -VM $VM -erroraction stop | out-null
                            
                         # Updating Virtual Machine to reflect the new static IP address
                          Update-AzureVM -VM $VM.VM -Name $using:VMName -ServiceName $using:ServiceName -erroraction stop | out-null
                          
                           $OutputMessage ="Assigned IP $using:StaticIPAddress to Virtual Machine $using:VMName in Cloud Service $using:ServiceName successfully !!"
                       }
                   catch
                       {
                         $OutputMessage ="Error assigning static IP $using:StaticIPAddress to Virtual Machine $using:VMName in Cloud Service $using:ServiceName successfully !!"
                                      
                       }   
                               
             }  else  { 
                    $OutputMessage = "Virtual Machine $using:VMName in Cloud Service $using:ServiceName could not be retrieved !!" 
                }

            Write-Output "$OutputMessage"
    } 
}




    