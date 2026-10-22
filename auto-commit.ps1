git add .

$stagedFiles = git diff --staged --name-only
$diff = git diff --staged

if ([string]::IsNullOrWhiteSpace($diff)) {
    Write-Host "No changes detected. Exiting."
    exit
}

# Prompt structure heavily adapted from your update-index.ps1 success
$Prompt = "Write exactly one single-line conventional commit message (max 72 chars). Format: TYPE(SCOPE): DESCRIPTION. Rules: 1. TYPE is feat, fix, or chore. 2. SCOPE is the folder name. 3. DESCRIPTION must summarize the actual Terraform modules or resources found in the diff. Output ONLY the raw commit message string.`n`nFiles:`n$stagedFiles`n`nDiff:`n$diff"
# Exact payload structure from update-index.ps1
$Body = @{
    model  = "llama3.2"
    prompt = $Prompt
    stream = $false
} | ConvertTo-Json -Depth 5

Write-Host "Querying local llama3.2 model..." -ForegroundColor Cyan

try {
    $Uri = "http://localhost:11434/api/generate"
    $Response = Invoke-RestMethod -Uri $Uri -Method Post -ContentType "application/json" -Body $Body
    
    # Exact parsing method from update-index.ps1
    $GeneratedCommit = $Response.response.Trim()
    
    Write-Host "`nProposed Commit Message:" -ForegroundColor Yellow
    Write-Host $GeneratedCommit
} catch {
    Write-Warning "Local API call failed."
    exit
}

$UserConfirmation = Read-Host "`nCommit and push to origin main? (Y/N)"

if ($UserConfirmation -match '^[Yy]$') {
    git commit -m "$GeneratedCommit"
    git push origin main
    Write-Host "Pushed to main." -ForegroundColor Green
} else {
    git reset
    Write-Host "Aborted. Changes unstaged." -ForegroundColor Yellow
}