

    
        #Enter your vCenter server names here:
        $vCenters = @(
            "BMOMNVCENTER01.jkhy.com"
            "MMOCOVC01.jhacorp.com"
            "MMOMNVC01.jkhy.com"
            "ATXMNVC01.jkhy.com"
            "LKSMNVC01.jkhy.com"
            "SMOMNVC01.jkhy.com"
            "mmomncorevc01.jkhy.com"
        )
	# enter your server name, without the domain
	$VM = Read-Host "Identify Waldo, please"	
		
	Import-Module INF-PSModule  
        
        ForEach ($vCenter in $vCenters)
        {
            Write-Host "Looking for $VM"
            Write-Host "Checking $vCenter..."
            Write-Host "Connecting to $vCenter..."
            $Connect = Connect-VIServer $vCenter 3> $null -ErrorAction SilentlyContinue
            $VMObjs = Get-VM $VM -ErrorAction SilentlyContinue
            ForEach ($VMObj in $VMObjs)
            {
                [PSCustomObject]@{
                    Name = $VMObj.Name
                    GuestOS = $VMObj.ExtensionData.Guest.GuestFullName
                    VCenter = $vCenter
                    DataCenter = $VMObj | Get-DataCenter | Select -ExpandProperty Name
                    Cluster = $VMObj | Get-VMHost | Get-Cluster | Select -ExpandProperty Name
                    Host = $VMObj | Get-VMHost | Select -ExpandProperty Name
                }
            }
            Disconnect-VIServer $vCenter -Confirm:$false
        }
        
    

