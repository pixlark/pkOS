OS=pkos
SRC=src
BUILD=build
TOOLS=tools

all: $(BUILD)/$(OS).iso

$(BUILD)/$(OS).iso: $(BUILD)/$(OS).bin
	mkdir -p $(BUILD)/isodir/boot/grub
	cp $(BUILD)/$(OS).bin $(BUILD)/isodir/boot/$(OS).bin
	cp $(SRC)/grub.cfg $(BUILD)/isodir/boot/grub/grub.cfg
	grub-mkrescue -o $(BUILD)/$(OS).iso $(BUILD)/isodir

$(BUILD)/$(OS).bin: $(BUILD)/boot.o $(BUILD)/kernel.o
	i686-elf-gcc -T $(SRC)/linker.ld -o $(BUILD)/$(OS).bin -ffreestanding -O2 -nostdlib $(BUILD)/boot.o $(BUILD)/kernel.o -lgcc
	$(TOOLS)/check-multiboot $(BUILD)/$(OS).bin

$(BUILD)/boot.o: $(SRC)/boot.s
	i686-elf-as $(SRC)/boot.s -o $(BUILD)/boot.o

$(BUILD)/kernel.o: $(SRC)/kernel.c
	i686-elf-gcc -c $(SRC)/kernel.c -o $(BUILD)/kernel.o -std=c99 -ffreestanding -O2 -Wall -Wextra

.PHONY=clean

clean:
	rm -r $(BUILD)/*
