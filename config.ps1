# Run this file: powershell -ExecutionPolicy Bypass .\config.ps1

# View the profile files and its scopes: $PROFILE | Select-Object *

# Set the execution policy to RemoteSigned in order to perform the setup
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Create a "Current User, Current Host" profile if it does not exist
if (!(Test-Path -Path $PROFILE)) {
  New-Item -ItemType File -Path $PROFILE -Force
}

# Get the path to the $PROFILE directory
$profileDir = Split-Path -Path $PROFILE -Parent

# Install Oh My Posh
winget install JanDeDobbeleer.OhMyPosh -s winget

# Add Oh My Posh to PATH
$env:Path += ";APPDATA\Local\Programs\oh-my-posh\bin"

# Upgrade Oh My Posh
winget upgrade JanDeDobbeleer.OhMyPosh -s winget

# Instal nerd fonts
# It will be necessary to change the font in the settings
# If powershell throw an error at this point, just copy the following command and execute it after restarting the terminal
oh-my-posh font install meslo

# Install icons for terminal
Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser

# Instal this module to use history viewer
Install-Module PSReadLine -Force -Scope CurrentUser

# Write the profile script into $PROFILE
Copy-Item profile.ps1 -Destination $PROFILE

# Reloading the profile
. $PROFILE
