#!/usr/bin/env bash

# Path to the mounted boot partition
BOOTMNT="/boot"

CONFIG_FILE="$BOOTMNT/config.txt"
CMDLINE_FILE="$BOOTMNT/cmdline.txt"

# ----------------------------------------
# 1) Update config.txt
# ----------------------------------------
echo "Processing $CONFIG_FILE ..."

add_line_if_missing() {
    local file="$1"
    local line="$2"
    grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

add_line_if_missing "$CONFIG_FILE" "enable_uart=1"
add_line_if_missing "$CONFIG_FILE" "uart_2ndstage=1"
add_line_if_missing "$CONFIG_FILE" "BOOT_UART=1"

echo "config.txt done."

# ----------------------------------------
# 2) Update cmdline.txt
# ----------------------------------------
echo "Processing $CMDLINE_FILE ..."

# Read entire cmdline (must be a single line)
orig_cmdline=$(cat "$CMDLINE_FILE" | tr -d '\n')

# Remove patterns that suppress UART output
clean_cmdline=$(echo "$orig_cmdline" \
    | sed -E 's/(^| )quiet($| )/ /g' \
    | sed -E 's/(^| )splash($| )/ /g' \
    | sed -E 's/(^| )plymouth.ignore-serial-consoles($| )/ /g')

# Remove duplicate spaces
clean_cmdline=$(echo "$clean_cmdline" | tr -s ' ')

# Remove existing console/earlycon entries that we are going to add ourselves
clean_cmdline=$(echo "$clean_cmdline" \
    | sed -E 's/(^| )console=serial0,[^ ]*//g' \
    | sed -E 's/(^| )console=tty1//g' \
    | sed -E 's/(^| )earlycon=[^ ]*//g')

# Remove extra spaces
clean_cmdline=$(echo "$clean_cmdline" | tr -s ' ' | sed -E 's/^ //;s/ $//')

# Build new command line
new_cmdline="earlycon=pl011,mmio32,0xfe201000,115200n8 console=serial0,115200 console=tty1 $clean_cmdline"

# Write back to file (one line)
echo "$new_cmdline" > "$CMDLINE_FILE"

echo "cmdline.txt updated."
echo ""
echo "Finished! Please verify the files:"
echo "  $CONFIG_FILE"
echo "  $CMDLINE_FILE"
