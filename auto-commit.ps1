# Stage all current changes
git add .

$diff = git diff --staged
if ([string]::IsNullOrWhiteSpace($diff)) {
    Write-Host "No changes detected. Exiting."
    exit
}

$Prompt = "You are a Senior DevOps Engineer documenting infrastructure-as-code. Write a single-line conventional commit message for the following code diff. Output strictly the commit message itself without quotes or markdown.`n`n$diff"

# The JSON payload structure required by Ollama's local API
$Body = @{
    model = "llama3.2"
    prompt = $Prompt
    stream = $false
} | ConvertTo-Json -Depth 5

Write-Host "Querying local llama3.2 model for commit message..." -ForegroundColor Cyan

try {
    # Pointing the script to your local machine (localhost)
    $Uri = "http://localhost:11434/api/generate"
    $Response = Invoke-RestMethod -Uri $Uri -Method Post -ContentType "application/json" -Body $Body
    $GeneratedCommit = $Response.response.Trim()
    
    Write-Host "`nProposed Commit Message:" -ForegroundColor Yellow
    Write-Host $GeneratedCommit
} catch {
    Write-Warning "Local API call failed."
    Write-Host "Error Details: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# The Safety Gate
$UserConfirmation = Read-Host "`nDo you want to commit and push to origin main? (Y/N)"

if ($UserConfirmation -match '^[Yy]$') {
    git commit -m "$GeneratedCommit"
    git push origin main
    Write-Host "Successfully pushed to main." -ForegroundColor Green
} else {
    # Rollback staging to prevent accidental commits later
    git reset
    Write-Host "Action aborted. Changes unstaged." -ForegroundColor Yellow
}