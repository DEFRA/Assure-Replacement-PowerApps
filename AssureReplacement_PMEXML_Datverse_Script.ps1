try 
{ 

   
   # $CodeSecureString = ConvertTo-SecureString "" -AsPlainText -Force
   # $Encrypted = ConvertFrom-SecureString -SecureString $CodeSecureString
   #Error Log File Name and Location

    
    $sampleManagerDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $scriptDir = $sampleManagerDir
    $errorlogDir  = Join-Path -Path $scriptDir -ChildPath \Logs

     $ErrorLogFile = "$errorlogDir\PMEScriptErrorLog-" + (Get-Date).ToString("dd-MM-yyyy") + ".csv"
         
  "==Step1==PME Script Started to Retrieve PME XML files from Dataverse ===="+(Get-Date).ToString("dd/MM/yyyy HH:mm:ss") +"=========" | Out-File $ErrorLogFile -Append
    
  "========== Fetch TenantId,ClientId,environmnetURL,environmentname,APHAserversharedpath etc.from PMEConfiguration csv File ======" | Out-File $ErrorLogFile -Append

      $PMEConfiguration = Import-Csv -path  "$scriptDir\PMEConfiguration.csv"
    "======================================= Fetched the Tenant Id, ClientId, Client Secret From csv File =========================" | Out-File $ErrorLogFile -Append

    for($i=0;$i -lt $PMEConfiguration.Count;$i++)
    
    {
    
        if($PMEConfiguration[$i].Name -eq "TenantId")

        {
        
          $TenantId=$PMEConfiguration[$i].value;
          
        "======================================= Fetched the Tenant Id From csv File =============================================" | Out-File $ErrorLogFile -Append
        
      }
    
        
        if($PMEConfiguration[$i].Name -eq "ClientId")

        {
        
          $ClientId=$PMEConfiguration[$i].value;
          
      "======================================= Fetched the ClientId From csv File =================================================" | Out-File $ErrorLogFile -Append
        
        }


         if($PMEConfiguration[$i].Name -eq "PowerPlatformOrg")

        {
        
          $PowerPlatformOrg=$PMEConfiguration[$i].value;
          
     "======================================= Fetched the PowerPlatformOrg From csv File ========================================" | Out-File $ErrorLogFile -Append

        
        }

         if($PMEConfiguration[$i].Name -eq "PMESharedpath")

        {
        
          $PMESharedpath=$PMEConfiguration[$i].value;
          
     "======================================= Fetched the PMESharedpath From csv File ==========================================" | Out-File $ErrorLogFile -Append
            
        }
     
        
        if($PMEConfiguration[$i].Name -eq "EnvironmentName")

        {
        
          $EnvironmentName=$PMEConfiguration[$i].value;
          
     "======================================= Fetched the EnvironmentName From csv File ======================================" | Out-File $ErrorLogFile -Append
             
        }          
    
    }
             
    
    "===========$EnvironmentName============================================================================================" | Out-File $ErrorLogFile -Append
    "======================================= Retrieve encrypted Client Secret From Text File ===============================" | Out-File $ErrorLogFile -Append
    
    $SecureKey = Get-Content -path  "$scriptDir\Securitykey.txt"
      
    "======================================= Fetched the Client Secret From Text File ======================================" | Out-File $ErrorLogFile -Append

           
    $PasswordSecureSecret = ConvertTo-SecureString $SecureKey
  
 
    $PlainTextClientSecret= [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PasswordSecureSecret))

        


    #Azure Tenant Id 
    $TenantId = $TenantId
    # Azure - "Assure-PME-APP" app client id 
    $ClientId = $ClientId

   
    #Azure - "Assure-PME-APP" app client secret 
    $ClientSecret = $PlainTextClientSecret
    
    #PME XML Files Download Folder Location
    $PMEFilesDownloadLocation = $PMESharedpath

    #Get the power platform environmnet url
    $PowerPlatformEnvironmentUrl = $PowerPlatformOrg

    #Get the authentication url
    $oAuthTokenEndpoint = "https://login.microsoftonline.com/$($TenantId)/oauth2/v2.0/token"


  
   
      
    $creds = [System.Management.Automation.PSCredential]::new($ClientId, (ConvertTo-SecureString $ClientSecret -AsPlainText -Force))
       

    "===========$EnvironmentName========================================================================================" | Out-File $ErrorLogFile -Append

    "===========Start_Access_Token_Request==============================================================================" | Out-File $ErrorLogFile -Append

    "===========Step1 OAuth Body Access Token Request through service principal=========================================" | Out-File $ErrorLogFile -Append

     $authBody = @{
                    client_id = $ClientId;
                    client_secret = $ClientSecret;    
                    # The v2 endpoint for OAuth uses scope instead of resource
                    scope = "$($PowerPlatformEnvironmentUrl)/.default"
                    grant_type = 'client_credentials'
                }

    "===========Step2 Parameters for OAuth Access Token Request==========================================================" | Out-File $ErrorLogFile -Append

         $authParams = @{
                    URI = $oAuthTokenEndpoint
                    Method = 'POST'
                    ContentType = 'application/x-www-form-urlencoded'
                    Body = $authBody
                }
             # Get Access Token
       
                $authResponseObject = Invoke-RestMethod @authParams  
                $authResponseObject
     
     "===========End_Access_Token_Request===============================================================================" | Out-File $ErrorLogFile -Append

     "===========Step3 Start_Extract_XMLfile_From_DataVerse_Table=======================================================" | Out-File $ErrorLogFile -Append

      

     $statuscodefilter   =  '/api/data/v9.1/assure_pmexmlfiles_storages?$select=assure_name&$filter=assure_file_status eq 1'

     
     # Set up web API call parameters, including a header for the access token
    $getApiCallParams = @{
    
     
   #  URI = $URILink

     

     URI = "$($PowerPlatformEnvironmentUrl)$statuscodefilter"
      
        Headers = @{
            "Authorization" = "$($authResponseObject.token_type) $($authResponseObject.access_token)" 
            "Accept" = "application/json"
            "OData-MaxVersion" = "4.0"
            "OData-Version" = "4.0"
        }
        Method = 'GET'
    }

# Call API to Get Response
    $getApiResponseObject = Invoke-RestMethod @getApiCallParams 

#verify if any xml files staus as uploaded morethan 0
if($getApiResponseObject.value.Length -gt 0)
  
{
    
for ($i=0; $i -lt $getApiResponseObject.value.Length; $i++)
 
{

  #Retrive filename and Guid of the file 
  $xmlfilename= $getApiResponseObject.value[$i].assure_name
  $filestoreid = $getApiResponseObject.value[$i].assure_pmexmlfiles_storageid
  $objvalue = "value"
  $objdollar = "$"

  #Build xml file URL to download

   $DownloadXMLfile = "assure_pmexmlfiles_storages($filestoreid)/assure_xml_file_link/$objdollar$objvalue";

   $getXMLfileApiCallParams = @{
       URI = "$($PowerPlatformEnvironmentUrl)/api/data/v9.1/$($DownloadXMLfile)"

   
      
        Headers = @{
            "Authorization" = "$($authResponseObject.token_type) $($authResponseObject.access_token)" 
            "Accept" = "application/json"
            "OData-MaxVersion" = "4.0"
            "OData-Version" = "4.0"
        }

        Method = 'GET'
    }

   
   Invoke-RestMethod @getXMLfileApiCallParams -OutFile ( New-Item -Path "$PMEFilesDownloadLocation\$xmlfilename" -Force ) 

   "=======Downloaded the $xmlfilename==== from Pmexmlfiles_storage DataVerse table ===to APHA server===================" | Out-File $ErrorLogFile -Append

   "=======To create an update request to the DataVerse table===========================================================" | Out-File $ErrorLogFile -Append
    
      
    $DownloaedDate = (Get-Date).ToString("MM/dd/yyyy HH:mm:ss")
    

#   $patchRequestUri = "assure_pmexml_filestores($($filestoreid))"+'?$select=assure_name,assure_pmexml_filestoreid,statuscode,assure_downloadeddate'

$patchRequestUri = "assure_pmexmlfiles_storages($($filestoreid))"+'?$select=assure_name,assure_pmexmlfiles_storageid,assure_file_status,assure_downloadeddate'

   $updateBody  = @{
   'assure_file_status' = '2'
   'assure_downloadeddate' = $DownloaedDate
   } | ConvertTo-Json
# Set up web API call parameters, including a header for the access token
$patchApiCallParams = @{
    URI = "$($PowerPlatformEnvironmentUrl)/api/data/v9.1/$($patchRequestUri)"
    Headers = @{
        "Authorization" = "$($authResponseObject.token_type) $($authResponseObject.access_token)"
        "Accept" = "application/json"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
        "Content-Type" = "application/json; charset=utf-8"
        "Prefer" = "return=representation"  # in order to return data
        "If-Match" = "*" 
    }
    Method = 'PATCH'
    Body = $updateBody
}

# Call API to Update a record.
$patchApiResponseObject = Invoke-RestMethod @patchApiCallParams 

  "=======updated the statuscode and assure_downloadeddate columns after downloaded===================================" | Out-File $ErrorLogFile -Append
  "=======$EnvironmentName==PME Script End ==============="+(Get-Date).ToString("dd/MM/yyyy HH:mm:ss") +"=============" | Out-File $ErrorLogFile -Append
  "===================================================================================================================" | Out-File $ErrorLogFile -Append


}

}

else

{
   "===============================There is no PME XML file(s) to download from Pmexmlfiles_storage Dataversetable ====" | Out-File $ErrorLogFile -Append
  "=======$EnvironmentName==PME Script End ==============="+(Get-Date).ToString("dd/MM/yyyy HH:mm:ss") +"==============" | Out-File $ErrorLogFile -Append
 
}

 
 }
  
catch [System.IO.FileNotFoundException] {
 "=====================================================================================================================" | Out-File $ErrorLogFile -Append
   "Errors" | Out-File $ErrorLogFile -Append
     $_.Exception | Out-File $ErrorLogFile -Append
         
 "=====================================================================================================================" | Out-File $ErrorLogFile -Append
  
}

catch {
"======================================================================================================================" | Out-File $ErrorLogFile -Append
 "Errors" | Out-File $ErrorLogFile -Append
     $_.Exception | Out-File $ErrorLogFile -Append
"======================================================================================================================" | Out-File $ErrorLogFile -Append

}




