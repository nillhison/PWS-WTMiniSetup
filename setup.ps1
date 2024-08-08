# Run this file: powershell -ExecutionPolicy Bypass .\setup.ps1

# View the profile files and its scopes: $PROFILE | Select-Object *

# Set the execution policy to RemoteSigned in order to perform the setup
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Create this class to interact with the installer application method in InstallRequired
class AppInfo {
    
    $info = [PSCustomObject]@{}

    AppInfo([string]$appId, [string]$appExe, [string]$appName, [string]$appScope) {
        $this.info.Id = $appId
        $this.info.Exe = $appExe
        $this.info.Name = $appName
        $this.info.Scope = $appScope
    }

    [PSCustomObject] Info() {
        return $this.info
    }
    
}

# Create the core class for this setup
class InstallRequired {

    [void] Modules([string[]]$mdls) {
        
        # Trust the repository's authors
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        
        foreach($mdl in $mdlss) {
            
            # Install the module, if not yet installed
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
            
            # Look up for the application in the system
            # Install it, if not yet installed
            if (-not (Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq $app.Info().Name })) {
                try {
                    winget install --id $app.Info().Id -e --source winget --scope $app.Info().Scope
                } catch {
                    Write-Error "Failed to install application $app.Info().Name. Error: $_"
                }
            } else {
                Write-Host "Application $app.Info().Name is already installed"
            }
            
            # Update the PATH setting an environment variable to the .exe file
            $this.SetAppEnv($app.Info().Exe, $app.Info().Scope)
        }
        
    }
    
    [void] SetAppEnv([string]$exe, [string]$scope) {
        
        # Create a variable that holds the directory for the .exe file, regarding its scope
        # Create a variable to adapt the scope nomenclature from winget to .NET
        
        switch($scope) {
            'machine' {
                $exePath  = Get-ChildItem -Path "C:\Program Files", "C:\Program Files (x86)" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $exe }
                $exeDirectory = $exePath.DirectoryName
                $dotnetScope = 'Machine'
            }
            'user' {
                $exePath  = Get-ChildItem -Path "APPDATA\Local\Programs" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $exe }
                $exeDirectory = $exePath.DirectoryName
                $dotnetScope = 'CurrentUser'
            }
        }
        
        # If the application was already installed, check whether it's in the PATH
        # Also applied if this instalation itself has just added the .exe to the PATH
        if(-not (Test-Path -Path $exeDirectory)) {
            # Use .NET context to append the .exe directory to the PATH
            [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";$exeDirectory", [System.EnvironmentVariableTarget]::$dotnetScope)
        }
    }

}

# Create the installer variable
$install = [InstallRequired]::new()

# Create the variable that wraps the modules informations (in this case, only their names)
$modules = @(
    "Terminal-Icons",
    "PSReadLine",
    "posh-git"
)

# Create the variable that wraps the applications informations
$applications = @(
    [AppInfo]::new('Git.Git', 'git', 'Git', 'machine'),
    [AppInfo]::new('GitHub.cli', 'gh', 'GitHub CLI', 'machine'),
    [AppInfo]::new('Microsoft.VisualStudioCode', 'code' 'Microsoft Visual Studio Code', 'user'),
    [AppInfo]::new('JanDeDobbeleer.OhMyPosh', 'oh-my-posh', 'Oh My Posh', 'user')
)

# Finally...
# Pass the data items variables to the installer and proceed the instalation
$install.Modules($modules)
$install.Applications($applications)

# Install the additional items
oh-my-posh font install meslo

# Create a "Current User, Current Host" profile if it does not exist
if(-not (Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

# Write the profile script into $PROFILE
# Although the template is located in this directory, check this before proceeding
if(Test-Path -Path "profile.ps1") {
    
    Copy-Item profile.ps1 -Destination $PROFILE
    
    # Finally...
    # Reload the profile
    . $PROFILE
    
} else {
    Write-Host "Profile template not found!"
}
