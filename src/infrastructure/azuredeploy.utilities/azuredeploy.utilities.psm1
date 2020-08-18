Get-ChildItem `
    -Path (Join-Path -Path $PSScriptRoot -ChildPath 'public') `
    -Include '*.ps1' `
    -Recurse | ForEach-Object -Process {
        . $_.Fullname
    }