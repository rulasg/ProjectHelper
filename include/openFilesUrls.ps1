function Open-Url {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Url
    )

    process {
        try {
            # Determine the operating system
            if ($IsWindows -or $env:OS -match "Windows") {
                # Windows - use Start-Process
                Start-Process $Url
            }
            elseif ($IsMacOS) {
                # macOS - use open command
                Start-Process "open" -ArgumentList $Url
            }
            elseif ($IsLinux) {
                # Linux - try xdg-open
                Start-Process "xdg-open" -ArgumentList $Url
            }
            else {
                # Fallback for older PowerShell versions without OS variables
                switch ([System.Environment]::OSVersion.Platform) {
                    "Win32NT" {
                        Start-Process $Url
                    }
                    "Unix" {
                        # Try to determine if macOS or Linux
                        if (Test-Path "/System/Library/CoreServices/Finder.app") {
                            # macOS
                            Start-Process "open" -ArgumentList $Url
                        }
                        else {
                            # Assume Linux
                            Start-Process "xdg-open" -ArgumentList $Url
                        }
                    }
                    default {
                        throw "Unsupported operating system"
                    }
                }
            }
        }
        catch {
            Write-Error "Failed to open URL: $_"
        }
    }
}

function Open-File {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    process {
        try {
            # Ensure the file exists
            if (-not (Test-Path -Path $Path)) {
                throw "File not found: $Path"
            }

            # Get absolute path
            $absolutePath = (Resolve-Path -Path $Path).Path

            # Determine the operating system
            if ($IsWindows -or $env:OS -match "Windows") {
                # Windows - use Invoke-Item
                Invoke-Item -Path $absolutePath
            }
            elseif ($IsMacOS) {
                # macOS - use open command
                Start-Process "open" -ArgumentList $absolutePath
            }
            elseif ($IsLinux) {
                # Linux - try xdg-open
                Start-Process "xdg-open" -ArgumentList $absolutePath
            }
            else {
                # Fallback for older PowerShell versions without OS variables
                switch ([System.Environment]::OSVersion.Platform) {
                    "Win32NT" {
                        Invoke-Item -Path $absolutePath
                    }
                    "Unix" {
                        # Try to determine if macOS or Linux
                        if (Test-Path "/System/Library/CoreServices/Finder.app") {
                            # macOS
                            Start-Process "open" -ArgumentList $absolutePath
                        }
                        else {
                            # Assume Linux
                            Start-Process "xdg-open" -ArgumentList $absolutePath
                        }
                    }
                    default {
                        throw "Unsupported operating system"
                    }
                }
            }
        }
        catch {
            Write-Error "Failed to open file: $_"
        }
    }
} Export-ModuleMember -Function 'Open-File'
