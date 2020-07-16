param($username,
    $password,
    $orgName,
    $region,    
    $orgUrl,
    $rulestatus
)

<###################################################################################################

This set Rule Set to 'Active'
The package usually contains data (i.e Entities and other CRM components) and solution files

Required Parameters 
    
    username      - Organization username
    password      - Organization password
    orgName       - Organization Name where to import the data and solutions
    region        - Which region is your organization belongs to
    orgUrl        - This is the URL of an Organization to deploy to

####################################################################################################> 

###$username = "graveline_m@subway.com"
###$password = "----------"
###$orgName = "org8a100095"
###$region = "East US"
###$orgUrl  = "https://fwhsandbox.crm.dynamics.com/"
###$rulestatus = "Draft"



Write-Verbose "===================================================================="
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

#Credentials
$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
#No PROMPT for credential
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

#this is required to establish connection in order for Get-CrmConnection to work
$conn = Connect-CrmOnline -Credential $cred -ServerUrl $orgUrl  -ForceDiscovery 

$__conn = Get-CrmConnection  -DeploymentRegion $region –OnlineType Office365 –OrganizationName $orgName -Credential $cred -LogWriteDirectory $logLocation -Verbose 


$__ht = @{}

if ($rulestatus -eq "Active") {
   "Activating SLA"
   $__statecode = New-CrmOptionSetValue -Value 1
   $__ht.Add("statecode", $__statecode)

   $__statuscode = New-CrmOptionSetValue -Value 2
   $__ht.Add("statuscode", $__statuscode)


   $__ht.Add("isdefault", $true)



   Set-CrmRecord -conn $__conn -EntityLogicalName "sla" -Id "03C526B8-C3A5-EA11-A812-000D3A8B33F5" -Fields $__ht 
}

if ($rulestatus -eq "Draft") {
   "DeActivating SLA"
   $__statecode = New-CrmOptionSetValue -Value 0
   $__ht.Add("statecode", $__statecode)

   $__statuscode = New-CrmOptionSetValue -Value 1
   $__ht.Add("statuscode", $__statuscode)

   Set-CrmRecord -conn $__conn -EntityLogicalName "sla" -Id "03C526B8-C3A5-EA11-A812-000D3A8B33F5" -Fields $__ht
}