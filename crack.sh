#!/bin/bash

read -rp "file?: " file
read -rp "wordlist?: " wordlist

if [[ ! -f "captures/$file" ]]; then
    echo "Error: File '$file' not found."
    exit 1
fi

base=$(basename "$file")
extension="${base##*.}"
extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]') # convert it to lower characters

echo -e "\n$base"
echo -e "type: \"$extension\""

case "$extension" in
        cap)
		hcxpcapngtool -o "/tmp/handshake.hccapx" "captures/$file"
		;;
	pcap)
		cp "captures/$file" "/tmp/handshake.pcap"
		aircrack-ng -w wordlists/$wordlist "/tmp/handshake.pcap"
		exit 0
		;;

        hccapx|22000)
		cp "captures/$file" "/tmp/handshake.$extension"
                ;;

        *)
                echo "File type not supported"
                exit 1
                ;;
esac

hashcat -w 3 -S -m 22000 -a 0 -D 1 "/tmp/handshake.$extension" "wordlists/$wordlist"

exit 0
