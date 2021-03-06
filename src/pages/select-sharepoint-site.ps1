param ($SharePointSites)

function onSelect ($object,$event){
# write-host "select"  $object $event
$ButtonOK.isEnabled = $true

}

function onWindowSizeChanged ($object,$event){
$sharepointSitesList.width = $object.width
$sharepointSitesList.height = $object.height-116

}

function onOK ($object,$event){
# write-host "OK clicked"


 Set-Variable -Name HexatownSelectedSite -Value $sharepointSitesList.selectedValue -Scope global
$mainWindow.DialogResult = $true
$mainWindow.Close()
}

function onCancel ($object,$event){
# write-host "Cancel clicked"

$mainWindow.DialogResult = $false
$mainWindow.Close()
}

#-------------------------------------------------------------#
#----Initial Declarations-------------------------------------#
#-------------------------------------------------------------#

Add-Type -AssemblyName PresentationCore, PresentationFramework

$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Width="1024" Height="800" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="0,0,0,0" Name="mainWindow" >
  <Grid>
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        
    </Grid.ColumnDefinitions>
    <Grid.RowDefinitions>
        <RowDefinition Height="66"/>
        <RowDefinition Height="*"/>
        
        <RowDefinition Height="50"/>
    </Grid.RowDefinitions>
    
<Border BorderBrush="Black" BorderThickness="1" Background="#3677c5" Grid.ColumnSpan="2">    
<TextBlock TextWrapping="Wrap" Text="PowerBrick configuration" Foreground="#ffffff" FontSize="24" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/>
</Border>


        
    <StackPanel Grid.Row="1" Grid.ColumnSpan="1" Orientation="Horizontal" HorizontalAlignment="Left" VerticalAlignment="Top">
      <ListView ItemsSource="{Binding data}" Name="sharepointSitesList" Width="587" Height="200" SelectionMode="Single">
        <ListView.ItemTemplate>
          <DataTemplate>
            <StackPanel Orientation="Horizontal" Height="69">
              <Ellipse Height="40" Width="40" Fill="{Binding Color}" VerticalAlignment="Center" Name="klryc3uw0q6bc"/>
              <StackPanel Orientation="Vertical" VerticalAlignment="Center" Margin="12,0,0,0">
              
                <TextBlock Text="{Binding displayName}" FontWeight="Semibold" Name="klryc3uxs0ho7"/>
                <TextBlock Text="{Binding webURL}" Name="klryc3ux1xv9s"/>
              </StackPanel> 
            </StackPanel>
          </DataTemplate>
        </ListView.ItemTemplate>
      </ListView>
    </StackPanel>
    <StackPanel Grid.Row="2" Grid.ColumnSpan="1" Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Top">
    <Button Content="Cancel" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="10,10,10,10" Name="ButtonCancel" />
    <Button Content="OK" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="10,10,10,10" Name="ButtonOK" IsDefault="True" IsEnabled="False"/>
    </StackPanel>
  </Grid>
</Window>

"@

#-------------------------------------------------------------#
#----Control Event Handlers-----------------------------------#
#-------------------------------------------------------------#


function welcome(){
    $State.status = "Welcome " + $State.userInput
}
#endregion

#-------------------------------------------------------------#
#----Script Execution-----------------------------------------#
#-------------------------------------------------------------#

$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }


$sharepointSitesList.Add_SelectionChanged({onSelect $this $_})
$mainWindow.Add_SizeChanged({onWindowSizeChanged $this $_})
$ButtonOK.Add_Click({onOK $this $_})
$ButtonCancel.Add_Click({onCancel $this $_})

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

$data = ""

$max = $SharePointSites.Count

$comma = ""
for ($i = 0; $i -lt $max ; $i++)
{ 
    $site = $SharePointSites[$i]

    $data += "$comma{`"displayName`" : `"$($site.displayName)`", `"webURL`" : `"$($site.webUrl)`", `"Color`" : `"Green`"}"
    $comma = ","
    
}

$dataText  = @"
 {
  "data": [
$data
  ]
}

"@

$DataObject =  ConvertFrom-Json $dataText 




$DataContext = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
FillDataContext @("data") 

$Window.DataContext = $DataContext
Set-Binding -Target $sharepointSitesList -Property $([System.Windows.Controls.ListView]::ItemsSourceProperty) -Index 0 -Name "data"







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

Start-RunspaceTask $JobCleanupScript @([PSObject]@{ Name='Jobs' ; Variable=$Jobs }) | Out-Null



$result = $Window.ShowDialog()
if ($result){
    return $HexatownSelectedSite
}else{
    return $null
}



