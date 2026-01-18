# Simple NASM Bootloader

This project is a **minimal 16-bit bootloader** written in nasm assembly. 
When run the BIOS loads and executes this bootloader and then prints text into the screen with BIOS calls.

## Requirements
 
- [`nasm`](https://www.nasm.us/) – assembler for 16-bit code  
- `make` – build system to run the Makefile to automate compilation and .img file creation in build folder 
- Optional: `qemu-system-i386` – emulator to test the bootloader on  

On Ubuntu/Debian-based systems, you can install the required tools with:
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


## Example of running BootLoader
[![Screenshot](https://i.postimg.cc/kG0ZgHwJ/Captura-de-pantalla-2026-01-13-a-la(s)-9-08-18-p-m.png)](https://postimages.org/)
