Get-ChildItem `
    -Path (Join-Path -Path $moduleRoot -ChildPath 'public') `
    -Include '*.ps1' `
    -Recurse | ForEach-Object -Process {
        . $_.Fullname
    }