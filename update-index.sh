# 3. Inject the updated Table and Notes back into the README
export NEW_INDEX="$table_content"
export NEW_NOTES="$notes_content"

# Overwrite the Index Table using ENVIRON to safely pass multi-line strings
awk '
    /<!-- LAB_INDEX_START -->/ {
        print
        printf "%b\n", ENVIRON["NEW_INDEX"]
        skip=1
        next
    }
    /<!-- LAB_INDEX_END -->/ {
        skip=0
    }
    !skip {print}
' "$README_FILE" > "$README_FILE.tmp" && mv "$README_FILE.tmp" "$README_FILE"

# Overwrite the Architecture Notes
awk '
    /<!-- LAB_NOTES_START -->/ {
        print
        printf "%b\n", ENVIRON["NEW_NOTES"]
        skip=1
        next
    }
    /<!-- LAB_NOTES_END -->/ {
        skip=0
    }
    !skip {print}
' "$README_FILE" > "$README_FILE.tmp" && mv "$README_FILE.tmp" "$README_FILE"

echo -e "\e[32mSuccess: README index and notes synced with ${#folders[@]} lab modules.\e[0m"