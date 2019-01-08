function Load-ConfigObject {
    param (
        [string]$path
    )
    $json_config = Get-Content -Path $path -Force
    try {
        return ($json_config | ConvertFrom-Json)
    }
    catch {
        return $null
    }
}

function Load-ConfigHashTable {
    param (
        [string]$path
    )
    $json_config = Get-Content -Path $path -Force
    try {
        return ($json_config | ConvertFrom-Json | ConvertTo-HashtableFromPsCustomObject)
    }
    catch {
        return $null
    }
}

function Get-ConfigKey {
    param (
        [string]$path,
        [string]$key
    )
    [hashtable]$config = Load-ConfigHashTable $path
    return ($config.$key)
}

function Set-ConfigKey {
    param (
        [string]$path,
        [string]$key,
        [string]$value
    )
    [hashtable]$config = Load-ConfigHashTable $path
    $config.$key = $value
    $json = $config | ConvertTo-Json
    Set-Content -Path $path -Value $json
}

function Create-ConfigKey {
    param (
        [string]$path,
        [string]$key,
        [string]$value
    )
    [hashtable]$config = Load-ConfigHashTable $path
    $config.Add($key, $value)
    $json = $config | ConvertTo-Json
    Set-Content -Path $path -Value $json
}


# START HELPER FUNCTIONS

function ConvertTo-PsCustomObjectFromHashtable { 
     param ( 
         [Parameter(  
             Position = 0,   
             Mandatory = $true,   
             ValueFromPipeline = $true,  
             ValueFromPipelineByPropertyName = $true  
         )] [object[]]$hashtable 
     ); 
     
     begin { $i = 0; } 
     
     process { 
         foreach ($myHashtable in $hashtable) { 
             if ($myHashtable.GetType().Name -eq 'hashtable') { 
                 $output = New-Object -TypeName PsObject; 
                 Add-Member -InputObject $output -MemberType ScriptMethod -Name AddNote -Value {  
                     Add-Member -InputObject $this -MemberType NoteProperty -Name $args[0] -Value $args[1]; 
                 }; 
                 $myHashtable.Keys | Sort-Object | % {  
                     $output.AddNote($_, $myHashtable.$_);  
                 } 
                 $output; 
             } else { 
                 Write-Warning "Index $i is not of type [hashtable]"; 
             } 
             $i += 1;  
         } 
     } 
} 

function ConvertTo-HashtableFromPsCustomObject { 
     param ( 
         [Parameter(  
             Position = 0,   
             Mandatory = $true,   
             ValueFromPipeline = $true,  
             ValueFromPipelineByPropertyName = $true  
         )] [object[]]$psCustomObject 
     ); 
     
     process { 
         foreach ($myPsObject in $psObject) { 
             $output = @{}; 
             $myPsObject | Get-Member -MemberType *Property | % { 
                 $output.($_.name) = $myPsObject.($_.name); 
             } 
             $output; 
         } 
     } 
}
