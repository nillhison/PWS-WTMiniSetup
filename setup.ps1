# Run this file: powershell -ExecutionPolicy Bypass .\setup.ps1

# View the profile files and its scopes: $PROFILE | Select-Object *

# Set the execution policy to RemoteSigned in order to perform the setup
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

class InstallRequired {
    [void] Modules([string[]]$modules) {
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        foreach($module in $modules) {
            Install-Module -Name $module -Force -Scope CurrentUser
        }
    }

    [void] Applications([hashtable]$applications) {
        foreach($id in $applications.Keys) {
            if (!(Get-Command $id -ErrorAction SilentlyContinue)) {
                winget install --id $applications[$id] -e --source winget -scope user
            }
        }
    }
}

$install = [InstallRequired]::new()

$mdls = @ (
    "Terminal-Icons",
    "PSReadLine",
    "posh-git"
)

$apps = @ {
    "git" = "Git.Git",
    "gh" = "GitHub.cli",
    "code" = "Microsoft.VisualStudioCode",
    "oh-my-posh" = "JanDeDobbeleer.OhMyPosh"
}

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

###########

#######

###
