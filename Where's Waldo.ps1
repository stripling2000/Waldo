###################################################
## Necessary stuff to make the menu magic happen ##
###################################################
$menu=@"
1 Find vCenter in which a Virtual Server resides
2 Retrieve Disk info for Virtual team
3 Open vCenter web client
Q Quit
 
Select a task by number or Q to quit
"@

# create function to make the menu work
Function Invoke-Menu {
[cmdletbinding()]
Param(
[Parameter(Position=0,Mandatory=$True,HelpMessage="Enter your menu text")]
[ValidateNotNullOrEmpty()]
[string]$Menu,
[Parameter(Position=1)]
[ValidateNotNullOrEmpty()]
[string]$Title = "My Menu",
[Alias("cls")]
[switch]$ClearScreen
)
 
#clear the screen if requested
if ($ClearScreen) { 
 Clear-Host 
}
 
#build the menu prompt
$menuPrompt = $title
#add a return
$menuprompt+="`n"
#add an underline
$menuprompt+="-"*$title.Length
#add another return
$menuprompt+="`n"
#add the menu
$menuPrompt+=$menu
 
Read-Host -Prompt $menuprompt
 
} #end function

###########################
## End of the menu magic ##
###########################

## List all the vCenter servers here
$vCenters = @(
			"MMOCOVC01.jhacorp.com"
			"MMOMNVC01.jkhy.com"
			)

Do {
    #use a Switch construct to take action depending on what menu choice is selected.
    Switch (Invoke-Menu -menu $menu -title "My Help Desk Tasks") {
     "1" {Write-Host "Searching vCenters..." -ForegroundColor Yellow
				#Enter your vCenter server names here:
				
					# enter your server name, without the domain
					$VM = Read-Host "Enter the Virtual Server name, without the domain"	
		
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
							if ($VMObjs -ne "$null") {break}
						}
		 sleep -seconds 2
         } 
     "2" {Write-Host "Retrieving Disk info for Virtual team" -ForegroundColor Green
          $Connect = Connect-VIServer $vCenter 3> $null -ErrorAction SilentlyContinue
          Write-Host "Retrieving $VM disk information"
          INF-Get-VM-Disk-Info -Name $VM
          sleep -seconds 2
          }
     "3" {Write-Host "This functionality is still being developed" -ForegroundColor Magenta
         sleep -seconds 1
         }
     "Q" {Write-Host "Goodbye" -ForegroundColor Cyan
         Return
         }
     Default {Write-Warning "Invalid Choice. Try again."
              sleep -milliseconds 750}
    } #switch
} While ($True)