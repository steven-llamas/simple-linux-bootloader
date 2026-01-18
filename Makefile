# -------------- variables --------------------- 
ASM=nasm
SRC_DIR=src
BUILD_DIR=build

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
#$<   the first prerequisite $(SRC_DIR)/bootloader/boot.asm
#$@   the target the file being built $(BUILD_DIR)/bootloader.bin

# --------- kernel ----------------------------
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: $(SRC_DIR)/kernel/main.asm | $(BUILD_DIR)
	$(ASM) $< -f bin -o $@

# ---------- Create build dir if missing -------
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

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