#!/bin/bash

# Define the absolute root path to ensure relative links always resolve correctly
ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
README_FILE="$ROOT_PATH/README.md"

# 1. Discover all numbered lab folders (e.g., 01-ec2-provisioning)
folders=($(find "$ROOT_PATH" -maxdepth 1 -type d -name "[0-9][0-9]-*" | sort))

# Initialize the Markdown table structure
table_content="| Lab Module | Directory Path |\n| :--- | :--- |"
notes_content=""

for folder_path in "${folders[@]}"; do
    folder_name=$(basename "$folder_path")
    
    # String formatting: '10-variables' -> '10. Variables'
    prefix="${folder_name:0:2}"
    suffix="${folder_name:3}"
    clean_suffix="${suffix//-/ }"
    # Title-case the remaining string using awk
    title="$prefix. $(echo "$clean_suffix" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')"
    relative_link="./$folder_name"
    
    # Append the formatted row to the table string
    table_content="$table_content\n| [**$title**]($relative_link) | \`$folder_name\` |"
    
    # 2. Rebuild the Architecture Notes
    header="### [$title]($relative_link)"
    
    # Check if this module already exists in the README
    if grep -Fq "$header" "$README_FILE"; then
        # Extract the existing note block to preserve manual edits
        existing_block=$(awk -v start="$header" '
            $0 == start {found=1; print; next}
            found && /^### \[/ {exit}
            found && /<!-- LAB_NOTES_END -->/ {exit}
            found {print}
        ' "$README_FILE")
        notes_content="$notes_content$existing_block\n\n"
    else
        # Brand new module detected; prepare placeholder bullets
        generated_bullets="* Automated lab module configuration."
        
        # Check if the Ollama API is listening locally on port 11434
        if nc -z 127.0.0.1 11434 2>/dev/null; then
            tf_files=$(find "$folder_path" -maxdepth 1 -name "*.tf")
            if [ -n "$tf_files" ]; then
                tf_code=$(cat $tf_files)
                
                prompt="You are a Senior DevOps Engineer documenting infrastructure-as-code. Read the Terraform HCL from folder '$folder_name'. Write exactly 3 terse, highly technical Markdown bullet points (* ) explaining the architecture and resource dependencies. DO NOT output conversational filler, introductory sentences, or define basic terms. Output ONLY the 3 bullet points.:\n\n$tf_code"
                
                # Safely encode the payload
                json_payload=$(jq -n --arg p "$prompt" '{model: "llama3.2", prompt: $p, stream: false}')
                
                # Execute the API call
                response=$(curl -s -X POST http://localhost:11434/api/generate \
                    -H "Content-Type: application/json" \
                    -d "$json_payload")
                    
                if [ -n "$response" ]; then
                    # Extract string and trim whitespace
                    generated_bullets=$(echo "$response" | jq -r '.response' | xargs -0)
                    echo -e "\e[36mLocal AI generated architecture notes for $folder_name\e[0m"
                else
                    echo -e "\e[31mLocal API call failed for $folder_name. Using placeholder note.\e[0m"
                fi
            fi
        fi
        
        notes_content="$notes_content$header\n$generated_bullets\n\n"
    fi
done

# 3. Inject the updated Table and Notes back into the README
# We use awk to stream the file and replace everything between the anchor tags

# Overwrite the Index Table
awk -v new_index="$table_content" '
    /<!-- LAB_INDEX_START -->/ {
        print
        printf "%b\n", new_index
        skip=1
        next
    }
    /<!-- LAB_INDEX_END -->/ {
        skip=0
    }
    !skip {print}
' "$README_FILE" > "$README_FILE.tmp" && mv "$README_FILE.tmp" "$README_FILE"

# Overwrite the Architecture Notes
awk -v new_notes="$notes_content" '
    /<!-- LAB_NOTES_START -->/ {
        print
        printf "%b\n", new_notes
        skip=1
        next
    }
    /<!-- LAB_NOTES_END -->/ {
        skip=0
    }
    !skip {print}
' "$README_FILE" > "$README_FILE.tmp" && mv "$README_FILE.tmp" "$README_FILE"

echo -e "\e[32mSuccess: README index and notes synced with ${#folders[@]} lab modules.\e[0m"