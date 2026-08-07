Add-Type -AssemblyName PresentationFramework -ErrorAction Stop
try { Import-Module "$env:SystemRoot\System32\WindowsPowerShell\v1.0\Modules\ActiveDirectory\ActiveDirectory.psd1" -ErrorAction Stop }
catch {
    [Windows.MessageBox]::Show('Active Directory tools are unavailable. Verify RSAT and try again.',
        'Active Directory Investigation Console', 'OK', 'Error') | Out-Null
    return
}

$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Active Directory Investigation Console"
        Width="1040" Height="630" MinWidth="900" MinHeight="550"
        WindowStartupLocation="CenterScreen"
        Background="#F4F6F8" FontFamily="Segoe UI" FontSize="13">
    <Window.Resources>
        <Style x:Key="Card" TargetType="Border"><Setter Property="Background" Value="White"/><Setter Property="BorderBrush" Value="#D7DEE8"/><Setter Property="BorderThickness" Value="1"/><Setter Property="CornerRadius" Value="8"/><Setter Property="Padding" Value="22"/></Style>
        <Style x:Key="Input" TargetType="TextBox"><Setter Property="Height" Value="38"/><Setter Property="Padding" Value="10,7"/><Setter Property="BorderBrush" Value="#CBD5E1"/><Setter Property="VerticalContentAlignment" Value="Center"/></Style>
        <Style x:Key="Primary" TargetType="Button"><Setter Property="Height" Value="38"/><Setter Property="Background" Value="#2563EB"/><Setter Property="Foreground" Value="White"/><Setter Property="BorderThickness" Value="0"/><Setter Property="FontWeight" Value="SemiBold"/></Style>
        <Style x:Key="Secondary" TargetType="Button"><Setter Property="Height" Value="36"/><Setter Property="Padding" Value="15,0"/><Setter Property="Background" Value="White"/><Setter Property="BorderBrush" Value="#CBD5E1"/><Setter Property="Foreground" Value="#334155"/></Style>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions><RowDefinition Height="88"/><RowDefinition Height="*"/></Grid.RowDefinitions>

        <Border Grid.Row="0" Background="White" BorderBrush="#D7DEE8" BorderThickness="0,0,0,1">
            <TextBlock Text="Active Directory Investigation Console" FontSize="23" FontWeight="SemiBold" Foreground="#0F172A"
                       HorizontalAlignment="Center" VerticalAlignment="Center"/>
        </Border>

        <Grid Grid.Row="1" Margin="28,22,28,28">
            <Grid.ColumnDefinitions><ColumnDefinition Width="370"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>

            <Border Grid.Column="0" Style="{StaticResource Card}">
                <StackPanel>
                    <TextBlock Text="LOOKUPS" FontSize="11" FontWeight="Bold" Foreground="#64748B" Margin="0,0,0,18"/>

                    <TextBlock Text="User Lookup" FontSize="14" FontWeight="SemiBold"/>
                    <TextBlock Text="Exact eRaider ID or email address" FontSize="11" Foreground="#64748B" Margin="0,4,0,8"/>
                    <DockPanel>
                        <Button x:Name="UserButton" DockPanel.Dock="Right" Width="80" Content="Search" Margin="8,0,0,0" Style="{StaticResource Primary}"/>
                        <TextBox x:Name="UserInput" Style="{StaticResource Input}" MaxLength="256"/>
                    </DockPanel>

                    <Border Height="1" Background="#E2E8F0" Margin="0,19"/>
                    <TextBlock Text="Device Lookup" FontSize="14" FontWeight="SemiBold"/>
                    <TextBlock Text="Exact computer name" FontSize="11" Foreground="#64748B" Margin="0,4,0,8"/>
                    <DockPanel>
                        <Button x:Name="DeviceButton" DockPanel.Dock="Right" Width="80" Content="Search" Margin="8,0,0,0" Style="{StaticResource Primary}"/>
                        <TextBox x:Name="DeviceInput" Style="{StaticResource Input}" MaxLength="64"/>
                    </DockPanel>

                    <Border Height="1" Background="#E2E8F0" Margin="0,19"/>
                    <TextBlock Text="Firewall / AD Lookup" FontSize="14" FontWeight="SemiBold"/>
                    <TextBlock Text="Username, computer name, AD group, or OU name" FontSize="11" Foreground="#64748B" Margin="0,4,0,8"/>
                    <DockPanel>
                        <Button x:Name="GroupButton" DockPanel.Dock="Right" Width="80" Content="Search" Margin="8,0,0,0" Style="{StaticResource Primary}"/>
                        <TextBox x:Name="GroupInput" Style="{StaticResource Input}" MaxLength="256"/>
                    </DockPanel>
                </StackPanel>
            </Border>

            <Border Grid.Column="1" Margin="20,0,0,0" Style="{StaticResource Card}">
                <Grid>
                    <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                    <Grid>
                        <TextBlock Text="RESULT" FontSize="11" FontWeight="Bold" Foreground="#64748B"/>
                        <Border x:Name="StatusBadge" HorizontalAlignment="Right" Background="#F1F5F9" CornerRadius="12" Padding="11,4">
                            <TextBlock x:Name="StatusBadgeText" Text="READY" FontSize="10" FontWeight="Bold" Foreground="#475569"/>
                        </Border>
                    </Grid>
                    <TextBlock x:Name="ResultTitle" Grid.Row="1" Text="Ready for a lookup" Margin="0,22,0,10" FontSize="18" FontWeight="SemiBold"/>
                    <TextBox x:Name="ResultText" Grid.Row="2" IsReadOnly="True"
                             Text="Go Hunt."
                             TextWrapping="Wrap" VerticalScrollBarVisibility="Auto" Padding="14"
                             Background="#F8FAFC" BorderBrush="#D7DEE8" FontFamily="Consolas" FontSize="12.5"/>
                    <StackPanel Grid.Row="3" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,16,0,0">
                        <Button x:Name="CopyButton" Content="Copy Result" IsEnabled="False" Style="{StaticResource Secondary}"/>
                        <Button x:Name="ClearButton" Content="Clear" Margin="8,0,0,0" Style="{StaticResource Secondary}"/>
                    </StackPanel>
                </Grid>
            </Border>
        </Grid>
    </Grid>
</Window>
'@

$window = [Windows.Markup.XamlReader]::Parse($xaml)

$UserInput = $window.FindName('UserInput');       $UserButton = $window.FindName('UserButton')
$DeviceInput = $window.FindName('DeviceInput');   $DeviceButton = $window.FindName('DeviceButton')
$GroupInput = $window.FindName('GroupInput');     $GroupButton = $window.FindName('GroupButton')
$StatusBadge = $window.FindName('StatusBadge');   $StatusBadgeText = $window.FindName('StatusBadgeText')
$ResultTitle = $window.FindName('ResultTitle');   $ResultText = $window.FindName('ResultText')
$CopyButton = $window.FindName('CopyButton');     $ClearButton = $window.FindName('ClearButton')

$brush = New-Object Windows.Media.BrushConverter
$styles = @{ Ready = @('#F1F5F9','#475569','READY'); Success = @('#DCFCE7','#166534','FOUND'); Warning = @('#FEF3C7','#92400E','REVIEW'); Error = @('#FEE2E2','#991B1B','ERROR') }
function Set-Result($State, $Title, $Text) {
    $style = $styles[$State]
    $StatusBadge.Background = $brush.ConvertFromString($style[0])
    $StatusBadgeText.Foreground = $brush.ConvertFromString($style[1])
    $StatusBadgeText.Text = $style[2]
    $ResultTitle.Text = $Title
    $ResultText.Text = $Text
    $CopyButton.IsEnabled = $State -eq 'Success'
}

function Get-OuInfo($dn) {
    $ous = @($dn -split '(?<!\\),' | Where-Object { $_ -like 'OU=*' } | ForEach-Object { $_.Substring(3).Replace('\,', ',') })
    if (-not $ous) { return @('Not available', 'Not available') }
    $path = @($ous); [array]::Reverse($path); @($ous[-1], ($path -join ' > '))
}

$UserButton.Add_Click({
    $value = $UserInput.Text.Trim()
    if (-not $value) { Set-Result Warning 'Input required' 'Enter an eRaider or email address.'; return }

    try {
        $users = @(Get-ADUser -Filter { SamAccountName -eq $value -or mail -eq $value -or UserPrincipalName -eq $value } -Properties Department,mail -ResultSetSize 2 -ErrorAction Stop)
        if ($users.Count -ne 1) { Set-Result Warning 'User not found' 'No unique user matched that eRaider or email address.'; return }

        $user = $users[0]
        $department = if ($user.Department) { $user.Department } else { 'Not available' }
        $email = if ($user.mail) { $user.mail } else { 'Not available' }
        $ou = Get-OuInfo $user.DistinguishedName
        $text = "eRaider            : $($user.SamAccountName)`r`nDepartment         : $department`r`nEmail              : $email"
        if ($ou[1] -ne 'Not available') { $text += "`r`nOU Path            : $($ou[1])" }
        $text += "`r`nDistinguished Name : $($user.DistinguishedName)"
        Set-Result Success 'User found' $text
    }
    catch { Set-Result Error 'User lookup failed' 'Active Directory could not complete the lookup.' }
})

$DeviceButton.Add_Click({
    $name = $DeviceInput.Text.Trim()
    if (-not $name) { Set-Result Warning 'Input required' 'Enter a computer name.'; return }

    try {
        $computer = Get-ADComputer -Identity $name -ErrorAction Stop
        $ou = Get-OuInfo $computer.DistinguishedName
        $text = "Computer Name      : $($computer.Name)`r`nDepartment         : $($ou[0])`r`nOU Path            : $($ou[1])`r`nDistinguished Name : $($computer.DistinguishedName)"
        Set-Result Success 'Computer found' $text
    }
    catch { Set-Result Error 'Computer lookup failed' 'The computer was not found.' }
})

$GroupButton.Add_Click({
    $value = $GroupInput.Text.Trim()
    if (-not $value) { Set-Result Warning 'Input required' 'Enter a username, computer name, AD group, or OU name.'; return }

    try {
        $objects = @(Get-ADObject -Filter { (ObjectClass -eq 'user' -or ObjectClass -eq 'computer' -or ObjectClass -eq 'group' -or ObjectClass -eq 'organizationalUnit') -and (Name -eq $value -or SamAccountName -eq $value) } -Properties SamAccountName -ResultSetSize 2 -ErrorAction Stop)
        if ($objects.Count -eq 0) { Set-Result Warning 'Not found' 'No user, computer, AD group, or OU matched that exact input.'; return }
        if ($objects.Count -gt 1) {
            $result = ($objects | ForEach-Object { "$($_.ObjectClass) : $($_.Name)`r`n$($_.DistinguishedName)" }) -join "`r`n`r`n"
            Set-Result Warning 'Multiple AD objects found' $result
            return
        }

        $object = $objects[0]
        $ou = Get-OuInfo $object.DistinguishedName
        switch ($object.ObjectClass) {
            'user'               { $type = 'User';     $label = 'Username';      $name = $object.SamAccountName }
            'computer'           { $type = 'Computer'; $label = 'Computer Name'; $name = $object.Name }
            'group'              { $type = 'Group';    $label = 'Group Name';    $name = $object.Name }
            'organizationalUnit' { $type = 'OU';       $label = 'OU Name';       $name = $object.Name }
        }

        $result = "Type               : $type`r`n$($label.PadRight(18)) : $name"
        if ($ou[1] -ne 'Not available') { $result += "`r`nOU Path            : $($ou[1])" }
        $result += "`r`nDistinguished Name : $($object.DistinguishedName)"
        Set-Result Success 'Firewall lookup result' $result
    }
    catch { Set-Result Error 'Firewall lookup failed' 'Active Directory could not complete the lookup.' }
})

$CopyButton.Add_Click({ [Windows.Clipboard]::SetText($ResultText.Text) })

$ClearButton.Add_Click({
    $UserInput.Clear(); $DeviceInput.Clear(); $GroupInput.Clear()
    Set-Result Ready 'Ready for a lookup' 'Go Hunt.'
})

$window.Add_ContentRendered({ $UserInput.Focus() | Out-Null })
[void]$window.ShowDialog()
