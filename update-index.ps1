# update-index.ps1
$RootPath = Get-Location
$ReadmeFile = Join-Path $RootPath "README.md"

# 1. Discover all numbered lab folders
$Folders = Get-ChildItem -Directory | Where-Object { $_.Name -match '^\d{2}-' } | Sort-Object Name

# 2. Build the Markdown table lines
$Table = @(
    "| Lab Module | Directory Path |",
    "| :--- | :--- |"
)

foreach ($Folder in $Folders) {
    # Convert '10-variables' -> '10. Variables'
    $CleanName = ($Folder.Name -replace '^(\d{2})-(.*)$', '$1. $2' -replace '-', ' ')
    $Title = (Get-Culture).TextInfo.ToTitleCase($CleanName)
    $RelativeLink = "./$($Folder.Name)"
    $Table += "| [**$Title**]($RelativeLink) | ``$($Folder.Name)`` |"
}

$TableContent =$Table -join "`r`n"

# 3. Read README.md and replace content between anchor tags
$OriginalContent = Get-Content -Path $ReadmeFile -Raw
$RegexPattern = '(?s)<!-- LAB_INDEX_START -->.*?<!-- LAB_INDEX_END -->'
$Replacement = "<!-- LAB_INDEX_START -->`r`n$TableContent`r`n<!-- LAB_INDEX_END -->"

$FinalContent =$OriginalContent -replace $RegexPattern,$Replacement
Set-Content -Path $ReadmeFile -Value $FinalContent -NoNewline

Write-Host "Success: README index updated with $($Folders.Count) lab modules." -ForegroundColor Green