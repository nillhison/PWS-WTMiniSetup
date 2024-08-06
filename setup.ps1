# Run this file: powershell -ExecutionPolicy Bypass .\setup.ps1

# View the profile files and its scopes: $PROFILE | Select-Object *

# Set the execution policy to RemoteSigned in order to perform the setup
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

class AppInfo {

    [string]$id
    [string]$exe
    [string]$name

    AppInfo([string]$givenId, [string]$givenExe, [string]$givenName) {
        $this.id = $givenId
        $this.exe = $givenExe
        $this.name = $givenName
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

}
class InstallRequired {

    [void] Modules([string[]]$modules) {
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        foreach($module in $modules) {
            Install-Module -Name $module -Force -Scope CurrentUser
        }
    }

    [void] Applications([AppInfo[]]$applications) {
        foreach($application in $applications) {
            if (!(Get-Command $application.Exe -ErrorAction SilentlyContinue)) {
                winget install --id $applications.Id -e --source winget -scope user
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
    [AppInfo]::new('git', 'Git.Git', 'Git'),
    [AppInfo]::new('gh', 'GitHub.cli', 'GitHub CLI')
    [AppInfo]::new('code', 'Microsoft.VisualStudioCode', 'Microsoft Visual Studio Code')
    [AppInfo]::new('oh-my-posh', 'JanDeDobbeleer.OhMyPosh', 'Oh My Posh')
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
