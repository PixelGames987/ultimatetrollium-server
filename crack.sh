#!/bin/bash

read -rp "file?: " file

file="captures/$file"

if [[ ! -f "$file" ]]; then
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
                echo "cap"
                ;;

        pcap)
                echo "pcap"
                ;;

        pcapng)
                echo "pcapng"
                ;;

        hccapx)
                echo "hccapx"
                ;;

        22000)
                echo "22000"
                ;;

        *)
                echo "File type not supported"
                exit 1
                ;;
esac

exit 0
