Enum HexatownEvent {
    onItemRead = 1
    onItemsRead = 2
 
}

function FatalError($message) {
    Write-Error $message 
    exit
}


function http($api, $method, $url, $body) {
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    

    foreach ($apikey in $api._headers.keys) {
    
       $headers.Add($apikey, $api._headers.$apikey)    
    }
       
    
    $errorCount = $error.Count
    $result = Invoke-RestMethod $url -Method $method -Headers $headers #-Body $body
    if ($errorCount -ne $error.Count) {
        Write-Error $url
    }

    return $result
}


function  CheckListPath($api, $path) {
    if (!$api.ContainsKey($path)) {
        FatalError "List $path not found $api $path " 
        
    }
}
function  CheckIsArray($api, $array, $callback) {
    if ($null -eq $array) {
        FatalError "Missing array" 
    }
    foreach ($item in $array) {
        invoke-expression $callback
    }
}

function  CheckHasPath($api, $path) {
    if ($null -eq $api) {
        FatalError "API cannot be null" 
    }
    if ($null -eq $path) {
        FatalError "Path cannot be null" 
    }
    if (!$api.ContainsKey($path) ) {
        FatalError "Path not defined" 
    }
    return $api.$path 
}

function getUrl ($api, $path, $subarea) {

    $method = CheckHasPath $api $path
    $instance = $api
    

    $script = $method.getPath
       
    $result = Invoke-Command $script
    $url = $api._root + $result
    return $url
}

function emit($api, $path, $event) {
    $method = CheckHasPath $api $path
    $eventName = $event.ToString().Split("::")[2]
    write-verbose "Emiting $eventName"

    if ($null -ne $method.$eventName) {
        $instance = $api
        Invoke-Command $method.$eventName
    }
}

function Items($api, $method, $subarea) {
    
    $url = getUrl $api  $method $subarea
    $items = http $api get $url
    emit $api $method [HexatownEvent]::onItemsRead 
    

   
    
    return $items 
    
     

}

function Each($items, $callback) {
    foreach ($item in $items) {
        Invoke-Command -ScriptBlock $callback
    }

}




$instances = @{

}



function login($api) {
    if (!$instances.ContainsKey($api)) {

        $apipath = Join-Path $psscriptroot "$api.api.ps1"
        if (!(Test-Path $apipath)) {
            FatalError "FATAL ERROR API NOT FOUND $api"  
        }

        . $apipath 
        
        $instances.$api = APIInstance
        
    }
    return $instances.$api
}

function invoke-api($apiname,$arg0,$arg1){
    switch ($arg0 ) {
        'login' { return login $apiname }
        Default {
            FatalError "Method not found '$arg0'"  
        }
    }


}

function executeStatic($cmd,$arg0,$arg1) {
    switch ($cmd ) {
        'api'   { invoke-api $cmd $arg0 $arg1}
        
        Default {
            FatalError "Command not found '$cmd'"  
        }
    }

}
function executeInstance($api, $method, $area, $subarea) {
    switch ($method) {
        'list' {
            return Items $api $area $subarea
        }
        'first' {
            return (Items $api $area $subarea)[0]
        }
        Default {
            write-host "Method not found '$method'"  -ForegroundColor Red
            exit

        }
    }
}

function HEXA() {
    if ($args[0].GetType().Name -eq "String") { 
        return executeStatic $args[0] $args[1]
    }
    if ($args[1].GetType().Name -eq "String") {
        executeInstance  $args[0] $args[1] $args[2]
    }
    else {
        executeInstance $args[0] $args[2] $args[3] $args[1]
    }
}




