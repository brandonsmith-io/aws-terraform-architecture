#!/bin/bash

git add .

staged_files=$(git diff --staged --name-only)
diff_output=$(git diff --staged)

if [ -z "$diff_output" ]; then
    echo "No changes detected. Exiting."
    exit 0
fi

prompt="Write exactly one single-line conventional commit message (max 72 chars). Format: TYPE(SCOPE): DESCRIPTION. Rules: 1. TYPE is feat, fix, or chore. 2. SCOPE is the folder name. 3. DESCRIPTION must summarize the actual Terraform modules or resources found in the diff. Output ONLY the raw commit message string.

Files:
$staged_files

Diff:
$diff_output"

# Safely construct the JSON payload using jq
json_payload=$(jq -n --arg p "$prompt" '{model: "llama3.2", prompt: $p, stream: false}')

echo -e "\e[36mQuerying local llama3.2 model...\e[0m"

# Execute the REST API call via curl
response=$(curl -s -X POST http://localhost:11434/api/generate \
    -H "Content-Type: application/json" \
    -d "$json_payload")

if [ -z "$response" ]; then
    echo -e "\e[33mLocal API call failed. Is Ollama running on this Mac?\e[0m"
    exit 1
fi

# Extract the response text and trim whitespace
generated_commit=$(echo "$response" | jq -r '.response' | xargs)

echo -e "\n\e[33mProposed Commit Message:\e[0m"
echo "$generated_commit"

read -p $'\nCommit and push to origin main? (Y/N) ' user_confirmation

if [[ "$user_confirmation" =~ ^[Yy]$ ]]; then
    git commit -m "$generated_commit"
    git push origin main
    echo -e "\e[32mPushed to main.\e[0m"
else
    git reset
    echo -e "\e[33mAborted. Changes unstaged.\e[0m"
fi