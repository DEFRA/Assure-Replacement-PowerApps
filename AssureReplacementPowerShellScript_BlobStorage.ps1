try 
{ 

   
   # $CodeSecureString = ConvertTo-SecureString "entersecrettext" -AsPlainText -Force
   # $Encrypted = ConvertFrom-SecureString -SecureString $CodeSecureString
   #Error Log File Name and Location

    
    $sampleManagerDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $scriptDir = $sampleManagerDir
    $errorlogDir  = Join-Path -Path $scriptDir -ChildPath \Logs
    $ErrorLogFile = "$errorlogDir\PMEScriptErrorLog-" + (Get-Date).ToString("yyyy-MM-dd") + ".csv"

  "==Step1 PME Script Started to Retrieve PME XML files from BLOB storage ==============="+(Get-Date).ToString("yyyy-MM-dd hh:mm:ss")+"=============" | Out-File $ErrorLogFile -Append
    

     
    "==================================================================================================================" | Out-File $ErrorLogFile -Append
    "==================================================================================================================" | Out-File $ErrorLogFile -Append
    "======================================= Retrieve encrypted Client Secret From Text File ==========================" | Out-File $ErrorLogFile -Append
    
    $SecureKey = Get-Content -path  "$scriptDir\SecurityKeyTest.txt" | Out-File $ErrorLogFile -Append

         
    "======================================= Fetched the Client Secret From Text File =================================" | Out-File $ErrorLogFile -Append

   # $ClientSecret = "GHO8Q~Oi0NCsdwwGAkbrPseuaoD0wem.GUQKqamL"
           
    $PasswordSecureSecret = ConvertTo-SecureString $SecureKey | Out-File $ErrorLogFile -Append
    $EncryptedSecret =     ConvertFrom-SecureString $PasswordSecureSecret | Out-File $ErrorLogFile -Append
   
    $PasswordSecureString = ConvertTo-SecureString $EncryptedSecret -AsPlainText -force | Out-File $ErrorLogFile -Append

   
 
    $PlainTextClientSecret= [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PasswordSecureSecret)) | Out-File $ErrorLogFile -Append

    "========== Fetch Tenant Id, ClientId, Subscrption, Resourcegroup etc.. from PMEConfiguration csv File ============" | Out-File $ErrorLogFile -Append
    

     $PMEConfiguration = Import-Csv -path  "$scriptDir\PMEConfiguration.csv"
    "======================================= Fetched the Tenant Id, ClientId, Client Secret From csv File =============" | Out-File $ErrorLogFile -Append

    for($i=0;$i -lt $PMEConfiguration.Count;$i++)

    {
    
        if($PMEConfiguration[$i].Name -eq "TenantId")

        {
        
          $TenantId=$PMEConfiguration[$i].value;
          
        "======================================= Fetched the Tenant Id From csv File ==================================" | Out-File $ErrorLogFile -Append

        
      }
      
        
        if($PMEConfiguration[$i].Name -eq "ClientId")

        {
        
          $ClientId=$PMEConfiguration[$i].value;
          
     "======================================= Fetched the ClientId From csv File ======================================" | Out-File $ErrorLogFile -Append

        
        }


         if($PMEConfiguration[$i].Name -eq "SubscrptionId")

        {
        
          $SubscrptionId=$PMEConfiguration[$i].value;
          
     "======================================= Fetched the SubscrptionId From csv File =================================" | Out-File $ErrorLogFile -Append

        
        }

         if($PMEConfiguration[$i].Name -eq "PMESharedpath")

        {
        
          $PMESharedpath=$PMEConfiguration[$i].value;
          
     "======================================= Fetched the PMESharedpath From csv File =================================" | Out-File $ErrorLogFile -Append

        
        }



       if($PMEConfiguration[$i].Name -eq "ResourceGroupName")

        {
        
          $ResourceGroupName=$PMEConfiguration[$i].value;
          
     "======================================= Fetched the ResourceGroupName From csv File =============================" | Out-File $ErrorLogFile -Append

        
        }

        
       if($PMEConfiguration[$i].Name -eq "StorageAccountName")

        {
        
          $StorageAccountName=$PMEConfiguration[$i].value;
          
     "======================================= Fetched the StorageAccountName From csv File ============================" | Out-File $ErrorLogFile -Append

        
        }

           if($PMEConfiguration[$i].Name -eq "ContainerName")

        {
        
          $ContainerName=$PMEConfiguration[$i].value;
          
     "======================================= Fetched the ContainerName From csv File =================================" | Out-File $ErrorLogFile -Append

        
        }


       if($PMEConfiguration[$i].Name -eq "ArchiveContainerName")

        {
        
          $ArchiveContainerName=$PMEConfiguration[$i].value;
          
     "======================================= Fetched the ArchiveContainerName From csv File ==========================" | Out-File $ErrorLogFile -Append

        
        }


          if($PMEConfiguration[$i].Name -eq "KeyVaultName")

        {
        
          $KeyVaultName=$PMEConfiguration[$i].value;
          
     "======================================= Fetched the KeyVaultName From csv File ==================================" | Out-File $ErrorLogFile -Append

        
        }


       if($PMEConfiguration[$i].Name -eq "AccessKeySecret")

        {
        
          $AccessKeySecretName=$PMEConfiguration[$i].value;
          
     "======================================= Fetched the AccessKeySecretName From csv File ===========================" | Out-File $ErrorLogFile -Append

        
        }


       if($PMEConfiguration[$i].Name -eq "ClientSecret")

        {
        
          $ClientSecret=$PMEConfiguration[$i].value;
          
     "======================================= Fetched the ClientSecret From csv File ==================================" | Out-File $ErrorLogFile -Append

        
        }
    
    
    }

     


    #Azure Tenant Id 
    $TenantId = $TenantId
    # Azure - "Assure-PME-APP" app client id 
    $ClientId = $ClientId

    #Azure - "Assure-PME-APP" app client secret 
    $ClientSecret = $PlainTextClientSecret

    
    #Azure Subscription Id
    $SubscriptionId = $SubscrptionId
    #PME XML Files Download Folder Location
    $PMEFilesDownloadLocation = $PMESharedpath
    #Current Date Time Variable 
    $dtCurrentDateTime =  Get-Date -Format G
   
    #Assure PME Blob Container Name
    $ContainerName  = $ContainerName
    #Assure PME Archive Blob Container Name
    $ArchiveContainerName = $ArchiveContainerName
    #Storage Account 
    $StorageAccountName = $StorageAccountName
    #Assure Resource Group Name
    $ResourceGroupName = $ResourceGroupName 
   
    $KeyVaultName =$KeyVaultName

    $AccessKeySecretName =$AccessKeySecretName

   
    $creds = [System.Management.Automation.PSCredential]::new($ClientId, (ConvertTo-SecureString $ClientSecret -AsPlainText -Force))
       

    "==================================================================================================================" | Out-File $ErrorLogFile -Append
    "Step2 - Connecting to Azure Portal through Client ID and Client Secret" | Out-File $ErrorLogFile -Append

 
   
     Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionId -Credential $creds -ServicePrincipal 
     
 
    "Step2 - Connected to Azure Portal through Client ID and Client Secret" | Out-File $ErrorLogFile -Append
    "==================================================================================================================" | Out-File $ErrorLogFile -Append
    #Get Storage Account Key to get storage account context
    "==================================================================================================================" | Out-File $ErrorLogFile -Append
    "Step3 - Retrieve the Storgae Account Access Key" | Out-File $ErrorLogFile -Append

      $StorageAccountKey = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $AccessKeySecretName -AsPlainText 
       

      "Step3 - Retrieved the Storgae Account Access Key" | Out-File $ErrorLogFile -Append

    
    "==================================================================================================================" | Out-File $ErrorLogFile -Append
    #Create storage account context from retrieved sotrage account key
    "==================================================================================================================" | Out-File $ErrorLogFile -Append
    "Step4 - Creating Azure Storage Account Context from Access Key" | Out-File $ErrorLogFile -Append
    
 
   
    
    $StorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey 
                


    "Step4 - Created Azure Storage Account Context from Access Key" | Out-File $ErrorLogFile -Append
    "==================================================================================================================" | Out-File $ErrorLogFile -Append
    "==================================================================================================================" | Out-File $ErrorLogFile -Append
     "Step5 - Retrieve  all xml files which strats with 'PME' and storing as instance" | Out-File $ErrorLogFile -Append
    
   
     $assurepmeBlobs = Get-AzStorageBlob -Container $ContainerName -Context $StorageContext | Where-Object {$_.Name -match "PME" -and $_.Name -match ".xml"} 

    
     if($assurepmeBlobs.Count -le 0)
     {
     
     "===============================There is no PME XML file(s) to download from $ContainerName ======================" | Out-File $ErrorLogFile -Append

        "Disconnecting to Azure Portal" | Out-File $ErrorLogFile -Append
         Disconnect-AzAccount
         "Disconnected to  Azure Portal becuase there is no files to download" | Out-File $ErrorLogFile -Append
        "=========================PME Script End ==============="+(Get-Date).ToString("yyyy-MM-dd hh:mm:ss")+"=========" | Out-File $ErrorLogFile -Append

        Exit $LASTEXITCODE
     
     }

     "Step5 - Retrieved all XML files which strats with 'PME' and stored as instance" | Out-File $ErrorLogFile -Append
    "==================================================================================================================" | Out-File $ErrorLogFile -Append
    #Dowloading all blobs from 'assurepmedata' blob container to local folder
    "==================================================================================================================" | Out-File $ErrorLogFile -Append
     "Step6 - Downloading all xml files and copy it in $PMEFilesDownloadLocation folder" | Out-File $ErrorLogFile -Append
   

    $assurepmeBlobs | Get-AzStorageBlobContent -Destination $PMEFilesDownloadLocation 

     "Step6 - Downloaded all xml files and copied t in $PMEFilesDownloadLocation folder" | Out-File $ErrorLogFile -Append
    "==================================================================================================================" | Out-File $ErrorLogFile -Append
         
   
     "=================================================================================================================" | Out-File $ErrorLogFile -Append
     "Step7 - Deleting Process of PMEXML files from container: $ContainerName =========================================" | Out-File $ErrorLogFile -Append

      foreach ($PMEXMLfile in $assurepmeBlobs) {

   
    # Delete the source blob
    "Deleting " + $PMEXMLfile.Name + " from $ContainerName container" | Out-File $ErrorLogFile -Append
    Remove-AzStorageBlob -Container $ContainerName  -Blob $PMEXMLfile.Name -Context  $StorageContext
    "Deleted " + $PMEXMLfile.Name + "  from $ContainerName container" | Out-File $ErrorLogFile -Append
    }
    "Step7 - Delete Process is Completed of azure blobs from $ContainerName container==================================="| Out-File $ErrorLogFile -Append
   "===================================================================================================================" | Out-File $ErrorLogFile -Append
   "===================================================================================================================" | Out-File $ErrorLogFile -Append
   "Disconnecting to Azure Portal" | Out-File $ErrorLogFile -Append
   Disconnect-AzAccount
   "Disconnected to  Azure Portal" | Out-File $ErrorLogFile -Append
   "===================================================================================================================" | Out-File $ErrorLogFile -Append

   "=========================PME Script End ==============="+(Get-Date).ToString("yyyy-MM-dd hh:mm:ss")+"==============" | Out-File $ErrorLogFile -Append
    "==================================================================================================================" | Out-File $ErrorLogFile -Append

 } 
catch [System.IO.FileNotFoundException] {
 "=====================================================================================================================" | Out-File $ErrorLogFile -Append
   "Errors" | Out-File $ErrorLogFile -Append
     $_.Exception | Out-File $ErrorLogFile -Append
 "======================================================================================================================" | Out-File $ErrorLogFile -Append
}
catch [System.UnauthorizedAccessException] {
"======================================================================================================================" | Out-File $ErrorLogFile -Append
 "Errors" | Out-File $ErrorLogFile -Append
     $_.Exception | Out-File $ErrorLogFile -Append
"======================================================================================================================" | Out-File $ErrorLogFile -Append
}
catch {
"======================================================================================================================" | Out-File $ErrorLogFile -Append
 "Errors" | Out-File $ErrorLogFile -Append
     $_.Exception | Out-File $ErrorLogFile -Append
"======================================================================================================================" | Out-File $ErrorLogFile -Append
}




