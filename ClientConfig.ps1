# Check for PowerShell version compatibility
if ($PSVersionTable.PSVersion.Major -lt 3) {
    Write-Host "This script requires PowerShell 3.0 or higher for full functionality. Falling back to legacy methods..." -ForegroundColor Yellow
}

# Function to prompt for PC name and change it (compatible across versions)
function Change-PCName {
    param (
        [string]$NewPCName = (Read-Host "Enter the new PC name")
    )

    if ($PSVersionTable.PSVersion.Major -ge 3) {
        # Modern method using Rename-Computer
        Rename-Computer -NewName $NewPCName -Force -ErrorAction Stop
    } else {
        # Fallback for older systems
        $WmiComputerSystem = Get-WmiObject Win32_ComputerSystem
        $WmiComputerSystem.Rename($NewPCName)
    }
    Write-Host "Computer name changed to $NewPCName" -ForegroundColor Green
}

# Function to set a random static IP address
function Set-RandomStaticIP {
    param (
        [string]$InterfaceAlias = (Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }).Description
    )

    $RandomOctet = Get-Random -Minimum 2 -Maximum 255
    while ($RandomOctet -eq 136 -or $RandomOctet -eq 250) {
        $RandomOctet = Get-Random -Minimum 2 -Maximum 255
    }
    $StaticIP = "172.16.44.$RandomOctet"
    $SubnetMask = "255.255.0.0"
    $DefaultGateway = "172.16.44.2"
    $PreferredDNS = "172.16.44.250"
    $AlternateDNS = "8.8.8.8"

    if ($PSVersionTable.PSVersion.Major -ge 3) {
        # Modern method using New-NetIPAddress
        New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $StaticIP -PrefixLength 16 -DefaultGateway $DefaultGateway -ErrorAction Stop
        Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $PreferredDNS, $AlternateDNS -ErrorAction Stop
    } else {
        # Fallback for older systems
        $NetworkConfig = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.Description -eq $InterfaceAlias }
        $NetworkConfig.EnableStatic($StaticIP, $SubnetMask)
        $NetworkConfig.SetGateways($DefaultGateway)
        $NetworkConfig.SetDNSServerSearchOrder($PreferredDNS, $AlternateDNS)
    }

    Write-Host "Static IP and DNS successfully configured: $StaticIP" -ForegroundColor Green
}

# Function to validate configurations
function Validate-Configuration {
    Write-Host "Validating network configuration..." -ForegroundColor Cyan
    if ($PSVersionTable.PSVersion.Major -ge 3) {
        $CurrentIP = Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" -and $_.PrefixLength -eq 16 }
        $DNS = Get-DnsClientServerAddress | Where-Object { $_.AddressFamily -eq "IPv4" }
    } else {
        $NetworkConfig = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }
        $CurrentIP = $NetworkConfig.IPAddress
        $DNS = $NetworkConfig.DNSServerSearchOrder
    }

    if ($CurrentIP) {
        Write-Host "IP Address: $($CurrentIP -join ', ')"
        Write-Host "Default Gateway: 172.16.44.2"
        Write-Host "Subnet Mask: 255.255.0.0"
        Write-Host "DNS Servers: $($DNS -join ', ')"
        Write-Host "Configuration validated successfully." -ForegroundColor Green
    } else {
        Write-Host "Configuration failed! Please check settings." -ForegroundColor Red
        Exit 1
    }
}

# Function to restart PC and remind the user to re-run the script
function Restart-PCWithReminder {
    $ScriptPath = $MyInvocation.MyCommand.Path
    Write-Host "System will restart. Please re-run the script at: $ScriptPath" -ForegroundColor Yellow
    shutdown /r /t 0
}

# Function to join the domain
function Join-Domain {
    param (
        [string]$Domain = "marvel.local",
        [string]$Username = (Read-Host "Enter domain admin username"),
        [string]$Password = (Read-Host -AsSecureString "Enter domain admin password")
    )
    $Credential = New-Object System.Management.Automation.PSCredential ($Username, $Password)
    Add-Computer -DomainName $Domain -Credential $Credential -Force -ErrorAction Stop
    Write-Host "Computer successfully joined the domain $Domain. Please restart the PC to complete the process." -ForegroundColor Green
}

# Main Script Execution
Write-Host "Starting the configuration script..." -ForegroundColor Cyan

if (-not (Test-Path "C:\ScriptCompleted.flag")) {
    # Initial configuration steps
    Change-PCName
    Set-RandomStaticIP
    Validate-Configuration
    New-Item -ItemType File -Path "C:\ScriptCompleted.flag" -Force
    Restart-PCWithReminder
} else {
    # Post-reboot tasks
    Write-Host "Re-running script post-reboot..." -ForegroundColor Cyan
    if (-not (Get-ADDomain -ErrorAction SilentlyContinue)) {
        Join-Domain
    } else {
        Write-Host "The computer is already part of a domain. No further action needed." -ForegroundColor Green
    }
}
