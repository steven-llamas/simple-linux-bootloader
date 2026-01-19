# -------------- variables --------------------- 
ASM=nasm
SRC_DIR=src
BUILD_DIR=build
# watcom 16 bit C compiler location
# default location at /usr/bin/watcom 
WATCOM?= /usr/bin/watcom
CC16:= $(WATCOM)/binl/wcc
LD16:= $(WATCOM)/binl/wlink
C_FLAGS16= -s -wx -ms -zl -zq
ASM_FLAGS=-f obj

# ---------------- Floppy Image ----------------
floppy_img: check_tools $(BUILD_DIR)/main.img
$(BUILD_DIR)/main.img: bootloader kernel
# prereqs of bootloader and kernel
# copies from if (input file) to of (output)
# creates them in 512 byte format bs
# 2880 times (floppy disk size of 1.33MB)	
	dd if=/dev/zero of=$(BUILD_DIR)/main.img bs=512 count=2880 
# makes file system FAT12 format
	mkfs.fat -F 12 -n "EKKO_OS" $(BUILD_DIR)/main.img
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main.img conv=notrunc 
	mcopy -i $(BUILD_DIR)/main.img $(BUILD_DIR)/kernel.bin "::kernel.bin"

# --------------- bootloader ------------------
bootloader: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: $(SRC_DIR)/bootloader/boot.asm | $(BUILD_DIR)
	$(ASM) $< -f bin -o $@
# $<   the first prerequisite $(SRC_DIR)/bootloader/boot.asm
# $@   the target the file being built $(BUILD_DIR)/bootloader.bin

# --------- kernel ----------------------------
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: $(SRC_DIR)/kernel/main.asm | $(BUILD_DIR)
	$(ASM) $(ASM_FLAGS) -o $(BUILD_DIR)/kernel/asm/main.obj $<
	$(ASM) $(ASM_FLAGS) -o $(BUILD_DIR)/kernel/asm/print.obj $(SRC_DIR)/kernel/print.asm
	$(CC16) $(C_FLAGS16) -fo=$(BUILD_DIR)/kernel/c/main.obj $(SRC_DIR)/kernel/main.c
	$(CC16) $(C_FLAGS16) -fo=$(BUILD_DIR)/kernel/c/stdio.obj $(SRC_DIR)/kernel/stdio.c
	$(LD16) NAME $@ FILE \{$(BUILD_DIR)/kernel/asm/main.obj $(BUILD_DIR)/kernel/asm/print.obj \
		$(BUILD_DIR)/kernel/c/main.obj $(BUILD_DIR)/kernel/c/stdio.obj \} \
		OPTION MAP=${BUILD_DIR}/kernel.map @${SRC_DIR}/kernel/linker.lnk

# ---------- Create build dir if missing -------
.PHONY: $(BUILD_DIR)
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)/kernel/asm 
	mkdir -p $(BUILD_DIR)/kernel/c

# ---------- check tools ----------
.PHONY: check_tools
check_tools:
	@command -v nasm >/dev/null 2>&1 || { \
		echo "nasm missing. Run 'make install_tools' (Ubuntu/Debian)."; exit 1; }
	@command -v dd >/dev/null 2>&1 || { \
		echo "dd missing. Run 'make install_tools' (Ubuntu/Debian)."; exit 1; }
	@command -v mkfs.fat >/dev/null 2>&1 || { \
		echo "mkfs.fat missing. Run 'make install_tools' (Ubuntu/Debian)."; exit 1; }
	@command -v mcopy >/dev/null 2>&1 || { \
		echo "mcopy missing. Run 'make install_tools' (Ubuntu/Debian)."; exit 1; }
	@test -x $(CC16) || { \
		echo "Open Watcom 16-bit not found at $(CC16)"; \
		echo "Run make WATCOM=/path after installing, to set path if needed"; exit 1; }
	@test -x $(LD16) || { \
		echo "Open Watcom 16-bit linker not found at $(LD16)"; \
		echo "Run make WATCOM=/path after installing to set path if needed"; exit 1; }

# ---------- install required tools ----------
# for Ubuntu/Debian systems (apt-based)
.PHONY: install_tools
install_tools:
	echo "Installing required build tools..."
	sudo apt update
	sudo apt install -y nasm coreutils dosfstools mtools
	echo "All required tools installed!"
# ------ clean ----------------------------------
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/*