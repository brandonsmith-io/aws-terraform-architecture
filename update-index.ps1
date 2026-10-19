# update-index.ps1
# $PSScriptRoot ensures the script always targets the repo root, even if run from a subfolder
$RootPath = $PSScriptRoot
$ReadmeFile = Join-Path $RootPath "README.md"

# 1. Discover all numbered lab folders
$Folders = Get-ChildItem -Path $RootPath -Directory | Where-Object { $_.Name -match '^\d{2}-' } | Sort-Object Name

# Read current README.md first so we can preserve existing architectural descriptions
$OriginalContent = Get-Content -Path $ReadmeFile -Raw

# 2. Build the Markdown table lines AND the Architecture Notes section
$Table = @(
    "| Lab Module | Directory Path |",
    "| :--- | :--- |"
)
$NotesBlocks = @()

foreach ($Folder in $Folders) {
    # Convert '10-variables' -> '10. Variables'
    $CleanName = ($Folder.Name -replace '^(\d{2})-(.*)$', '$1. $2' -replace '-', ' ')
    $Title = (Get-Culture).TextInfo.ToTitleCase($CleanName)
    $RelativeLink = "./$($Folder.Name)"
    
    # Add row to top navigation table
    $Table += "| [**$Title**]($RelativeLink) | ``$($Folder.Name)`` |"

    # Check if this folder already has a ### [..](./folder-name) block in README.md
    $EscapedFolder = [regex]::Escape($Folder.Name)
    $ExistingBlockPattern = "(?ms)^### \[[^\]]+\]\(\./$EscapedFolder\)\r?\n(.*?)(?=(\r?\n### \[|\r?\n<!-- LAB_NOTES_END -->))"

    if ($OriginalContent -match $ExistingBlockPattern) {
        # Preserve your existing header and bullets for this folder
        $FullMatch = $Matches[0].Trim()
        $NotesBlocks += $FullMatch
    }
    else {
        # Brand new folder detected! Generate header + bullets
        $NewHeader = "### [$Title]($RelativeLink)"
        $GeneratedBullets = "* Automated lab module configuration."

        # If GEMINI_API_KEY is present, read the .tf code and write detailed bullets automatically
       # Check if the local Ollama API is listening on the default port (11434)
if (Test-NetConnection -ComputerName "127.0.0.1" -Port 11434 -InformationLevel Quiet) {
    $TfFiles = Get-ChildItem -Path $Folder.FullName -Filter "*.tf"
    if ($TfFiles) {$TfCode = ($TfFiles | ForEach-Object { Get-Content $_.FullName -Raw }) -join "`n"
        
        $Prompt = "You are a Senior DevOps Engineer documenting infrastructure-as-code. Read the Terraform HCL from folder '$($Folder.Name)' Write exactly 3 terse, highly technical Markdown bullet points (* ) explaining the architecture and resource dependencies. DO NOT output conversational filler, introductory sentences, or define basic terms. Output ONLY the 3 bullet points.:`n`n$TfCode"

        # The JSON payload structure required by Ollama's local API
        $Body = @{
            model  = "llama3.2"
            prompt = $Prompt
            stream = $false
        } | ConvertTo-Json -Depth 5

        try {
            # Pointing the script to your local machine (localhost)
            $Uri = "http://localhost:11434/api/generate"
            $Response = Invoke-RestMethod -Uri $Uri -Method Post -ContentType "application/json" -Body $Body
            
            # Ollama returns the generated text inside a 'response' property
            $GeneratedBullets =$Response.response.Trim()
            Write-Host "Local AI generated architecture notes for $($Folder.Name)" -ForegroundColor Cyan
        }
        catch {
            Write-Warning "Local API call failed for $($Folder.Name). Using placeholder note."
            Write-Host "Error Details: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

        $NotesBlocks += "$NewHeader`r`n$GeneratedBullets"
    }
}

$TableContent =$Table -join "`r`n"
$NotesContent =$NotesBlocks -join "`r`n`r`n"

# 3. Replace Table between LAB_INDEX anchors
$IndexPattern = '(?s)<!-- LAB_INDEX_START -->.*?<!-- LAB_INDEX_END -->'
$IndexReplacement = "<!-- LAB_INDEX_START -->`r`n$TableContent`r`n<!-- LAB_INDEX_END -->"
$UpdatedContent =$OriginalContent -replace $IndexPattern,$IndexReplacement

# 4. Replace Architecture Notes between LAB_NOTES anchors (if anchors exist)
$NotesPattern = '(?s)<!-- LAB_NOTES_START -->.*?<!-- LAB_NOTES_END -->'
if ($UpdatedContent -match $NotesPattern) {$NotesReplacement = "<!-- LAB_NOTES_START -->`r`n$NotesContent`r`n<!-- LAB_NOTES_END -->"
    $UpdatedContent =$UpdatedContent -replace $NotesPattern,$NotesReplacement
}

Set-Content -Path $ReadmeFile -Value $UpdatedContent -NoNewline
Write-Host "Success: README index and notes synced with $($Folders.Count) lab modules." -ForegroundColor Green