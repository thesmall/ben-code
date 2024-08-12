#NOTES:
# This code NEEDS to be run as the account that will be executing Get-StoredCredential, i.e. the account that needs to query the password during execution of code.
# This code requires the CredentialManager module, you can install it using Install-Module:


#Type "Y" or "Yes" when prompted.
#Install-Module CredentialManager


#The username component of the credential. 
#If connecting to a Domain Resource, you will need to prefix you username with 'csnzoo\'
#If connecting to MSOL/SharePoint/O365, you need suffix your username with '@wayfair.com'
#If the credential is for a non-domain service, just supply the username as is. 

$Username = "ExampleUserName@domain.com"

#The password component of the credential. Remember to clear your clipboard and Clear-History after supplying the password.
$Password = 'FOoBar123!'

#The Target parameter is a friendly name used to get the password after you store it in the credential manager. It can be anything.
$Target = 'FriendlyName'

#The Type parameter specifies the type of credential it is. Unless you have a specific reason to use a different type of credential, choose "Generic"
$CredType = 'Generic'

#Specifies a comment that will be associated with the credential. "Used to connect to X Service". Maybe supply a Project Tracker Number here...
$Comment = "This credential is used to connect to X."

#Persistence defines the scope of the credential. There are three choices: 
    #Session = stores the password until the session (i.e. PowerShell.exe process) is destroyed.
    #LocalMachine = Stored the password on the system. It can only be accessed FROM the host itself.
    #Enterprise = presumably, the password can be accessed by other system. Not too much documentation about this choice, and its not exactly intuitive.
$Persist = 'LocalMachine'

#################################################################

#This will store the credential on the machine under the security context of the use running the code. 
New-StoredCredential -Target $Target -UserName $Username -Password $Password -Type $CredType -Comment $Comment -Persist $Persist -Verbose

#You can then Get back the credential as a PsCredential using:
$cred = Get-StoredCredential -Target $Target -Verbose


#Finally, you can use $cred in a function call that utilizes the -Credential Parameter:
Get-ADUser -Filter * -Credential $cred

