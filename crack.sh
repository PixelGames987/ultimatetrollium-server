#!/bin/bash
error_exit() {
    echo "Error: $1" >&2
    exit 1
}
read -rp "File?: " file
[[ -z "$file" ]] && error_exit "File name cannot be empty."
full_path="captures/$file"
[[ ! -f "$full_path" ]] && error_exit "File '$full_path' not found."
extension="${file##*.}"
extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
hash_output="/tmp/handshake.hccapx"
echo -e "\nProcessing '$file' (type: $extension)..."
case "$extension" in
    cap)
        echo "Converting .cap to .hccapx for Hashcat..."
        hcxpcapngtool -o "$hash_output" "$full_path" 2>/dev/null || \
            error_exit "Failed to convert '$full_path' to .hccapx. Is 'hcxpcapngtool' installed?"
        ;;
    hccapx|22000)
        echo "Copying '$full_path' to '$hash_output'."
        cp "$full_path" "$hash_output" || \
            error_exit "Failed to copy '$full_path'."
        ;;
    *)
        error_exit "Unsupported file type '$extension'. Only 'hccapx', '22000', and 'cap' are supported."
        ;;
esac
read -rp "Use wordlist (w) or mask (m)?: " choice
choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
attack_type="" # This will store '0' or '3'
target_data="" # This will store the wordlist path or mask string
case "$choice" in
    w)
        read -rp "Wordlist (e.g., rockyou.txt)?: " wordlist_name
        [[ -z "$wordlist_name" ]] && error_exit "Wordlist name cannot be empty."
        wordlist_path="wordlists/$wordlist_name"
        [[ ! -f "$wordlist_path" ]] && error_exit "Wordlist '$wordlist_path' not found."
        attack_type="0"
        target_data="$wordlist_path"
        ;;
    m)
        read -rp "Mask (e.g., ?1?1?1?1?1?1?1?1?1?1)?: " mask_string
        [[ -z "$mask_string" ]] && error_exit "Mask cannot be empty."
        attack_type="3"
        target_data="$mask_string"
        ;;
    *)
        error_exit "Invalid choice. Please enter 'w' for wordlist or 'm' for mask."
        ;;
esac
echo -e "\n--- Hashcat Options ---"
echo "Hash File: $hash_output"
echo "Mode: 22000 (WPA/WPA2 PMKID/EAPOL)"
echo "Attack Type: $attack_type"
echo "Target: $target_data"
echo "-----------------------"
echo -e "\nStarting Hashcat. Press 's' for status, 'q' to quit..."
hashcat -w 3 -S -m 22000 -a "$attack_type" "$hash_output" "$target_data"
rm -f "$hash_output"
echo -e "\nHashcat session finished. Temporary file '$hash_output' removed."
exit 0
