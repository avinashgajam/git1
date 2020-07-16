param($username,
    $password,
    $packageLoc,
    $packageName,
    $orgName,
    $region,    
    $orgUrl,
    $logLocation
)
<###################################################################################################

This imports the Package that is built with VS. 
The package usually contains data (i.e Entities and other CRM components) and solution files

Required Parameters 
    
    username      - Organization username
    password      - Organization password
    packageLoc    - Package location. This is the package built by VS
    packageName   - Packagename is the dll built by VS i.e. SubwayTestPkgDep.dll
    orgName       - Organization Name where to import the data and solutions
    region        - Which region is your organization belongs to
    orgUrl        - This is the URL of an Organization to deploy to
    logLocation   - Folder location to write log during import process 

####################################################################################################> 


Write-Verbose "===================================================================="
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

#Credentials
$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
#No PROMPT for credential
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

#this is required to establish connection in order for Get-CrmConnection to work
$conn = Connect-CrmOnline -Credential $cred -ServerUrl $orgUrl  -ForceDiscovery 

$CRMConn = Get-CrmConnection  -DeploymentRegion $region –OnlineType Office365 –OrganizationName $orgName -Credential $cred -LogWriteDirectory $logLocation -Verbose 

#Import Solutions and or CRM Data
#Import-CrmPackage -CrmConnection $CRMConn -PackageDirectory $packageLoc -PackageName $packageName -LogWriteDirectory  $logLocation -Verbose -RuntimePackageSettings PkgFolderLoc=$packageLoc -Timeout "2:00:00"

$lcidEnabled = $false

Do {
   
    if ( !$lcidEnabled){
            
            Write-Host " Trying to deploy solution..."
            try{
                Import-CrmPackage -CrmConnection $CRMConn -PackageDirectory $packageLoc -PackageName $packageName -LogWriteDirectory  $logLocation -Verbose -RuntimePackageSettings PkgFolderLoc=$packageLoc -Timeout "2:00:00" -ErrorAction stop
                $lcidEnabled = $true
            }catch{ 
                 $_.Exception.Message
                 $lcidEnabled = $false
                 Write-Host "Error Timeout occurs  - waiting for 5 minutes " -BackgroundColor Cyan
                 Write-Host "Checking every 5 min making sure language activation is complete" 
                [System.DateTime]::Now  
           
                Start-Sleep -Seconds  300  #pause for 5 minutes before activating another one. looks like it has to finish the activation completely before activating a new one
            }
            
    }
} While (!$lcidEnabled)



  $deploymentOutput = "CRM Solutions Deployment:
        =========================================================
        Package Location: 	      $($packageLoc)
        Package Name: 	          $($packageName)
        Organization:       	  $($orgName)
        Organization URL:         $($orgUrl)
        Region:       	          $($region)
        "
	    Write-Host
	    Write-Host $deploymentOutput


