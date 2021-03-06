# File Monitor for Creation RANSOMWARE 
# Check if new ransomware is infecting our system, check docx docs. 
# If detect new ransomware, or one of blacklist, then disable de account of the user to 
# block any access to our system.
# Author : Amador Pérez Trujillo aka @c0p3rn1c0
# 2016

#TO_DO: Disable network adapter after ransomware detected
#       Multiple paths for monitor
#       Disable USB hdd
#       Change buffer size 4k 48
#       Creation different extension in spite of .docx _AntiRansomware
# NEXT VERSION:
#       Show message DANGER on client..........................DONE!
#       SNMP to server to log on siem
#       Detect filetype not based on extension 
#       Convert to service

$folder_tolog = ""

if ($args.Count -ne 1) {
    #help
    Clear-Host
    Write-Host "
 _____    ______       ____     ________    _____    _____      __      _        
(  __ \  (   __ \     / __ \   (___  ___)  / ___/   (_   _)    /  \    / )     
 ) )_) )  ) (__) )   / /  \ \      ) )    ( (__       | |     / /\ \  / /   
(  ___/  (    __/   ( ()  () )    ( (      ) __)      | |     ) ) ) ) ) )  
 ) )      ) \ \  _  ( ()  () )     ) )    ( (         | |    ( ( ( ( ( (       
( (      ( ( \ \_))  \ \__/ /     ( (      \ \___    _| |__  / /  \ \/ /             
/__\      )_) \__/    \____/      /__\      \____\  /_____( (_/    \__/                                                           
                                                                     
"

    Write-Host "PROTEcting your INformation - AntiRansomware"
    Write-Host "____________________________________________"
 
    Write-Host " "
    Write-Host " "
    Write-Host ".SYNOPSIS"
	Write-Host " - This script is an actively monitoring for files in a repository to search for known or unknown ransomware."
	Write-Host " - PROTEIN captures the action of creation new files, analyzing them and determining whether they are valid or not for the corporation."
    Write-Host " - PROTEIN Identifies known files (whitelist), potential threats (blacklist) likewise unknown files for further processing."
	Write-Host ""
    Write-Host " - PROTEIN logs every creation action on files on your server."
	Write-Host " - Possibility to email alerts to an administrator when a new ransomware is detected."
    Write-Host " - PROTEIN alerts, via messagebox on the user's computer, when a new ransomware is detected."
    Write-Host " - PROTEIN disables domain's user affected by the ransomware, preventing the access to the repository by the ransomware or other critical system objects."
    Write-Host " - PROTEIN disables the NIC on the user's computer affected by the ransomware, to block the access to the network."
    Write-Host " "
    Write-Host ".REQUIREMENTS"
    Write-Host " - Run this script as an administrator to control computers and domain users remotely."
    Write-Host " "
    Write-Host " .INSTALATION"
    Write-Host " - ./protein.ps1 --install"
    Write-Host " - ./protein.ps1 --configure"

	Write-Host ""
    Write-Host ".NOTES"
	Write-Host " - Author		: Amador Pérez Trujillo"
	Write-Host " - Twitter		: @c0p3rnic0"
	Write-Host " - Company		: http://www.newvisionsoftlan.com"
	Write-Host ""
	
    Write-Host ".PARAMETER --install"
	Write-Host " - Set the path to folder to monitor, path and filename for storage logs and email of the adminsitrator to alert of a risk."
    Write-Host ".PARAMETER --monitor"
    Write-Host " - Start monitoring the Folders... Start the Game!!!"
    Write-Host ".PARAMETER --configure"
    Write-Host " - Re-configure path of folders to monitor and storage the logs, email address..."
    Write-Host ".PARAMETER --path"
    Write-Host " - Echo by console the configuration files for checking purposing."
    Write-Host ".PARAMETER --logs"
    Write-Host " - Echo by console the log file."
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Break
}

if ($args -eq "--install")
{
    Clear-Host 
    Write-Host "
 _____    ______       ____     ________    _____    _____      __      _        
(  __ \  (   __ \     / __ \   (___  ___)  / ___/   (_   _)    /  \    / )     
 ) )_) )  ) (__) )   / /  \ \      ) )    ( (__       | |     / /\ \  / /   
(  ___/  (    __/   ( ()  () )    ( (      ) __)      | |     ) ) ) ) ) )  
 ) )      ) \ \  _  ( ()  () )     ) )    ( (         | |    ( ( ( ( ( (       
( (      ( ( \ \_))  \ \__/ /     ( (      \ \___    _| |__  / /  \ \/ /             
/__\      )_) \__/    \____/      /__\      \____\  /_____( (_/    \__/                                                           
                                                                     
"

    Write-Host "PROTEcting your INformation - AntiRansomware"
    Write-Host "____________________________________________"
    Write-Host " "
    Write-Host " "
    Write-Host "INTALATION:"
    Write-Host "==========="
    $question = Read-Host -Prompt 'Do you really want to install the application (Y/N)?'
    $question.ToUpper()
    $first_time = 0 #Create file of dir only 1 time
    if ($question -eq "Y" ) {
        Write-Host "Path to File Server Folder to monitor?"
        
	    $object = New-Object -comObject Shell.Application  
     
        $folder = $object.BrowseForFolder(0, "Path to File Server Folder to monitor", 0, 0) 
 
        $folder_toinstall = $folder.self.Path 

        
        if ($folder_toinstall.length -gt 3) {
            Write-Host "d3"
            $folder_toinstall.ToUpper()
            $folder_toinstall += "\_AntiRansomware"
            New-Item -ItemType Directory -Force -Path $folder_toinstall
            Copy-Item "C:\Anti_malware_config\docs\_1.docx" $folder_toinstall
            Copy-Item "C:\Anti_malware_config\docs\_2.docx" $folder_toinstall
            Copy-Item "C:\Anti_malware_config\docs\_3.docx" $folder_toinstall
            $question = Read-Host -Prompt 'Add another folder(Y/N)?'
            $question.ToUpper()
            $config_file = "C:\Anti_malware_config\fake_dirs.config"
            if ($first_time -eq 0) { #Check if file is created or not
                New-Item  $config_file -type file -force
                Add-Content -Path $config_file -Value $folder_toinstall
                $first_time = 1
            }
            else 
            {
                Add-Content -Path $config_file -Value $folder_toinstall
            }
        }
        else {
            $question = "N"
            Write-Host "d4"
        }
    }
}

if ($args -eq "--logs")
{
    $lines_config = Get-Content C:\Anti_malware_config\setup.config

    $next = "0"
    foreach ($line_data in $lines_config) {
        if ($line_data -notlike '*#*') {
        #Isn't a comment
        
            switch ($next) 
            {
                "folder"    {
                            $folder = $line_data
                            $next = "null"
                            }
                "logs"      {
                            $folder_logs = $line_data + "\config_changes.txt"
                            $next = "null"
                            }
                "from"      {
                            $FROM = $line_data
                            $next = "null"
                            }
                "email"     {
                            $To = $line_data
                            $next = "null"
                            }
                "server"    {
                            $smtp = $line_data
                            $next = "null"
                            }
           
            }
            if ($line_data -like '%Path_Repository*') {  # Enter the root path you want to monitor. 
                $next = "folder"
            }
            if ($line_data -like '%Path_File*'){  # Enter the  path you want to storage logs. 
                $next = "logs"
            }
            if ($line_data -like '%To*') {  # Enter the  path you want to storage logs. 
                $next = "email"
            }

            if ($line_data -like '%Smtp*') {  # Enter the  path you want to storage logs. 
                $next = "server"
            }
            if ($line_data -like '%From*') {  # Enter the  path you want to storage logs. 
                $next = "from"
            }
        
        }
    }
    Clear-Host 
    Write-Host "
 _____    ______       ____     ________    _____    _____      __      _        
(  __ \  (   __ \     / __ \   (___  ___)  / ___/   (_   _)    /  \    / )     
 ) )_) )  ) (__) )   / /  \ \      ) )    ( (__       | |     / /\ \  / /   
(  ___/  (    __/   ( ()  () )    ( (      ) __)      | |     ) ) ) ) ) )  
 ) )      ) \ \  _  ( ()  () )     ) )    ( (         | |    ( ( ( ( ( (       
( (      ( ( \ \_))  \ \__/ /     ( (      \ \___    _| |__  / /  \ \/ /             
/__\      )_) \__/    \____/      /__\      \____\  /_____( (_/    \__/                                                           
                                                                     
"
    
    Write-Host "PROTEcting your INformation - AntiRansomware"
    Write-Host "____________________________________________"
    Write-Host " "
    Write-Host " "
    Write-Host "LOGS:"
    Write-Host "====="
    $lines_config = Get-Content $folder_logs 
    
    foreach ($line in $lines_config)
    {
        write-host $line
    }
}


if ($args -eq "--path")
{
    Clear-Host 
    Write-Host "
 _____    ______       ____     ________    _____    _____      __      _        
(  __ \  (   __ \     / __ \   (___  ___)  / ___/   (_   _)    /  \    / )     
 ) )_) )  ) (__) )   / /  \ \      ) )    ( (__       | |     / /\ \  / /   
(  ___/  (    __/   ( ()  () )    ( (      ) __)      | |     ) ) ) ) ) )  
 ) )      ) \ \  _  ( ()  () )     ) )    ( (         | |    ( ( ( ( ( (       
( (      ( ( \ \_))  \ \__/ /     ( (      \ \___    _| |__  / /  \ \/ /             
/__\      )_) \__/    \____/      /__\      \____\  /_____( (_/    \__/                                                           
                                                                     
"
    
    Write-Host "PROTEcting your INformation - AntiRansomware"
    Write-Host "____________________________________________"
    Write-Host " "
    Write-Host " "
    Write-Host "SETUP CONFIGURATION:"
    Write-Host "===================="
    $lines_config = Get-Content C:\Anti_malware_config\setup.config
    foreach ($line in $lines_config)
    {
        write-host $line
    }
    Write-Host "FOLDERS CONFIGURATION:"
    Write-Host "===================="
    $lines_config = Get-Content C:\Anti_malware_config\folder_config.config
    foreach ($line in $lines_config)
    {
        write-host $line
    }
    Write-Host""
    #Pause
    Break
   
}


if ($args -eq "--configure")
{
    Clear-Host 
    Write-Host "
 _____    ______       ____     ________    _____    _____      __      _        
(  __ \  (   __ \     / __ \   (___  ___)  / ___/   (_   _)    /  \    / )     
 ) )_) )  ) (__) )   / /  \ \      ) )    ( (__       | |     / /\ \  / /   
(  ___/  (    __/   ( ()  () )    ( (      ) __)      | |     ) ) ) ) ) )  
 ) )      ) \ \  _  ( ()  () )     ) )    ( (         | |    ( ( ( ( ( (       
( (      ( ( \ \_))  \ \__/ /     ( (      \ \___    _| |__  / /  \ \/ /             
/__\      )_) \__/    \____/      /__\      \____\  /_____( (_/    \__/                                                           
                                                                     
"

    Write-Host "PROTEcting your INformation - AntiRansomware"
    Write-Host "____________________________________________"
    Write-Host " "
    Write-Host " "
    Write-Host "SETUP CONFIGURATION:"
    Write-Host "===================="
    $question = Read-Host -Prompt 'Do you really want to re-configure the paths for the application (Y/N)?'
    $question.ToUpper()
    if ($question -eq "Y" ) {

        $object = New-Object -comObject Shell.Application  
     
        $folder = $object.BrowseForFolder(0, "Path to File Server Folder to monitor", 0, 0) 
 
        $folder_toinstall = $folder.self.Path

        if ($folder_toinstall.length -gt 3) {$folder_toinstall.ToUpper()}

        Write-Host "Path to File Server Activity Log?"
        $object = New-Object -comObject Shell.Application  
     
        $folder = $object.BrowseForFolder(0, "Path to File Server Folder to monitor", 0, 0) 
 
        $folder_logs = $folder.self.Path

        if ($folder_logs.length -gt 3) {$folder_logs.ToUpper()}

        $FROM = Read-Host -Prompt "Email address (From:) for alerts?"
        if ($FROM.length -gt 3) {$FROM.ToUpper()}
        $To = Read-Host -Prompt "Email address (To:) for alerts?"
        if ($To.length -gt 3) {$To.ToUpper()}
        
        $smtp = Read-Host -Prompt "SMTP Server for alerts?"
        if ($smtp.length -gt 3) {$smtp.ToUpper()}

        # Make Config file
        $config_file = "C:\Anti_malware_config\fake_dirs.config"
        New-Item  $config_file -type file -force
        $fake_foldertoinstall = $folder_toinstall+ "\_AntiRansomware"
        Add-Content -Path $config_file -Value $fake_foldertoinstall
        
        $config_file = "C:\Anti_malware_config\setup.config"
        New-Item  $config_file -type file -force
        Add-Content -Path $config_file -Value "# You need to specify Path (Root path...) to active monitoring for File Server"
        Add-Content -Path $config_file -Value "# And Path where store a log file for this monitoring."
        Add-Content -Path $config_file -Value ""
        Add-Content -Path $config_file -Value "%Path_Repository_to_Check:"
        Add-Content -Path $config_file -Value $folder_toinstall
        Add-Content -Path $config_file -Value ""
        Add-Content -Path $config_file -Value "%Path_File_Server_Activity_Log:"
        Add-Content -Path $config_file -Value $folder_logs
        Add-Content -Path $config_file -Value ""
        Add-Content -Path $config_file -Value "#Email_account"
        Add-Content -Path $config_file -Value "%From:"
        Add-Content -Path $config_file -Value $FROM
        Add-Content -Path $config_file -Value "%To:"
        Add-Content -Path $config_file -Value $To
        Add-Content -Path $config_file -Value "%Smtp_Server:"
        Add-Content -Path $config_file -Value $SMTP

    }
}


if ($args -eq "--monitor")
{ # ARGS PASSED. START!!!!

    Clear-Host 
    Try
    {
        Unregister-Event AntiRansomware 
    }
    Catch
    {
        Clear-Host 
    }

#Start Reading file configuration setup.config 
    Write-Host "Loading configuration file..." -foregroundcolor red -backgroundcolor white
    Write-Host "" 
    Write-Host ""
    Write-Host ""

    $lines_config = Get-Content C:\Anti_malware_config\setup.config

    $next = "0"
    foreach ($line_data in $lines_config) {
        if ($line_data -notlike '*#*') {
        #Isn't a comment
        
            switch ($next) 
            {
                "folder"    {
                            $folder = $line_data
                            $next = "null"
                            }
                "logs"      {
                            $folder_tolog = $line_data + "\config_changes.txt"
                            $next = "null"
                            }
                "from"      {
                            $FROM = $line_data
                            $next = "null"
                            }
                "email"     {
                            $To = $line_data
                            $next = "null"
                            }
                "server"    {
                            $smtp = $line_data
                            $next = "null"
                            }
           
            }
            if ($line_data -like '%Path_Repository*') {  # Enter the root path you want to monitor. 
                $next = "folder"
            }
            if ($line_data -like '%Path_File*'){  # Enter the  path you want to storage logs. 
                $next = "logs"
            }
            if ($line_data -like '%To*') {  # Enter the  path you want to storage logs. 
                $next = "email"
            }

            if ($line_data -like '%Smtp*') {  # Enter the  path you want to storage logs. 
                $next = "server"
            }
            if ($line_data -like '%From*') {  # Enter the  path you want to storage logs. 
                $next = "from"
            }
        
        }
    }
    Write-Host "Loaded... Checking Configuration..." -foregroundcolor red -backgroundcolor white
    # Check parameters

# Check that all variables have values 
    if ( ($folder) -and ($folder_tolog) -and ($To)  -and ($smtp) ) {

        
        $whitelist = Get-Content -Path C:\Anti_malware_config\white_list.config
        $blacklist = Get-Content -Path C:\Anti_malware_config\ransomware_list.config
        $fake_dirs = Get-Content -Path C:\Anti_malware_config\Fake_dirs.config
    
       
        $filter = '*.*' # You can enter a wildcard filter here.

# In the following line, you can change 'IncludeSubdirectories to $true if required. 
        $fsw = New-Object IO.FileSystemWatcher $folder, $filter -Property @{IncludeSubdirectories = $true;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'}

################################################################################################################################
#                                                                                                                              #
#                                                 REGISTER_EVENTS_TO_MONITOR                                                   # 
#                                                                                                                              #
################################################################################################################################        
        
        
        Register-ObjectEvent $fsw Created -SourceIdentifier AntiRansomware -Action {

            $whitelist = Get-Content -Path C:\Anti_malware_config\white_list.config
            $blacklist = Get-Content -Path C:\Anti_malware_config\ransomware_list.config
            $fake_dirs = Get-Content -Path C:\Anti_malware_config\Fake_dirs.config
            $lines_config = Get-Content C:\Anti_malware_config\setup.config
            
            ####################
            #LOAD CONFIGURATION#
            ####################

            $next = "0"
            foreach ($line_data in $lines_config) {
                if ($line_data -notlike '*#*') {      
                    switch ($next) 
                    {
                        "folder"    {
                                    $folder = $line_data
                                    $next = "null"
                                    }
                        "logs"      {
                                    $folder_tolog = $line_data + "\config_changes.txt"
                                    $next = "null"
                                    }
                        "from"      {
                                    $FROM = $line_data
                                    $next = "null"
                                    }
                        "email"     {
                                    $To = $line_data
                                    $next = "null"
                                    }
                        "server"    {
                                    $smtp = $line_data
                                    $next = "null"
                                    }
           
                    }
                    if ($line_data -like '%Path_Repository*') {  # Enter the root path you want to monitor. 
                        $next = "folder"
                    }
                    if ($line_data -like '%Path_File*'){  # Enter the  path you want to storage logs. 
                        $next = "logs"
                    }
                    if ($line_data -like '%To*') {  # Enter the  path you want to storage logs. 
                        $next = "email"
                    }

                    if ($line_data -like '%Smtp*') {  # Enter the  path you want to storage logs. 
                        $next = "server"
                    }
                    if ($line_data -like '%From*') {  # Enter the  path you want to storage logs. 
                        $next = "from"
                    }
        
                }
            }

            ##########################
            # ANALYZE EVENT CAPTURED #
            ##########################

            $name = $Event.SourceEventArgs.Name
            $path = $Event.SourceEventArgs.FullPath
            $changeType = $Event.SourceEventArgs.ChangeType
            $timeStamp = $Event.TimeGenerated
            $datestamp = get-date -uformat "%Y-%m-%d@%H-%M-%S"
            $Computer = get-content env:computername
            $Body = " $path on $Computer was $changeType at $timeStamp"
            $PIECES=$path.split("\")
            $newfolder=$PIECES[-2]
            $user = (get-acl $path).owner
            
            ################################
            # find extension in white list #
            ################################

            $founded=""
            $pos = $name.IndexOf(".")
            $leftPart = $name.Substring(0, $pos)
            $rightPart = $name.Substring($pos+1)
            $founded=""
            $pos = $name.IndexOf(".")
            $leftPart = $name.Substring(0, $pos)
            $rightPart = $name.Substring($pos+1)
            
            ###############################
            # CHECK IF EXTENSION IS KNOWN #
            ###############################

            if ($whitelist -like '*.' + $rightPart) {
                $founded = ""
            }
            else {
                $founded = ", File is not recognized"
            }
            
            ######################################
            # CHECK IF EXTENSION IS A RANSOMWARE #
            ######################################
            $danger = ""
            if ($blacklist -like '*.' +$rightPart) {
                
                $infected = "and was INFECTED!!!!!"
                $danger = "DANGER! DANGER! NEW RANSOMWARE FOUNDED AND WORKING. BLOCKING..."
                $Messages_count++;
                ################
                #GETCOMPUTERNAME
                ################

                Import-Module ActiveDirectory

                $m= (Get-AdComputer -Filter *) | measure
                $total = $m.count
                $modelinfo=@()
                (Get-ADComputer -Filter *) | 
                ForEach-Object {
                    Try 
                    {
                        $count = $count + 1
                        $computername= $_.dnshostname
                        $user_temp = Get-WmiObject win32_computersystem -Computer $computername | Select-Object -ExpandProperty username
                        if ($user_temp -like $user) {
                            $computer = $computername
                        }
                    }
                    Catch {
                    }
                }

                

                ###################
                # Disable user AD #
                ###################
                Write-Host "Disabling user : $user" 
                $Danger += "Disabling user :"+  $user + "."
                $pos = $user.IndexOf("\")
                $user_to_disable= $user.Substring($pos+1)
                Disable-ADAccount -Identity $user_to_disable
                Write-Host "Disabled!" 
                
                ###########################
                # ALERTO TO ADMINISTRATOR #
                ###########################

                #Send-MailMessage -From $FROM -To $To -Subject "File Infected!!!" -Body $messageBody -SmtpServer $smtp
                $messageBody = "File `"$Name`" was infected!"

                ######################################
                #Sending message to user and computer#
                ######################################
               
                Invoke-WmiMethod -Class win32_process -ComputerName $computer -Name create -ArgumentList  "c:\windows\system32\msg.exe * DANGER! RANSOMWARE DETECTED.USER AND COMPUTER DISABLED.`n `nPLEASE PUT IN CONTACT WITH YOU SYSTEM ADMINISTRATOR."
                
                #####################################################  
                #Disable ETHERNET NETWORK ADAPTER for a computername#
                #####################################################  
                   
                    Write-Host "Disabling NIC on :  $computer" -ErrorAction Stop | ? { $_.NetConnectionStatus -eq 2 } 
                    $danger += ". Disabling NIC on:" + $computer + "."       
                                   
                    if(Test-Connection -ComputerName $computer -Count 1 -ErrorAction 0) {            
                        try {            
                                $nics = Get-wmiobject win32_NetworkAdapter -ComputerName $computer -ErrorAction Stop| Where-Object {($_.Name -like "*Ethernet*") -and  ($_.NetConnectionStatus -eq 2) }           
                                Write-Host "NICs DETECTED: $nics"
                            }
                             
                        catch {            
                                Write-Error "Failed to connect for network adapters on $computer"            
                                Continue            
                            }            
                       
                       foreach($nic in $nics) {   
                        
                               
                            try {       
                                    Write-Host "Disabling $nic ..."
                                    $retval = $nic.disable()     
                                } 
                                catch {            
                                        "Error occurred while disabling {0}" -f $nic.Name            
                                        continue            
                                } 
                                Write-Host "Disabled!"            
                        } 
                                   

                 } 
                 else {            
                         Write-Verbose "$computer is offline"            
                      }   
                
       
            Write-Host " "
            Write-Host "$path on $Computer was $changeType at $timeStamp by $user $founded $infected $danger"
            Out-File -FilePath $folder_tolog -Append -InputObject " $path on $Computer was $changeType at $timeStamp by $user $founded $infected $danger"
            #Send-MailMessage -To "email@domain.com" -From "email@domain.com" -Subject $Body -SmtpServer "192.168.#.##" -Body " "    
            }
            else {
                $infected = ""
            }

        
        # Let's check if is a new ransomware..
            foreach ($fake in $fake_dirs) {
            #Files to check if exists

                $file1 = $fake + "\_1.docx"
                $file2 = $fake + "\_2.docx"
                $file3 = $fake + "\_3.docx"

                if ( ( (Test-Path $file1) -and (Test-Path $file2) -and (Test-Path $file3) ) -or ( ($path -like "*_3.docx") -or ($path -like "*_2.docx") -or ($path -like "*_1.docx")  ) )
                { 
            #All fine!
                    Write-Host "NO NEW RANSOMWARE FOUNDED! on $fake"
                }
                else { 

                Write-Host "DETECTED HONEYPOT $path on $fake"
                ####################################################################
                # RANSOMWARE FAKE DELETE FILES!!!!! OR RENAME TO UNKOWN EXTERNSION #
                ####################################################################

                        $infected = ""
                        $danger = "DANGER! DANGER! NEW RANSOMWARE FOUNDED AND WORKING ON $fake. BLOCKING..."
                        
                        #######################################
                        # FIND NEW FILES IN THIS FAKE FOLDER  #
                        #######################################
                        $fake_files_new = Get-ChildItem -Path $fake -Exclude _1.docx,_2.docx,_3.docx
                        if ($fake_files_new) {
                        
                        #Detect the user who has ransomware by creation new files
                        $user = (get-acl $fake_files_new[0]).owner
                        

                        ################
                        #GETCOMPUTERNAME
                        ################

                        Import-Module ActiveDirectory

                        $m= (Get-AdComputer -Filter *) | measure
                        $total = $m.count
                        $modelinfo=@()
                        (Get-ADComputer -Filter *) | 
                        ForEach-Object {
                            Try 
                            {
                                $count = $count + 1
                                $computername= $_.dnshostname
                                $user_temp = Get-WmiObject win32_computersystem -Computer $computername | Select-Object -ExpandProperty username
                                if ($user_temp -like $user) {
                                    $computer = $computername
                                }
                            }
                            Catch {
                            }
                        }
                        
                        ###################
                        # Disable user AD #
                        ###################

                        Write-Host "Disabling user : $user ..."
                        $Danger += "Disabling user :"+  $user + "."
                        $pos = $user.IndexOf("\")
                        $user_to_disable= $user.Substring($pos+1)
                        Disable-ADAccount -Identity $user_to_disable
                        Write-Host "Disabled!" 
                
                        ###########################
                        # ALERTO TO ADMINISTRATOR #
                        ###########################

                        #Send-MailMessage -From $FROM -To $To -Subject "File Infected!!!" -Body $messageBody -SmtpServer $smtp
                        $messageBody = "File `"$Name`" was infected!"

                        ######################################
                        #Sending message to user and computer#
                        ######################################
               
                        Invoke-WmiMethod -Class win32_process -ComputerName $computer -Name create -ArgumentList  "c:\windows\system32\msg.exe * DANGER! RANSOMWARE DETECTED.USER AND COMPUTER DISABLED.`n `nPLEASE PUT IN CONTACT WITH YOU SYSTEM ADMINISTRATOR."
                        
                        #######################################################  
                        # Disable ETHERNET NETWORK ADAPTER for a computername #
                        ####################################################### 

                        Write-Host "Disabling NIC on :  $computer" -ErrorAction Stop | ? { $_.NetConnectionStatus -eq 2 } 
                        $danger += ". Disabling NIC on:" + $computer + "."       
                                   
                        if(Test-Connection -ComputerName $computer -Count 1 -ErrorAction 0) {            
                            try {            
                                  $nics = Get-wmiobject win32_NetworkAdapter -ComputerName $computer -ErrorAction Stop| Where-Object {($_.Name -like "*Ethernet*") -and  ($_.NetConnectionStatus -eq 2) }           
                                }
                             
                            catch {            
                                 Write-Error "Failed to connect for network adapters on $computer"            
                                 Continue            
                                }            
                       
                            foreach($nic in $nics) {     
                            try {       
                                    $retval = $nic.disable()            
                                    if($retval.returnvalue -eq 0) {             
                                        "{0} network card disabled successfully" -f $nic.Name            
                                    } 
                                    else {            
                                        "{0} network card disable failed" -f $nic.Name            
                                    }            
                                } 
                                catch {            
                                        "Error occurred while disabling {0}" -f $nic.Name            
                                        continue            
                                }            
                            }            

                        } 
                        else {            
                                Write-Verbose "$computer is offline"            
                       }   

                    Write-Host "Disabled!"
                    Write-Host "$path on $Computer was $changeType at $timeStamp by $user $founded $infected $danger"
                    Out-File -FilePath $folder_tolog -Append -InputObject " $path on $Computer was $changeType at $timeStamp by $user $founded $infected $danger"
                    
                    #############################################
                    # REMOVE ALL ITEMS AND COPY NEW IN HONEYPOT #
                    #############################################
                    Write-Host " Restoring fake files to $fake"
                    $restore = $fake +"\*.*"
                    Write-Host " Remove $restore"
                    Remove-Item $restore
                    Write-Host " And Copy"
                    $restore = $fake +"\"
                    Copy-Item "C:\Anti_malware_config\docs\_1.docx" $restore
                    Copy-Item "C:\Anti_malware_config\docs\_2.docx" $restore
                    Copy-Item "C:\Anti_malware_config\docs\_3.docx" $restore
                    Write-Host " Restored!"

                    
                    } #end if fake_files_new
                    }#end else
                }

            }

        Clear-Host 
        Write-Host "
 _____    ______       ____     ________    _____    _____      __      _  
(  __ \  (   __ \     / __ \   (___  ___)  / ___/   (_   _)    /  \    / ) 
 ) )_) )  ) (__) )   / /  \ \      ) )    ( (__       | |     / /\ \  / /  
(  ___/  (    __/   ( ()  () )    ( (      ) __)      | |     ) ) ) ) ) ) 
 ) )      ) \ \  _  ( ()  () )     ) )    ( (         | |    ( ( ( ( ( (    
( (      ( ( \ \_))  \ \__/ /     ( (      \ \___    _| |__  / /  \ \/ /    
/__\      )_) \__/    \____/      /__\      \____\  /_____( (_/    \__/                                                   
                                                                     
"
    
        Write-Host "PROTEcting your INformation - AntiRansomware"
        Write-Host "____________________________________________"
        Write-Host " "
        Write-Host " "
    
        Write-Host "Configuration Succesful..."
        Write-Host "--------------------------"
        Write-Host "PATH : $folder"
        Write-Host "LOGS: $folder_tolog"
        Write-Host "EMAIL : $To SMTP : $smtp"
        Write-Host ""
        #load black & white lists on arrays and fake directories

    }
    else { #Error configuration file
        Write-Host "CONFIG FILE ERROR"
        Write-Host "================="
        Write-Host ""
        Write-Host "%Path_Repository: "$Folder
        Write-Host "%Path_File: "$Folder_tolog
        Write-Host "%To: "$To
        Write-Host "%%SMTP "$smtp
    }
    
} # End monitor parameter