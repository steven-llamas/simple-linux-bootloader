# Simple Operating System

This project is a **minimal Operating System** written in `nasm` asm and `C`. 
When built, `the main.img` contains a bootable disk image that can be run in a x86 emulator.
This project is intended for educational purposes

## Requirements
 
- [`nasm`](https://www.nasm.us/) – assembler for 16-bit code  
- `make` – build system to run the Makefile to automate compilation and .img file creation in build folder
- [`open Watcom v2`](https://github.com/open-watcom/open-watcom-v2) - a `C` compiler with 16-bit support used to implement parts of the OS.
- other packages may be needed, make sure to run `make install_tools` (for Ubuntu/Debian systems) before building 
- Optional: `qemu-system-i386` – emulator to test the bootloader on  

On **Ubuntu/Debian-based** systems, you can install the required tools with:
```bash
sudo apt install build-essential nasm make
```

## Build

This project uses `make` to create the *build* folder and build the files into that folder. Simply run:

```bash
make install_tools
```
`install_tools` will install all the required packages for this project (on ubuntu/debian systems). Then run:
```bash
make
```


## Example of running OS in a VM
[![Screenshot](https://i.postimg.cc/DwC19Brq/Captura-de-pantalla-2026-01-18-a-la(s)-12-35-11-p-m.png)]()