function onSelect ($object,$event){
# write-host "select"  $object $event

$ButtonOK.isEnabled = $true

}
function onLinkClicked ($object,$event){

Start $object.NavigateUri
#$sharepointSitesList.height = $object.height-156

}

function onWindowSizeChanged ($object,$event){
$sharepointSitesList.width = $object.width-20
$sharepointSitesList.height = $object.height-156

}

function onWindowStateChanged ($object,$event){

$event

$sharepointSitesList.width = [System.Windows.SystemParameters]::WorkArea.Width
$sharepointSitesList.height = [System.Windows.SystemParameters]::WorkArea.Height-116

}

function onOK ($object,$event){
# write-host "OK clicked"

 Set-Variable -Name HexatownSelectedSite -Value $sharepointSitesList.selectedValue -Scope global
 Push-Location  $sharepointSitesList.selectedValue.webUrl
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
<Window
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Width="1000" Height="600" WindowState="Maximized"
HorizontalAlignment="Left" VerticalAlignment="Top" Margin="0,0,0,0" Background="orange" BorderThickness="0" BorderBrush="red" Foreground="green" OpacityMask="yellow" Name="MainWindow" WindowStartupLocation="CenterScreen" ResizeMode="CanResizeWithGrip" Title="jumpto365 Power-Bricks" WindowChrome.IsHitTestVisibleInChrome="True">
	<Grid Background="#eeeeee" ShowGridLines="False" Name="MainGrid">
		<Grid.RowDefinitions>
			<RowDefinition Height="50"/>
			<RowDefinition Height="13*"/>
			<RowDefinition Height="50"/>
		</Grid.RowDefinitions>
		<Grid.ColumnDefinitions>
			<ColumnDefinition Width="2*"/>
			<ColumnDefinition Width="8*"/>
		</Grid.ColumnDefinitions>
		<Border BorderBrush="#cccccc" BorderThickness="0" Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="2" Background="#eeeeee">
			<TextBox HorizontalAlignment="Right" VerticalAlignment="Center" Height="20" Width="300" TextWrapping="Wrap" Text="🔎 Search" Margin="10,10,10,10"  Visibility="Hidden"/>
		</Border>
		<StackPanel Background="#ffffff" SnapsToDevicePixels="True" Grid.Row="1" Grid.Column="0">
			<Button Content="PowerBricks" HorizontalContentAlignment ="Left" Padding="10,0,0,10" VerticalAlignment="Top" Height="40" Background="#eeeeee"   BorderThickness="0,0,0,0" FontWeight="Bold" Foreground="#333" Name="Tab1BT"/>
			<Button Content="SharePoint"  HorizontalContentAlignment ="Left" Padding="10,0,0,10" VerticalAlignment="Top" Height="40" Background="#eeeeee" BorderThickness="0,0,0,0" FontWeight="Bold" Foreground="#333" Name="Tab2BT"/>
			<Button Content="Hosts"  HorizontalContentAlignment ="Left" Padding="10,0,0,10" VerticalAlignment="Top" Height="40" Background="#eeeeee" BorderThickness="0,0,0,0" FontWeight="Bold" Foreground="#333" Name="Tab3BT" />
			<Button Content="Tab 4" HorizontalContentAlignment ="Left" Padding="10,0,0,10"  VerticalAlignment="Top" Height="40" Background="#eeeeee" BorderThickness="0,0,0,0" FontWeight="Bold" Foreground="#333" Name="Tab4BT" Visibility="Hidden"/>
			<Button Content="About"  HorizontalContentAlignment ="Left" Padding="10,0,0,10" VerticalAlignment="Top" Height="40" Background="#eeeeee" BorderThickness="0,0,0,0" FontWeight="Bold" Foreground="#333" Name="Tab5BT" />
			<Image Height="100" Width="170" Name="Icon" SnapsToDevicePixels="True" Source="https://avatars.githubusercontent.com/u/25307176" Margin="0,10,0,10" VerticalAlignment="Bottom"  Visibility="Hidden"/>
		</StackPanel>
		<StackPanel Grid.Row="2" Grid.ColumnSpan="2" Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Top">
			<Button Content="Cancel" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="10,10,10,10" Name="ButtonCancel" IsCancel="True" />
			<Button Content="OK" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="10,10,10,10" Name="ButtonOK" IsDefault="True" IsEnabled="False"/>
		</StackPanel>
		<TabControl Grid.Row="1" Grid.Column="1" Padding="-1" Name="TabNav" SelectedIndex="0">
			<TabItem Header="Tab 1" Visibility="Collapsed" Name="Tab1">
				<Grid Background="#eeeeee" ShowGridLines="False" Name="PowerBricksGrid">
					<Grid.RowDefinitions>
						<RowDefinition Height="50" />
						<RowDefinition Height="13*"/>
					</Grid.RowDefinitions>
					<Grid.ColumnDefinitions>
						<ColumnDefinition Width="50*"/>
		
			                <ColumnDefinition Width="5*"/>
					</Grid.ColumnDefinitions>
					<StackPanel  Grid.Row="0" Grid.ColumnSpan="1"  HorizontalAlignment="Left" VerticalAlignment="Top" Background="#eeeeee"  Orientation="Horizontal"      >
						<Button Content="Edit" HorizontalAlignment="Left" VerticalAlignment="Top" Width="100" Margin="10,10,10,10" Name="PbEditButton"  />
                        <Button Content="Environments" HorizontalAlignment="Left" VerticalAlignment="Top" Width="100" Margin="10,10,10,10" Name="PbEnvironmentsButton"  />
                        <Button Content="Publish" HorizontalAlignment="Left" VerticalAlignment="Top" Width="100" Margin="10,10,10,10" Name="PbPublishButton"  />
						<Button Content="OK" HorizontalAlignment="Left" VerticalAlignment="Top" Width="100" Margin="10,10,10,10" Name="PbButtonOK"  IsEnabled="False"/>
					</StackPanel >
					<StackPanel  Grid.Row="0" Grid.ColumnSpan="1"  HorizontalAlignment="Right" VerticalAlignment="Top" Background="#eeeeee"  Orientation="Horizontal"      >
						
						<Button Content="New" HorizontalAlignment="Right" VerticalAlignment="Top" Width="100" Margin="10,10,10,10" Name="PbButtonNew"/>
					</StackPanel >
					<DockPanel  Grid.Row="1" Grid.ColumnSpan="2"  HorizontalAlignment="Stretch" Background="#ff0000"  VerticalAlignment="Stretch"  >

    
    
						<ListView ItemsSource="{Binding data}" Name="sharepointSitesList"  SelectionMode="Single">
							<ListView.ItemTemplate>
								<DataTemplate>
									<StackPanel Orientation="Horizontal" Height="69"  FocusManager.FocusedElement="{Binding ElementName=Item}">
										
										<StackPanel Orientation="Vertical" VerticalAlignment="Center" Margin="12,0,0,0" Name="Item">
											<TextBlock Text="{Binding displayName}" FontWeight="Semibold" Name="klryc3uxs0ho7" FontSize="22"/>
											<TextBlock Text="{Binding webURL}" Name="klryc3ux1xv9s"/>
										</StackPanel>
									</StackPanel>
								</DataTemplate>
							</ListView.ItemTemplate>
						</ListView>
					</DockPanel >
				</Grid>
			</TabItem>
			<TabItem Header="Tab 2" Visibility="Collapsed" Name="Tab2">
				<Grid Background="#ffffff">
					<TextBlock HorizontalAlignment="Center" VerticalAlignment="Top" TextWrapping="Wrap" Text="SharePoint" FontSize="14" FontWeight="Bold" Height="21" Foreground="#333"/>


				</Grid>
			</TabItem>
			<TabItem Header="Tab 3" Visibility="Collapsed" Name="Tab3">
				<Grid Background="#262335">
					<TextBlock HorizontalAlignment="Center" VerticalAlignment="Top" TextWrapping="Wrap" Text="Tab 3" FontSize="14" FontWeight="Bold" Height="21" Foreground="#ffffff"/>
				</Grid>
			</TabItem>
			<TabItem Header="Tab 4" Visibility="Collapsed" Name="Tab4">
				<Grid Background="#262335">
					<TextBlock HorizontalAlignment="Center" VerticalAlignment="Top" TextWrapping="Wrap" Text="Tab 4" FontSize="14" FontWeight="Bold" Height="21" Foreground="#ffffff"/>
				</Grid>
			</TabItem>
			<TabItem Header="Tab 5" Visibility="Collapsed" Name="Tab5">
				<Grid Background="#ffffff">
		<Grid.RowDefinitions>
			
			<RowDefinition Height="13*"/>
			
		</Grid.RowDefinitions>
		<Grid.ColumnDefinitions>
			<ColumnDefinition Width="5*"/>
			<ColumnDefinition Width="5*"/>
		</Grid.ColumnDefinitions>

<Image Grid.Row="0" Grid.Column="0" HorizontalAlignment="Left"  VerticalAlignment="Top"  Margin="10,10,10,10" Source="$PSScriptRoot\Niels 2021 Proff Head shot.png" />
<StackPanel  Grid.Row="0" Grid.Column="1"  >
					<TextBlock  TextWrapping="Wrap" Padding="10,10,10,10" Text="PowerBricks, Hexatown &amp; jumpto365" FontSize="24" FontWeight="Bold" Foreground="#333"
/>
					<TextBlock  TextWrapping="Wrap" Padding="10,10,10,10" Text="Niels is a self-taught IT engineer who was introduced to Microsoft tools when DOS 1.1 was born in the 1980s. His focus is bridging the technical gap between as-is and to-be platforms, with as much time spent on coding as possible. Niels is the brains behind the web version of the Periodic Table of Office 365." FontSize="16" FontWeight="Bold" Foreground="#333"/>
    <TextBlock>
   <Hyperlink NavigateUri="https://jumpto365.com" Name="link1">
   jumpto365.com
   </Hyperlink>
   <Hyperlink NavigateUri="https://github.com/hexatown" Name="link2">
   github.com/hexatown
   </Hyperlink>
   <Hyperlink NavigateUri="https://jumpto365.com/powerbricks" Name="link3">
   power-bricks.com
   </Hyperlink>

</TextBlock>
</StackPanel >                    
                    
                    
				</Grid>
			</TabItem>
		</TabControl>
	</Grid>
</Window>

"@

#-------------------------------------------------------------#
#----Control Event Handlers-----------------------------------#
#-------------------------------------------------------------#


#Visit the link below for the full script
#https://gist.github.com/VV-B0Y/2119ad9df729a766ce5bede7eb194c56

#Write your code here
Function Tab1Click() {
	$TabNav.SelectedItem = $Tab1
}
Function Tab2Click() {
	$TabNav.SelectedItem = $Tab2
}
Function Tab3Click() {
	$TabNav.SelectedItem = $Tab3
}
Function Tab4Click() {
	$TabNav.SelectedItem = $Tab4
}
Function Tab5Click() {
	$TabNav.SelectedItem = $Tab5
}
#endregion

#-------------------------------------------------------------#
#----Script Execution-----------------------------------------#
#-------------------------------------------------------------#

$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }


$Tab1BT.Add_Click({Tab1Click $this $_})
$Tab2BT.Add_Click({Tab2Click $this $_})
$Tab3BT.Add_Click({Tab3Click $this $_})
$Tab4BT.Add_Click({Tab4Click $this $_})
$Tab5BT.Add_Click({Tab5Click $this $_})

$sharepointSitesList.Add_SelectionChanged({onSelect $this $_})
$ButtonOK.Add_Click({onOK $this $_})
$ButtonCancel.Add_Click({onCancel $this $_})
$link1.Add_Click({onLinkClicked $this $_})
$link2.Add_Click({onLinkClicked $this $_})
$link3.Add_Click({onLinkClicked $this $_})




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

$environmentPath = $env:HEXATOWNHOME
if ($null -eq $environmentPath ) {
    $environmentPath = ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonApplicationData)) 
}


$powerBricks = get-content -Path "$environmentPath\hexatown.com\.hexatown\powerbricks.json" | ConvertFrom-Json 
$powerBricks = $powerBricks | Sort-Object name

function pbDisplayName($pb){
if ($null -ne $pb.alias){
    return "$($pb.name) ($($pb.alias))"
}else{
return "$($pb.name)"
}
}

$max = $powerBricks.Count

$comma = ""
for ($i = 0; $i -lt $max ; $i++)
{ 
    $powerBrick = $powerBricks[$i]

    $data += "$comma{`"displayName`" : `"$(pbDisplayName $powerBrick)`", `"webURL`" : `"$($powerBrick.path.Replace("\","\\"))`", `"Color`" : `"Green`"}"
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



$sharepointSitesList.Focus()
$sharepointSitesList.SelectedIndex=0




$Global:SyncHash = [HashTable]::Synchronized(@{})
$Jobs = [System.Collections.ArrayList]::Synchronized([System.Collections.ArrayList]::new())
$initialSessionState = [initialsessionstate]::CreateDefault()

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


