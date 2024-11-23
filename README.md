# TCM-Cient-Script
A personal powershell script that I use to setup virtual clients to follow along with TCM Security's pentesting course. This script can be used to automate any basic windows client to Server/Domain setup.

Windows Configuration Script
Features

This PowerShell script automates system configuration tasks with compatibility for older and modern Windows systems, ensuring functionality across Windows 7, 8, 10, and 11. Below are the key features:
1. Change Computer Name

    Prompts the user for a new computer name.
    Uses modern cmdlets (Rename-Computer) or a fallback method via WMI for older systems.

2. Set Random Static IP Address

    Automatically generates a random static IP address.
    Excludes specific IPs (x.x.x.136 and x.x.x.250) as per user-defined constraints.
    Configures:
        Subnet Mask: 255.255.0.0
        Default Gateway: 172.16.44.2
        Preferred DNS: 172.16.44.250
        Alternate DNS: 8.8.8.8
    Supports modern (New-NetIPAddress) and legacy (Win32_NetworkAdapterConfiguration) methods.

3. Validation of Network Configuration

    Verifies that the IP, Subnet Mask, Default Gateway, and DNS settings were applied correctly.
    Outputs the current network configuration for user confirmation.
    Exits the script if configuration errors are detected.

4. Handles System Restarts Gracefully

    Restarts the system after the initial configuration.
    Reminds the user to re-run the script post-reboot.
    Optionally integrates with Task Scheduler for automatic re-runs upon reboot.

5. Join a Domain (marvel.local)

    Prompts the user to join the specified domain.
    Accepts domain admin credentials (username and password) for authentication.
    Verifies if the system is already part of a domain to prevent redundant actions.

6. Backward Compatibility

    Fully compatible with:
        Windows 7 and PowerShell 2.0+
        Windows 8, 10, and 11 with newer PowerShell versions.
    Implements legacy WMI methods for systems where modern cmdlets are unavailable.

7. Error Handling

    Gracefully handles missing cmdlets or incompatible methods.
    Provides clear feedback if configuration tasks fail.
    Logs and exits safely when unrecoverable issues are detected.

8. Script Execution Flow

    The script creates a checkpoint (C:\ScriptCompleted.flag) to ensure tasks are performed sequentially across reboots:
        First Run: Changes PC name, configures network, and reboots the system.
        Second Run: Prompts the user to join the domain and completes the setup.

Additional Notes

    Compatible with both PowerShell Core and Windows PowerShell.
    Built with reliability and minimal user intervention in mind.
    Easily customizable for different environments or network configurations.

Feel free to reach out for further customizations or enhancements! 😊
