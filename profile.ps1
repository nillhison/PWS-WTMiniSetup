# Set the theme
# Use Takuya theme
oh-my-posh init pwsh --config 'APPDATA\Local\Programs\oh-my-posh\themes\takuya.omp.json' | Invoke-Expression

# Or use Probua.minimal (uncomment the line bellow)
# oh-my-posh init pwsh --config 'APPDATA\Local\Programs\oh-my-posh\themes\probua.minimal.omp.json' | Invoke-Expression

# Modules imports
Import-Module -Name Terminal-Icons
Import-Module -Name posh-git

# Set predictions viewer options
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
