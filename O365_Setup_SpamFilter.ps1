###			     Setup O365 Spamfilter Script       ###
###				 Written by Daniel Hernandez		###
###				Dhernandez@nerdsthatcare.com		###

# On error, stop the script
	$ErrorActionPreference = "Continue"

# First we need credentials to use to connect to O365
	Write-Host "Enter your O365 Global Administrator credentials"
	$UserCredential = Get-Credential

# Then we need to define the PS session to connect to O365
	$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

# Now we Open the Session
	Import-PSSession $Session -AllowClobber
	
	
# Create Root Script location
	Write-Host "Creating root script location at C:\office365scripts"
		mkdir c:\office365scripts

	Write-Host "checking if prereq files exist"
	#check if Allowed Senders list exists......
		IF(test-path -path C:\office365Scripts\AllowedSenders.Txt){ 
			Write-Host "Allowed Senders file exists"
	}
		Else {
			Write-Host "AllowedSenders File was created please populate"
					echo "##list domains below 1 per line##REMOVE THIS COMMENT BEFORE EXECUTION" >> C:\office365scripts\allowedsenders.txt
			
	}
	#check if allowed Sender Domains list exists......
		IF(test-path -path C:\O365Scripts\AllowedSenderdomains.Txt){
			Write-Host "Allowed Sender domain file exists"
	}
		
		Else {
			Write-Host "AllowedSenderdomains File was created please populate"
			echo "##list domains below 1 per line#REMOVE THIS COMMENT BEFORE EXECUTION#" >> C:\office365scripts\allowedsenderdomain.txt
		
	}
	
	#check if  Blocked Domains list exists......
		IF(test-path -path C:\O365Scripts\BlockedSenderdomains.Txt){ 
				Write-Host "Blocked Sender domain file exists"
	}
		Else {
			Write-Host "BlockedSenderdomains File was created please populate"
					echo "## list domains below 1 per line#REMOVE THIS COMMENT BEFORE EXECUTION#" >> C:\office365scripts\Blockedsenderdomain.txt
			
	}
	
	#check if Blocked Senders list exists......
		IF(test-path -path C:\O365Scripts\BlockedSenders.Txt){
				Write-Host "Blocked Senders file exists"
	} 
	
	Else {
	
			Write-Host "Blockedsenders File was created please populate"	
					echo "##BlockedSenders list sender below 1 per line#REMOVE THIS COMMENT BEFORE EXECUTION#" >> C:\office365scripts\Blockedsenders.txt
			
	}
	
	#check if allowed IP list exists......
		IF(test-path -path C:\O365Scripts\AllowedIPS.Txt){
			Write-Host "Allowed Sender IPS file exists"
	}
		Else {
			write-host "AllowedIPS File was created please populate"
			echo "##list ips Per the following format;
			192.168.1.0/24,192.168.1.1,192.168.10.25,10.20.98.0/24
			No spaces between the ips just commas##REMOVE THIS COMMENT BEFORE EXECUTION" >> C:\office365scripts\AllowedIPS.Txt
			
	}
			
	#check if Blocked IP list exists......
		IF(test-path -path C:\O365Scripts\BlockedIPS.Txt){
			Write-Host "Blocked Sender IPS file exists"
	}
		Else {
			write-host "BlockedIPS File was created please populate"
			echo "##list ips Per the following format;
			192.168.1.0/24,192.168.1.1,192.168.10.25,10.20.98.0/24
			No spaces between the ips just commas##REMOVE THIS COMMENT BEFORE EXECUTION" >> C:\office365scripts\BlockedIPS.Txt
			
	}
			
			
	Read-Host -Prompt "Please Modify the TXT files and press any key to continue or CTRL-C to Cancel" 		


# Prompt for vars
	#$domainlist = Read-Host -Prompt 'Domain(s) to add to Allow list (press ENTER if none, use single space between entries): '
	#$addresslist = Read-Host -Prompt 'Email address to add to Allow list (press ENTER if none, use single space between entries): '
	#$domains = $domainlist -split " "
	#$addresses = $addresslist -split " "
	$AllowedIPS = Get-content C:\office365scripts\allowedips.txt
	$BlockedIPS = Get-content C:\office365scripts\BlockedIPS.txt
	$allowedsenderdomain = Get-content C:\office365scripts\allowedsenderdomain.txt
	$allowedsenders = Get-content C:\office365Scripts\AllowedSenders.txt
	$Blockedsenderdomain = Get-content C:\office365scripts\Blockedsenderdomain.txt
	$Blockedsenders = Get-content c:\office365scripts\Blockedsenders.txt
#Setup IpFilter
		if (!$AllowedIPS) {
		Write-Host "No Allowed IPS to add...skipping"
	} else {
		Write-Host "Adding allowed IPS to Default IP Allow list...."
		Set-HostedConnectionFilterPolicy Default -IPAllowList $AllowedIPS -IPBlocklist $BlockedIPS
	}

# Add Domains to allowed sender list, if any
	if (!$allowedsenderdomain) {
		Write-Host "No domains to add...skipping"
	} else {
		Write-Host "Adding domain name(s) to Default spam Allow list...."
		Set-HostedContentFilterPolicy -Identity Default -AllowedSenderDomains @{Add=$allowedsenderdomain}
	}

# Add email addresses to allowed senders list, if any
	if (!$allowedsenders) {
		Write-Host "No addresses to add...skipping"
	} else {
		Write-Host "Adding email address(es) to Default spam Allow list...."
		Set-HostedContentFilterPolicy -Identity Default -AllowedSenders @{Add=$allowedsenders}
	}
# Add Domains to Blocked  Sender Domain list, if any
	if (!$Blockedsenderdomain) {
		Write-Host "No domains to add...skipping"
	} else {
		Write-Host "Adding domain name(s) to Default spam Block list...."
		Set-HostedContentFilterPolicy -Identity Default -BlockedSenderDomains @{Add=$Blockedsenderdomain}
	}
# Add Addresses to Blocked Sender list, if any
	if (!$Blockedsenders) {
		Write-Host "No Addresses to add...skipping"
	} else {
		Write-Host "Adding Address(s) to Default spam Block list...."
		Set-HostedContentFilterPolicy -Identity Default -BlockedSenders @{Add=$Blockedsenders}
	}
	
# Enables Region Block and adds top offenders to the list.
	Set-HostedContentFilterPolicy default -EnableRegionBlockList $true -RegionBlockList BR,CN,DE,IR,IT,NL,RU,TH,UA,VN

# Close the Session or bad things happen!!!
	Remove-PSSession $Session
