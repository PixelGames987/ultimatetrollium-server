#!/bin/bash

# The setup script for debian server/lxc (Bookworm)

set -e

echo -e "\n[*] Updating package list...\n"
apt update

echo -e "\n[*] Full system update...\n"
apt full-upgrade -y

echo -e "\n[*] Installing tools and dependencies...\n"
apt install hashcat aircrack-ng hcxdumptool -y

mkdir captures wordlists

echo "[*] Setup completed, scripts ready for use."
