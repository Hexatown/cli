
#-------------------------------------------------------------#
#----Initial Declarations-------------------------------------#
#-------------------------------------------------------------#
$imageFolder = Join-Path $PSScriptRoot "img"
Add-Type -AssemblyName PresentationCore, PresentationFramework

$Xaml = @"
<Window Title="Hexatown Power⚙️Bricks by jumpto365" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
Width="713" Height="335" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="0,0,0,0" Name="kkwkgngptd1tl">
<Grid Margin="0,-1,0,1">
<Grid.Background>
            <ImageBrush ImageSource="$imageFolder/JUMPTOH POWERBRICKS.png"  Stretch="UniformToFill"/>
        </Grid.Background>
<Grid.RowDefinitions><RowDefinition Height="66"/><RowDefinition Height="109"/><RowDefinition Height="0.5735294117647058*"/></Grid.RowDefinitions>
<Grid.ColumnDefinitions><ColumnDefinition Width="0.5778222979064409*"/><ColumnDefinition Width="0.4229181167108753*"/></Grid.ColumnDefinitions>
  
 


<TextBlock Name="result" HorizontalAlignment="Left" VerticalAlignment="Top" Text="" TextWrapping="Wrap" Margin="80,0,0,0" Grid.Row="2" Grid.Column="0" FontWeight="Bold"/>
<Button Content="START" HorizontalAlignment="Left" VerticalAlignment="Top" Width="90" Margin="12.1875,35,0,0" Grid.Row="1" Grid.Column="1" Height="29" Name="pingButton"/>
 <ListView HorizontalAlignment="Left" BorderBrush="Black" BorderThickness="1" Height="277" VerticalAlignment="Top" Width="677" Margin="35,32,0,0" ItemsSource="{Binding data}">
  
  <ListView.ItemTemplate>
    <DataTemplate>
    
      <StackPanel Orientation="Horizontal">
<Ellipse HorizontalAlignment="Left" VerticalAlignment="Top" Fill="{Binding color}" Stroke="Black" Height="40" Width="40"/>
<StackPanel Margin="10,0,0,0">
  <TextBlock HorizontalAlignment="Left" VerticalAlignment="Top" TextWrapping="Wrap" Text="{Binding name}"/>
<TextBlock HorizontalAlignment="Left" VerticalAlignment="Top" TextWrapping="Wrap" Text="{Binding lastChecked}"/>
</StackPanel>

</StackPanel>
    
    </DataTemplate>
    </ListView.ItemTemplate>
  
  </ListView>

</Grid>
</Window>
"@
#-------------------------------------------------------------#
#----Control Event Handlers-----------------------------------#
#-------------------------------------------------------------#


function ping(){ 
    
    if($URL.Text -eq ""){
        $urlError.Text = "You have to provide an URL or IP"
        return
    }
    
     $urlError.Text = ""
    
    $result.Text =  "Pinging " + $URL.Text #Update the result label informing we are pinging
    
    [System.Windows.Forms.Application]::DoEvents() #Lets the UI to refresh, it's better to use runspaces which will be available in the next releases
    
    if(test-connection $URL.Text){
        $result.Text = $URL.Text + " is Online"
    }else{
         $result.Text = $URL.Text + " is not responding"
    }
}


function windowLoaded{
        write-host "loaded ..."
    
    
}

#endregion

#-------------------------------------------------------------#
#----Script Execution-----------------------------------------#
#-------------------------------------------------------------#

$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }
$State = [PSCustomObject]@{}


Function Set-Binding {
    Param($Target,$Property,$Index,$Name)
 
    $Binding = New-Object System.Windows.Data.Binding
    $Binding.Path = "["+$Index+"]"
    $Binding.Mode = [System.Windows.Data.BindingMode]::TwoWay
    


    [void]$Target.SetBinding($Property,$Binding)
}

function FillDataContext($props){

    For ($i=0; $i -lt $props.Length; $i++) {
   
   $prop = $props[$i]
   $DataContext.Add($DataObject."$prop")
   
    $getter = [scriptblock]::Create("return `$DataContext['$i']")
    $setter = [scriptblock]::Create("param(`$val) return `$DataContext['$i']=`$val")
    $State | Add-Member -Name $prop -MemberType ScriptProperty -Value  $getter -SecondValue $setter
               
       }
   }



$DataObject =  ConvertFrom-Json @"

{
    "data" : [
        {
            "name" : "poshgui.com",
            "lastChecked" : "Last check 4 minutes ago",
            "color" : "Green"
        },{
            "name" : "google.com",
            "lastChecked" : "Last check 6 minutes ago",
            "color" : "Red"
        },{
            "name" : "facebook.com",
            "lastChecked" : "Last check 7 minutes ago",
            "color" : "Green"
        },{
            "name" : "twitter.com",
            "lastChecked" : "Last check 8 minutes ago",
            "color" : "Red"
        }
        
        ]
}

"@

$DataContext = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
FillDataContext @("data") 

$Window.DataContext = $DataContext
Set-Binding -Target $kkwkgngptd1tl -Property $([System.Windows.Controls.ListView]::ItemsSourceProperty) -Index 0 -Name "data"





$kkwkgngptd1tl.Add_Loaded({windowLoaded $this $_})
$pingButton.Add_Click({ping $this $_})





$Global:SyncHash = [HashTable]::Synchronized(@{})
$Jobs = [System.Collections.ArrayList]::Synchronized([System.Collections.ArrayList]::new())
$initialSessionState = [initialsessionstate]::CreateDefault()

Function Start-RunspaceTask
{
    [CmdletBinding()]
    Param([Parameter(Mandatory=$True,Position=0)][ScriptBlock]$ScriptBlock,
          [Parameter(Mandatory=$True,Position=1)][PSObject[]]$ProxyVars)
            
    $Runspace = [RunspaceFactory]::CreateRunspace($InitialSessionState)
    $Runspace.ApartmentState = 'STA'
    $Runspace.ThreadOptions  = 'ReuseThread'
    $Runspace.Open()
    ForEach($Var in $ProxyVars){$Runspace.SessionStateProxy.SetVariable($Var.Name, $Var.Variable)}
    $Thread = [PowerShell]::Create('NewRunspace')
    $Thread.AddScript($ScriptBlock) | Out-Null
    $Thread.Runspace = $Runspace
    [Void]$Jobs.Add([PSObject]@{ PowerShell = $Thread ; Runspace = $Thread.BeginInvoke() })
}

$JobCleanupScript = {
    Do
    {    
        ForEach($Job in $Jobs)
        {            
            If($Job.Runspace.IsCompleted)
            {
                [Void]$Job.Powershell.EndInvoke($Job.Runspace)
                $Job.PowerShell.Runspace.Close()
                $Job.PowerShell.Runspace.Dispose()
                $Runspace.Powershell.Dispose()
                
                $Jobs.Remove($Runspace)
            }
        }

        Start-Sleep -Seconds 1
    }
    While ($SyncHash.CleanupJobs)
}

Get-ChildItem Function: | Where-Object {$_.name -notlike "*:*"} |  select name -ExpandProperty name |
ForEach-Object {       
    $Definition = Get-Content "function:$_" -ErrorAction Stop
    $SessionStateFunction = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList "$_", $Definition
    $InitialSessionState.Commands.Add($SessionStateFunction)
}


$Window.Add_Closed({
    Write-Verbose 'Halt runspace cleanup job processing'
    $SyncHash.CleanupJobs = $False
})

$SyncHash.CleanupJobs = $True
function Async($scriptBlock){ Start-RunspaceTask $scriptBlock @([PSObject]@{ Name='DataContext' ; Variable=$DataContext},[PSObject]@{Name="State"; Variable=$State})}

Start-RunspaceTask $JobCleanupScript @([PSObject]@{ Name='Jobs' ; Variable=$Jobs })



$Window.ShowDialog()


