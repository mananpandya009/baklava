






'Baklava3.0 - Multipurpose tool'



























































































































#$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($env:USERNAME)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    
   $Host.UI.RawUI.BackgroundColor = "Black"
   $Host.UI.RawUI.ForegroundColor = "Blue"
   clear-host
   }
else
   {
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   $newProcess.Verb = "runas";
   
   [System.Diagnostics.Process]::Start($newProcess);

   
   $Host.UI.RawUI.BackgroundColor = "Black"
   $Host.UI.RawUI.ForegroundColor = "Blue"
   exit
   }


   #Location with path reference for all variables

   $cuser=$env:USERNAME
   $aduser = $cuser + "-admin"
   $profilepath = set-location -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
   $arrayprof = Get-ChildItem $profilepath
   $state1 = "C:\Program Files (x86)\Quarantine\State\*"
   $manifest1 = "C:\Program Files (x86)\Quarantine\Manifests"
   $userprof = "C:\Users"
   $child = Get-ChildItem -Path "C:\Users\*" -Exclude "Public","$cuser","Default","$aduser"

function inspectbakprofiles
{
    param($prof)

    if ("$prof" -match ".*\.bak$") {
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = "Red"
        Write-Output "Found corrupted user profile registries :("
        $temp = "S" + $prof.TrimStart("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList")
        Write-Output($temp)
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = "Gray"
        $arrayprof = Get-ChildItem $profilepath
    }
    else {
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = 'Green'
        Write-Output "Profile registry is healthy!!"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = "Gray"
    }
}

function findbakprofiles
    {
        param($prof)
    
        if ("$prof" -match ".*\.bak$") {
            $Host.UI.RawUI.BackgroundColor = "Black"
       $Host.UI.RawUI.ForegroundColor = 'Red'
            Write-Output "Found corrupted profile registry, removing :)"
            $temp = "S" + $prof.TrimStart("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList")
            Write-Output($temp)
            Remove-Item -path $temp -force -recurse -ErrorAction 'silentlycontinue' #Requires -RunAsAdministrator
            $arrayprof = Get-ChildItem $profilepath
        }
        else {
            $Host.UI.RawUI.BackgroundColor = "Black"
       $Host.UI.RawUI.ForegroundColor = 'Green'
            Write-Output "Profile registry is fixed!!"
            $Host.UI.RawUI.BackgroundColor = "Black"
            $Host.UI.RawUI.ForegroundColor = "Gray"
        }
    }

function wiper {
    param ($_)
    try{
		foreach ($fol in $child) {
			Write-Host "$fol"
			
			$acl = Get-Acl -path $fol
		
		    $object = New-Object System.Security.Principal.Ntaccount("$cuser")
		
		    $acl.SetOwner($object)
		
		    $acl | Set-Acl -path $fol -ErrorAction 'silentlycontinue'
            $Host.UI.RawUI.BackgroundColor = "Black"
            $Host.UI.RawUI.ForegroundColor = "Blue"
            Write-Host "Removing $fol"
        
            remove-item -path "$fol" -force -recurse -ErrorAction 'silentlycontinue' #Requires -RunAsAdministrator
            
		    }
		}
	catch{
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = "Red"
			"Error removing $fol"
		} 
}
   
    



function qstate {
	param ($_)
	Try{
		foreach ($fol in $state1) {
				
			$acl = Get-Acl -path $fol
		
		$object = New-Object System.Security.Principal.Ntaccount("$cuser")
		
		$acl.SetOwner($object)
		
		$acl | Set-Acl -path $fol -ErrorAction 'silentlycontinue'
		
        remove-item -path "$fol" -force  -recurse -ErrorAction 'silentlycontinue' #Requires -RunAsAdministrator       
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = "Green"
        Write-Host "Quarantine 1 successful!"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = "Gray"
        }
    }
        catch{

            $Host.UI.RawUI.BackgroundColor = "Black"
            $Host.UI.RawUI.ForegroundColor = "Red"
			"Error : Quarantine 1" 
        }		
}



function qman {
	param ($_)
	try{
		foreach ($fol in $manifest1) {
			
			$acl = Get-Acl -path $fol
		
		$object = New-Object System.Security.Principal.Ntaccount("$cuser")
		
		$acl.SetOwner($object)
		
		$acl | Set-Acl -path $fol -ErrorAction 'silentlycontinue'
		
        remove-item -path "$fol" -force  -recurse -ErrorAction 'silentlycontinue' #Requires -RunAsAdministrator
        
        }
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = "Green"
        Write-Host "Quarantine 2 successful!"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = "Gray"
		}
		catch{
		
			"Error : Quarantine 2"
		} 
}

function rmprinter {
    param ($_)
    
}

function spoola {
    param ($_)
    $Host.UI.RawUI.ForegroundColor = "Green"
    Write-Host "Clearing and restarting spooler!"
    
    net stop spooler
    cd C:\Windows\System32\spool\PRINTERS
    del C:\Windows\System32\spool\PRINTERS\* 
    
    net start spooler
}

function printa {
    param ($_)
    $j=0
                $localprinter=Get-Printer
                $i=0
                $printer = Read-Host -Prompt 'Please enter printer name'   
                $uprinter = $printer.ToUpper()
             if (($uprinter -match "^lga9") -or ($uprinter -match "^ewr9") -or ($uprinter -match "^ewr4") -or ($uprinter -match "^ewr8") -or ($uprinter -match "^ewr6") -or ($uprinter -match "^jfk8") -or ($uprinter -match "^bdl3")){
                
                   foreach ($pr in $localprinter) {
                      $pr = $localprinter.Name[$i]
                      $temp=$pr.TrimStart("\\wcpm-print-lb.amazon.com\")
                      if ($uprinter -match $temp) {
                        $j=$j+1
                      }
                      $i = $i + 1
                  
                   }
                if ($j -eq 1) {
                   Write-host "$uprinter already exists"
                }
                else {
                   rundll32 printui.dll PrintUIEntry /in /n \\wcpm-print-lb.amazon.com\$uprinter
                   $Host.UI.RawUI.ForegroundColor = "Green"
                   Write-Output "$uprinter added successfully!!"
                   $Host.UI.RawUI.BackgroundColor = "Black"
                   $Host.UI.RawUI.ForegroundColor = "Gray"

                }             
             
             }
             else {
                $Host.UI.RawUI.ForegroundColor = "Red"
                Write-Output "Please enter a valid printer name."
                $Host.UI.RawUI.BackgroundColor = "Black"
                $Host.UI.RawUI.ForegroundColor = "Gray"
             } 
}

function Show-Menu
{
     param (
           [string]$Title = 'My Menu'
     )
     Clear-Host

Write-Output "`n"
     $Host.UI.RawUI.BackgroundColor = "Black"
     $Host.UI.RawUI.ForegroundColor = "Red"
   "-------------------------------------"
   "| Baklava - Fixes corrupted registry|"
   $Host.UI.RawUI.BackgroundColor = "Black"
   $Host.UI.RawUI.ForegroundColor = "White"
   "| Creator:  Manan Pandya            |"
   $Host.UI.RawUI.BackgroundColor = "Black"
   $Host.UI.RawUI.ForegroundColor = "Blue"
   "| Email:    panmanan@amazon.com     |"
   "-------------------------------------"
     Write-Output "`n"
     $Host.UI.RawUI.BackgroundColor = "Black"
     $Host.UI.RawUI.ForegroundColor = "Yellow"
     Write-Output "Hello $env:USERNAME, please select an option and hit enter:"
     Write-Output "`n"
     $Host.UI.RawUI.ForegroundColor = 'White'
     Write-Output "(1)Inspect user profile registries"
     Write-Output "(2)Fix the corrupted registries"
     Write-Output "(3)Free up space"
     Write-Output "(4)Fix quarantine issues"
     Write-Output "(5)Connect to a printer"
     Write-Output "(6)Reset printer spooler"
     Write-Output "(7)Rejoin ANT domain"
     Write-Output "(Q)To Quit"
}
do
{
     Show-Menu
     $input = Read-Host "Option"
     
     switch ($input)
     {
           '1' {
               $i=0
               foreach ($prof in $arrayprof)
               {
                    $prof = $arrayprof[$i].Name
                    inspectbakprofiles($prof)
                    $i = $i+1
               }
               $Host.UI.RawUI.BackgroundColor = "Black"
               $Host.UI.RawUI.ForegroundColor = "Red"
               "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
               "'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''.-::///:-.'''''''''''''''''''''''''"
               "'''''''''''''''''''''''''-+/.'''''''''''''''''''''''''''''''''''''''''''''''''''-+ooooooossss'''''''''''''''''''''''''"
               "''''''''''''''''''''''''''':os+/-''''''''''''''''''''''''''''''''''''''''''''''''''''''''.sso'''''''''''''''''''''''''"
               $Host.UI.RawUI.BackgroundColor = "Black"
               $Host.UI.RawUI.ForegroundColor = "White"
               "'''''''''''''''''''''''''''''./ssso+:-.''''''''''''''''''''''''''''''''''''''''''.:/oso'':ss-'''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''-/ossssso+/:-.'''''''''''''''''''''''''''..-:/+sssso/.'''ss/''''''''''''''''''''''''''"
               "'''''''''''''''''''''''''''''''''''.:/osssssssssoo++///:::::::::://++oosssssssso+:.'''''+s:'''''''''''''''''''''''''''"
               $Host.UI.RawUI.BackgroundColor = "Black"
               $Host.UI.RawUI.ForegroundColor = "Blue"
               "''''''''''''''''''''''''''''''''''''''''-:+osssssssssssssssssssssssssssssso+:-'''''''''./.''''''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''''''''''''''''.-:/++oossssssssssoo++/:-.''''''''''''''''''''''''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
               $Host.UI.RawUI.ForegroundColor = "Gray"
           } '2' {
               $j=0
               foreach ($prof in $arrayprof)
               {
                    $prof = $arrayprof[$j].Name
                    findbakprofiles($prof)
                    $j = $j+1
               }
               $Host.UI.RawUI.BackgroundColor = "Black"
               $Host.UI.RawUI.ForegroundColor = "Red"
               "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
               "'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''.-::///:-.'''''''''''''''''''''''''"
               "'''''''''''''''''''''''''-+/.'''''''''''''''''''''''''''''''''''''''''''''''''''-+ooooooossss'''''''''''''''''''''''''"
               "''''''''''''''''''''''''''':os+/-''''''''''''''''''''''''''''''''''''''''''''''''''''''''.sso'''''''''''''''''''''''''"
               $Host.UI.RawUI.BackgroundColor = "Black"
               $Host.UI.RawUI.ForegroundColor = "White"
               "'''''''''''''''''''''''''''''./ssso+:-.''''''''''''''''''''''''''''''''''''''''''.:/oso'':ss-'''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''-/ossssso+/:-.'''''''''''''''''''''''''''..-:/+sssso/.'''ss/''''''''''''''''''''''''''"
               "'''''''''''''''''''''''''''''''''''.:/osssssssssoo++///:::::::::://++oosssssssso+:.'''''+s:'''''''''''''''''''''''''''"
               $Host.UI.RawUI.BackgroundColor = "Black"
               $Host.UI.RawUI.ForegroundColor = "Blue"
               "''''''''''''''''''''''''''''''''''''''''-:+osssssssssssssssssssssssssssssso+:-'''''''''./.''''''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''''''''''''''''.-:/++oossssssssssoo++/:-.''''''''''''''''''''''''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
               $Host.UI.RawUI.ForegroundColor = "Gray"
           } '3' {
               wiper($_)
               $Host.UI.RawUI.BackgroundColor = "Black"
               $Host.UI.RawUI.ForegroundColor = "Red"
               "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
               "'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''.-::///:-.'''''''''''''''''''''''''"
               "'''''''''''''''''''''''''-+/.'''''''''''''''''''''''''''''''''''''''''''''''''''-+ooooooossss'''''''''''''''''''''''''"
               "''''''''''''''''''''''''''':os+/-''''''''''''''''''''''''''''''''''''''''''''''''''''''''.sso'''''''''''''''''''''''''"
               $Host.UI.RawUI.BackgroundColor = "Black"
               $Host.UI.RawUI.ForegroundColor = "White"
               "'''''''''''''''''''''''''''''./ssso+:-.''''''''''''''''''''''''''''''''''''''''''.:/oso'':ss-'''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''-/ossssso+/:-.'''''''''''''''''''''''''''..-:/+sssso/.'''ss/''''''''''''''''''''''''''"
               "'''''''''''''''''''''''''''''''''''.:/osssssssssoo++///:::::::::://++oosssssssso+:.'''''+s:'''''''''''''''''''''''''''"
               $Host.UI.RawUI.BackgroundColor = "Black"
               $Host.UI.RawUI.ForegroundColor = "Blue"
               "''''''''''''''''''''''''''''''''''''''''-:+osssssssssssssssssssssssssssssso+:-'''''''''./.''''''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''''''''''''''''.-:/++oossssssssssoo++/:-.''''''''''''''''''''''''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
               $Host.UI.RawUI.ForegroundColor = "Gray"
           } 
           '4' {
   
                    qstate($_)
                    qman($_)
                    Write-host "Running update check on policies"
                    gpupdate /force
                    $inpu = Read-Host "Would you like to reboot system(recommended)? - Y/N"
                    if ($inpu -match "Y") {
                        shutdown -r -f -t 3
                    }
                    else {
                       Write-host "Loading main menu..."
                   }
        }  
             '5' {
               printa($_)
               $Host.UI.RawUI.BackgroundColor = "Black"
               $Host.UI.RawUI.ForegroundColor = "Red"
               "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
               "'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''.-::///:-.'''''''''''''''''''''''''"
               "'''''''''''''''''''''''''-+/.'''''''''''''''''''''''''''''''''''''''''''''''''''-+ooooooossss'''''''''''''''''''''''''"
               "''''''''''''''''''''''''''':os+/-''''''''''''''''''''''''''''''''''''''''''''''''''''''''.sso'''''''''''''''''''''''''"
               $Host.UI.RawUI.BackgroundColor = "Black"
               $Host.UI.RawUI.ForegroundColor = "White"
               "'''''''''''''''''''''''''''''./ssso+:-.''''''''''''''''''''''''''''''''''''''''''.:/oso'':ss-'''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''-/ossssso+/:-.'''''''''''''''''''''''''''..-:/+sssso/.'''ss/''''''''''''''''''''''''''"
               "'''''''''''''''''''''''''''''''''''.:/osssssssssoo++///:::::::::://++oosssssssso+:.'''''+s:'''''''''''''''''''''''''''"
               $Host.UI.RawUI.BackgroundColor = "Black"
               $Host.UI.RawUI.ForegroundColor = "Blue"
               "''''''''''''''''''''''''''''''''''''''''-:+osssssssssssssssssssssssssssssso+:-'''''''''./.''''''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''''''''''''''''.-:/++oossssssssssoo++/:-.''''''''''''''''''''''''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
               "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
               $Host.UI.RawUI.ForegroundColor = "Gray"
          }
          '6' {
            spoola($_)
            $Host.UI.RawUI.BackgroundColor = "Black"
            $Host.UI.RawUI.ForegroundColor = "Red"
            "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
            "'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''.-::///:-.'''''''''''''''''''''''''"
            "'''''''''''''''''''''''''-+/.'''''''''''''''''''''''''''''''''''''''''''''''''''-+ooooooossss'''''''''''''''''''''''''"
            "''''''''''''''''''''''''''':os+/-''''''''''''''''''''''''''''''''''''''''''''''''''''''''.sso'''''''''''''''''''''''''"
            $Host.UI.RawUI.BackgroundColor = "Black"
            $Host.UI.RawUI.ForegroundColor = "White"
            "'''''''''''''''''''''''''''''./ssso+:-.''''''''''''''''''''''''''''''''''''''''''.:/oso'':ss-'''''''''''''''''''''''''"
            "''''''''''''''''''''''''''''''''-/ossssso+/:-.'''''''''''''''''''''''''''..-:/+sssso/.'''ss/''''''''''''''''''''''''''"
            "'''''''''''''''''''''''''''''''''''.:/osssssssssoo++///:::::::::://++oosssssssso+:.'''''+s:'''''''''''''''''''''''''''"
            $Host.UI.RawUI.BackgroundColor = "Black"
            $Host.UI.RawUI.ForegroundColor = "Blue"
            "''''''''''''''''''''''''''''''''''''''''-:+osssssssssssssssssssssssssssssso+:-'''''''''./.''''''''''''''''''''''''''''"
            "''''''''''''''''''''''''''''''''''''''''''''''.-:/++oossssssssssoo++/:-.''''''''''''''''''''''''''''''''''''''''''''''"
            "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
            "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
            $Host.UI.RawUI.ForegroundColor = "Gray"
        } 
        '7' {
            try {
                Write-Host "Please enter your admin credentials"
                $PSCredential = Get-Credential | Out-Null
                Reset-ComputerMachinePassword -Server ant.amazon.com -Credential $PSCredential
                Write-Host "Successfully joined ANT.amazon.com"
                $inpu = Read-Host "Would you like to reboot system(recommended)? - Y/N"
                if ($inpu -match "Y") {
                    shutdown -r -f -t 3
                }
                else {
                   Write-host "Loading main menu..."
                   $Host.UI.RawUI.BackgroundColor = "Black"
                   $Host.UI.RawUI.ForegroundColor = "Red"
                   "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
                   "'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''.-::///:-.'''''''''''''''''''''''''"
                   "'''''''''''''''''''''''''-+/.'''''''''''''''''''''''''''''''''''''''''''''''''''-+ooooooossss'''''''''''''''''''''''''"
                   "''''''''''''''''''''''''''':os+/-''''''''''''''''''''''''''''''''''''''''''''''''''''''''.sso'''''''''''''''''''''''''"
                   $Host.UI.RawUI.BackgroundColor = "Black"
                   $Host.UI.RawUI.ForegroundColor = "White"
                   "'''''''''''''''''''''''''''''./ssso+:-.''''''''''''''''''''''''''''''''''''''''''.:/oso'':ss-'''''''''''''''''''''''''"
                   "''''''''''''''''''''''''''''''''-/ossssso+/:-.'''''''''''''''''''''''''''..-:/+sssso/.'''ss/''''''''''''''''''''''''''"
                   "'''''''''''''''''''''''''''''''''''.:/osssssssssoo++///:::::::::://++oosssssssso+:.'''''+s:'''''''''''''''''''''''''''"
                   $Host.UI.RawUI.BackgroundColor = "Black"
                   $Host.UI.RawUI.ForegroundColor = "Blue"
                   "''''''''''''''''''''''''''''''''''''''''-:+osssssssssssssssssssssssssssssso+:-'''''''''./.''''''''''''''''''''''''''''"
                   "''''''''''''''''''''''''''''''''''''''''''''''.-:/++oossssssssssoo++/:-.''''''''''''''''''''''''''''''''''''''''''''''"
                   "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
                   "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
                   $Host.UI.RawUI.ForegroundColor = "Gray"
               } 
            }
            catch {
                Write-Host "Error joining ANT,please return to menu"
                $Host.UI.RawUI.BackgroundColor = "Black"
                $Host.UI.RawUI.ForegroundColor = "Red"
                "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
                "'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''.-::///:-.'''''''''''''''''''''''''"
                "'''''''''''''''''''''''''-+/.'''''''''''''''''''''''''''''''''''''''''''''''''''-+ooooooossss'''''''''''''''''''''''''"
                "''''''''''''''''''''''''''':os+/-''''''''''''''''''''''''''''''''''''''''''''''''''''''''.sso'''''''''''''''''''''''''"
                $Host.UI.RawUI.BackgroundColor = "Black"
                $Host.UI.RawUI.ForegroundColor = "White"
                "'''''''''''''''''''''''''''''./ssso+:-.''''''''''''''''''''''''''''''''''''''''''.:/oso'':ss-'''''''''''''''''''''''''"
                "''''''''''''''''''''''''''''''''-/ossssso+/:-.'''''''''''''''''''''''''''..-:/+sssso/.'''ss/''''''''''''''''''''''''''"
                "'''''''''''''''''''''''''''''''''''.:/osssssssssoo++///:::::::::://++oosssssssso+:.'''''+s:'''''''''''''''''''''''''''"
                $Host.UI.RawUI.BackgroundColor = "Black"
                $Host.UI.RawUI.ForegroundColor = "Blue"
                "''''''''''''''''''''''''''''''''''''''''-:+osssssssssssssssssssssssssssssso+:-'''''''''./.''''''''''''''''''''''''''''"
                "''''''''''''''''''''''''''''''''''''''''''''''.-:/++oossssssssssoo++/:-.''''''''''''''''''''''''''''''''''''''''''''''"
                "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
                "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
                $Host.UI.RawUI.ForegroundColor = "Gray"
            }
         
        }

          'q' {
               return
           }
     }
     pause
}
until ($input -eq 'q')
