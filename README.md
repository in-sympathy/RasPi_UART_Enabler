# Raspberry Pi Universal UART Debug Setup

This repository contains a **bash script** to configure Raspberry Pi SD cards with the necessary boot and kernel parameters to enable early UART output and serial console logging across multiple Raspberry Pi models, including:

- Raspberry Pi Zero / Zero 2 W  
- Raspberry Pi 3 / 3B / 3B+  
- Raspberry Pi 4 / 4B  
- Raspberry Pi 5 (kernel serial output)

This setup is especially useful when diagnosing boot issues, recovering non-booting boards, or collecting early debug logs over serial.

> ⚠️ **Note for Raspberry Pi 5:** Full bootloader debug output may appear on the dedicated Pi 5 debug UART rather than the standard GPIO serial pins; however, this configuration still enables early kernel UART output on serial0 for effective diagnostics.

---

## 📦 Contents

- `enable_uart_debug.sh`: The main setup script  
- `README.md`: This documentation  

---

## 🧠 What This Does

The script updates the SD card’s boot files to:

### ✅ In `config.txt`

- Enable UART hardware (`enable_uart=1`)  
- Enable extended firmware debug (`uart_2ndstage=1`)  
- Enable bootloader UART output (`BOOT_UART=1`)

### ✅ In `cmdline.txt`

- Add an early kernel printk console (`earlycon=pl011,mmio32,0xfe201000,115200n8`)  
- Enable the standard kernel serial console (`console=serial0,115200`)  
- Preserve existing kernel parameters like root settings and wireless regulatory domain (`cfg80211.ieee80211_regdom=…`)  
- Remove flags that suppress serial output (e.g., `quiet`, `splash`, `plymouth.ignore-serial-consoles`)

This ensures as much boot output as possible is sent over the UART pins (via a 3.3 V TTL adapter at 115200 baud) for debugging.

---

## 🚀 How to Use

1. **Mount the Raspberry Pi SD card** on a Linux machine  
2. Update the `BOOTMNT` variable in the script if needed (default `/boot`)  
3. Run the script with root privileges:

   ```bash
   sudo ./enable_uart_debug.sh
