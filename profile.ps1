# Setting themes
oh-my-posh init pwsh --config 'APPDATA\Local\Programs\oh-my-posh\themes\takuya.omp.json' | Invoke-Expression
# oh-my-posh init pwsh --config 'APPDATA\Local\Programs\oh-my-posh\themes\probua.minimal.omp.json' | Invoke-Expression

Import-Module -Name Terminal-Icons

# Setting predictions viewer options
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
