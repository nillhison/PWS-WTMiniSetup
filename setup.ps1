# Run this file: powershell -ExecutionPolicy Bypass .\setup.ps1

# View the profile files and its scopes: $PROFILE | Select-Object *

# Set the execution policy to RemoteSigned in order to perform the setup
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

class AppInfo {

    [string]$id
    [string]$exe
    [string]$name
    [string]$scope

    AppInfo([string]$appId, [string]$appExe, [string]$appName, [string]$appScope) {
        $this.id = $appId
        $this.exe = $appExe
        $this.name = $appName
        $this.scope = $appScope
    }

    [string] Exe() {
        return $this.exe
    }

    [string] Id() {
        return $this.id
    }

    [string] Name() {
        return $this.name
    }
    
    [string] Scope() {
      return $this.scope
    }

}

class InstallRequired {

    [void] Modules([string[]]$modules) {
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        foreach($module in $modules) {
            if (-not (Get-Module -ListAvailable -Name $module)) {
                try {
                    Install-Module -Name $module -Force -Scope CurrentUser
                } catch {
                    Write-Error "Failed to install module $module. Error: $_"
                }
            } else {
                Write-Host "Module $module is already installed"
            }
        }
    }

    [void] Applications([AppInfo[]]$applications) {
        foreach($application in $applications) {
            if (-not (Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq $application.Name })) {
                try {
                    winget install --id $application.Id -e --source winget -scope $application.Scope
                } catch {
                    Write-Error "Failed to install application. Error: $_"
                }
            } else {
                Write-Host "Application $applicatio.Name is already installed"
            }
        }
    }

}

$install = [InstallRequired]::new()

$mdls = @(
    "Terminal-Icons",
    "PSReadLine",
    "posh-git"
)

$apps = @(
    [AppInfo]::new('git', 'Git.Git', 'Git', 'machine'),
    [AppInfo]::new('gh', 'GitHub.cli', 'GitHub CLI' 'machine'),
    [AppInfo]::new('code', 'Microsoft.VisualStudioCode', 'Microsoft Visual Studio Code', 'user'),
    [AppInfo]::new('oh-my-posh', 'JanDeDobbeleer.OhMyPosh', 'Oh My Posh', 'user')
)


$install.Modules($mdls)
$install.Applications($apps)

$env:Path += ";APPDATA\Local\Programs\oh-my-posh\bin"
oh-my-posh font install meslo

# Create a "Current User, Current Host" profile if it does not exist
if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

# Write the profile script into $PROFILE
Copy-Item profile.ps1 -Destination $PROFILE

# Reloading the profile
. $PROFILE
