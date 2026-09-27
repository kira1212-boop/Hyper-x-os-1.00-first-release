# ⚡ HYPER X OS 1.00 (HXOS)

An ultra-lightweight, high-performance, bare-metal x86 Operating System written completely in **Pure Assembly Language**. Inspired by total architectural independence and a rejection of modern software bloat, **HXOS** bypasses standard commercial operating system restrictions to command physical hardware registers directly.

> "Justice isn't about getting your team down; its purpose is to work with a person." 
> — Operating System Core Philosophy

---

## 🚀 Core Features

### 🛠️ Bare-Metal Storage Installer
*   **True Partitioning Matrix:** Bypasses software emulation layers to issue direct BIOS `INT 0x13` hardware interrupts that physically write a valid Master Boot Record (MBR) partition table down to LBA Sector 0.
*   **Spec-Compliant FAT32 Formatter:** Generates fully valid Volume Boot Records (VBR), redundant File Allocation Tables (FAT 1 & 2), and clean initial Root Directory layout clusters natively from scratch. Fully recognized, parsed, and validated by the Linux kernel.
*   **Dual-Drive Target Selector:** Features an interactive drive selector prompt allowing safe deployment routing between the primary system boot sector (`0x80`) and an attached secondary virtual sandbox device (`0x81`).

### 💻 Text-User Interface (TUI) Workspace
*   **Anti-Scroll Canvas:** Custom text UI environment built inside a hyper-optimized 32KB kernel footprint. Uses explicit row-boundary monitoring to block black BIOS scrolling glitches and features automatic workspace page-flipping pauses.
*   **HXedit Sandbox Editor:** A non-bloated, minimalist plain text file creator featuring interactive backspace character erasing before forcing data blocks straight down to persistent storage sector 50.
*   **Dual-Pass Sector Auditor (`read`):** Queries raw hardware sectors off your drive and prints an aligned multi-column layout displaying Hexadecimal data bytes on the left and parsed ASCII alphanumeric text characters on the right.

### 🧮 Subsystem Utilities
*   **Hardware Math Engine (`calc`):** Drops straight into x86 processing registers to calculate immediate hardware-level Addition, Subtraction, Multiplication (`mul`), and Division (`div`) cycles.
*   **CMOS Real-Time Clock (`time`):** Communicates directly with motherboard memory ports `0x70` and `0x71` to read real physical system hours and minutes.
*   **Architecture Cross-Compilers:** Integrated validation interfaces matching baseline C, C++, and structural assembly vectors alongside specialized cross-compiler checks for `AArch64` (ARM) and SPARC V9 open-source enterprise profiles.
*   **Authoritative Power Reset (`reboot`):** Pulses the 8042 motherboard keyboard controller chip via Port `0x64` to force immediate bare-metal hardware cold reboots.

---

## 📦 Codebase Structural Mapping

The source tree is split across exactly 12 decoupled, bare-metal assembly layout frames:
*   `boot.asm` — The legacy 512-byte Master Boot Sector bootstrap track.
*   `kernel.asm` — The central command routing interface and shell prompt loop.
*   `ui.asm` — Master graphical user interface drawing constraints canvas.
*   `uicustom.asm` — Active theme manager and desktop palette color variables.
*   `install.asm` — Bare-metal dual-drive MBR partitioning and FAT32 formatting engine.
*   `partlist.asm` — Absolute low-level disk geometry analyzer and table reporter.
*   `software.asm` — Local package mirror provisioning index and storefront manager.
*   `compiler.asm` — Embedded multi-language compilation parser matrix.
*   `HXcalu.asm` — Interactive raw register math calculator loop.
*   `HXedit.asm` — Text editor sandbox with custom backspace character tracking routines.
*   `Read.asm` — Dual-column hexadecimal sector byte viewer and ASCII text parser.

---

## ⚡ How to Compile, Setup Tester, and Boot

### 1. Initialize the Fake Sandbox Testing Disk
To test the live partitioning tool, text editor saving states, and file reading utilities without altering your main operating system boot image, generate an empty, zeroed-out 32MB virtual raw sandbox disk file:
```bash
dd if=/dev/zero of=fake_disk.img bs=1M count=32
```

### 2. The Comprehensive One-Line Build and Emulation Pipeline
To purge prior binaries, assemble your 64-sector bootstrap sector, compile the multi-module 32KB kernel, merge the tracks, and launch the virtual environment with both your system image and your sandbox testing disk attached cleanly, run this single terminal chain:
```bash
rm -f boot.bin kernel.bin hyperx_os.img && nasm -f bin boot.asm -o boot.bin && nasm -f bin kernel.asm -o kernel.bin && cat boot.bin kernel.bin > hyperx_os.img && qemu-system-i386 -drive file=hyperx_os.img,format=raw,index=0,media=disk -drive file=fake_disk.img,format=raw,index=1,media=disk
```

### 3. Verification of the Hardware Installer
Once inside the OS interface canvas, you can verify that the formatting engine writes genuine hardware metadata maps directly from your host workstation. Exit QEMU after running the `install` module on your secondary fake disk (choice `2`), and check the partition table maps inside Linux:
```bash
/usr/sbin/fdisk -l fake_disk.img
```
