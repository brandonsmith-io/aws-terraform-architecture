#!/bin/bash

# Explicitly define the target file
README_FILE="README.md"
INDEX_PAYLOAD=".index_payload.tmp"
NOTES_PAYLOAD=".notes_payload.tmp"

# 1. Initialize payload files using echo -e for native macOS newline expansion
echo -e "| Lab Module | Directory Path |\n| :--- | :--- |" > "$INDEX_PAYLOAD"
> "$NOTES_PAYLOAD" # Initialize an empty notes file

# Discover all numbered lab folders
folders=($(find . -maxdepth 1 -type d -name "[0-9][0-9]-*" | sort))

for folder_path in "${folders[@]}"; do
    folder_name=$(basename "$folder_path")
    
    prefix="${folder_name:0:2}"
    suffix="${folder_name:3}"
    clean_suffix="${suffix//-/ }"
    title="$prefix. $(echo "$clean_suffix" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')"
    relative_link="./$folder_name"
    
    # Write directly to the index payload file
    echo -e "| [**$title**]($relative_link) | \`$folder_name\` |" >> "$INDEX_PAYLOAD"
    
    header="### [$title]($relative_link)"
    
    if grep -Fq "$header" "$README_FILE"; then
        # Extract existing notes and append them directly to the notes payload
        awk -v start="$header" '
            $0 == start {found=1; print; next}
            found && /^### \[/ {exit}
            found && /<!-- LAB_NOTES_END -->/ {exit}
            found {print}
        ' "$README_FILE" >> "$NOTES_PAYLOAD"
    else
        generated_bullets="* Automated lab module configuration."
        
        if nc -z 127.0.0.1 11434 2>/dev/null; then
            tf_files=$(find "$folder_path" -maxdepth 1 -name "*.tf")
            if [ -n "$tf_files" ]; then
                tf_code=$(cat $folder_path/*.tf 2>/dev/null)
                
                prompt="You are a Senior DevOps Engineer documenting infrastructure-as-code. Read the Terraform HCL from folder '$folder_name'. Write exactly 3 terse, highly technical Markdown bullet points (* ) explaining the architecture and resource dependencies. DO NOT output conversational filler, introductory sentences, or define basic terms. Output ONLY the 3 bullet points.:\n\n$tf_code"
                
                json_payload=$(jq -n --arg p "$prompt" '{model: "llama3.2", prompt: $p, stream: false}')
                
                response=$(curl -s -X POST http://localhost:11434/api/generate \
                    -H "Content-Type: application/json" \
                    -d "$json_payload")
                    
                if [ -n "$response" ]; then
                    generated_bullets=$(echo "$response" | jq -r '.response' | xargs -0)
                    echo -e "\e[36mLocal AI generated architecture notes for $folder_name\e[0m"
                fi
            fi
        fi
        
        # Write new AI generation directly to the payload file
        echo -e "$header\n$generated_bullets\n" >> "$NOTES_PAYLOAD"
    fi
done

# 3. Inject the payload files into the README using system("cat")
awk -v payload="$INDEX_PAYLOAD" '
    /<!-- LAB_INDEX_START -->/ {
        print
        system("cat " payload)
        skip=1
        next
    }
    /<!-- LAB_INDEX_END -->/ {
        skip=0
    }
    !skip {print}
' "$README_FILE" > "$README_FILE.tmp" && mv "$README_FILE.tmp" "$README_FILE"

awk -v payload="$NOTES_PAYLOAD" '
    /<!-- LAB_NOTES_START -->/ {
        print
        system("cat " payload)
        skip=1
        next
    }
    /<!-- LAB_NOTES_END -->/ {
        skip=0
    }
    !skip {print}
' "$README_FILE" > "$README_FILE.tmp" && mv "$README_FILE.tmp" "$README_FILE"

# Clean up hidden artifacts
rm -f "$INDEX_PAYLOAD" "$NOTES_PAYLOAD"

cat -s "$README_FILE" > "$README_FILE.tmp" && mv "$README_FILE.tmp" "$README_FILE"

echo -e "\e[32mSuccess: README index and notes synced with ${#folders[@]} lab modules.\e[0m"