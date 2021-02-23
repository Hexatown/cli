
#-------------------------------------------------------------#
#----Initial Declarations-------------------------------------#
#-------------------------------------------------------------#
$imageFolder = Join-Path $PSScriptRoot "img"
Add-Type -AssemblyName PresentationCore, PresentationFramework
# https://qiita.com/karuakun/items/aba6caf4cdf4684ea970
# https://developer.microsoft.com/en-us/microsoft-edge/webview2/
##https://go.microsoft.com/fwlink/p/?LinkId=2124703
<#

<Window.Resources>
  
  
  
  <wv2:CoreWebView2CreationProperties x:Key="FixedWebView2CreationProperties" 
  BrowserExecutableFolder="C:\ProgramData\hexatown.com\.hexatown\extensions\Microsoft.WebView2.FixedVersionRuntime.88.0.705.63.x64\"/>

  </Window.Resources>
#>
$Xaml = @"
<Window 
 xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
 xmlns:local="clr-namespace:SampleApp"
 xmlns:wv2="clr-namespace:Microsoft.Web.WebView2.Wpf;assembly=Microsoft.Web.WebView2.Wpf"
 Title="Hexatown Power*Bricks by jumpto365" 
 Width="713" 
 Height="335" 
 HorizontalAlignment="Left" 
 VerticalAlignment="Top" 
 Margin="0,0,0,0" 
 Name="kkwkgngptd1tl">
 
  <Grid Margin="0,-1,0,1">
     
                          
                      

    <Grid.Background>
      <ImageBrush ImageSource="$imageFolder/JUMPTOH POWERBRICKS.png" Stretch="UniformToFill"/>
    </Grid.Background>
    <Grid.RowDefinitions>
      <RowDefinition Height="66"/>
      <RowDefinition Height="109"/>
      <RowDefinition Height="0.5735294117647058*"/>
    </Grid.RowDefinitions>
    <Grid.ColumnDefinitions>
      <ColumnDefinition Width="0.5778222979064409*"/>
      <ColumnDefinition Width="0.4229181167108753*"/>
    </Grid.ColumnDefinitions>
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


$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }

$Window.ShowDialog()