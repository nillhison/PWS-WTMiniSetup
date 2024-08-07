# Run this file: powershell -ExecutionPolicy Bypass .\setup.ps1

# View the profile files and its scopes: $PROFILE | Select-Object *

# Set the execution policy to RemoteSigned in order to perform the setup
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

class AppInfo {
    
    $info = [PSCustomObject]@{}

    AppInfo([string]$appId, [string]$appExe, [string]$appName, [string]$appScope) {
        $info.Id = $appId
        $info.Exe = $appExe
        $info.Name = $appName
        $info.Scope = $appScope
    }

    [PSCustomObject] Info() {
        return $info
    }
    
}

class InstallRequired {

    [void] Modules([string[]]$mdls) {
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        foreach($mdl in $mdlss) {
            if (-not (Get-Module -ListAvailable -Name $mdl)) {
                try {
                    Install-Module -Name $mdl -Force -Scope CurrentUser
                } catch {
                    Write-Error "Failed to install module $mdl. Error: $_"
                }
            } else {
                Write-Host "Module $mdl is already installed"
            }
        }
    }

    [void] Applications([AppInfo[]]$apps) {
        foreach($app in $apps) {
            if (-not (Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq $app.Info().Name })) {
                try {
                    winget install --id $app.Info().Id -e --source winget -scope $app.Info().Scope
                } catch {
                    Write-Error "Failed to install application $app.Info().Name. Error: $_"
                }
            } else {
                Write-Host "Application $app.Info().Name is already installed"
            }
        }
    }

}

$install = [InstallRequired]::new()

$modules = @(
    "Terminal-Icons",
    "PSReadLine",
    "posh-git"
)

$applications = @(
    [AppInfo]::new('git', 'Git.Git', 'Git', 'machine'),
    [AppInfo]::new('gh', 'GitHub.cli', 'GitHub CLI', 'machine'),
    [AppInfo]::new('code', 'Microsoft.VisualStudioCode', 'Microsoft Visual Studio Code', 'user'),
    [AppInfo]::new('oh-my-posh', 'JanDeDobbeleer.OhMyPosh', 'Oh My Posh', 'user')
)


$install.Modules($modules)
$install.Applications($applications)

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
