OS=pkos
SRC=src
BUILD=build
TOOLS=tools
INCLUDE=include
CFLAGS=-std=c99 -ffreestanding -O2 -Wall -Wextra -nostdlib -I$(INCLUDE)

all: dirs $(BUILD)/$(OS).iso

$(BUILD)/$(OS).iso: $(BUILD)/$(OS).bin $(SRC)/grub.cfg
	mkdir -p $(BUILD)/isodir/boot/grub
	cp $(BUILD)/$(OS).bin $(BUILD)/isodir/boot/$(OS).bin
	cp $(SRC)/grub.cfg $(BUILD)/isodir/boot/grub/grub.cfg
	grub-mkrescue -o $(BUILD)/$(OS).iso $(BUILD)/isodir

$(BUILD)/$(OS).bin: $(BUILD)/boot.o $(BUILD)/kernel/kernel.o $(BUILD)/kernel/tty.o
	i686-elf-gcc -T $(SRC)/linker.ld -o $(BUILD)/$(OS).bin -ffreestanding -O2 -nostdlib $(BUILD)/boot.o $(BUILD)/kernel/kernel.o $(BUILD)/kernel/tty.o -lgcc
	$(TOOLS)/check-multiboot $(BUILD)/$(OS).bin

$(BUILD)/boot.o: $(SRC)/boot.s
	i686-elf-as $(SRC)/boot.s -o $(BUILD)/boot.o

$(BUILD)/kernel/kernel.o: $(BUILD)/kernel/tty.o $(SRC)/kernel/kernel.c
	i686-elf-gcc -c $(SRC)/kernel/kernel.c -o $(BUILD)/kernel/kernel.o $(CFLAGS)

$(BUILD)/kernel/tty.o: $(SRC)/kernel/tty.c
	i686-elf-gcc -c $(SRC)/kernel/tty.c -o $(BUILD)/kernel/tty.o $(CFLAGS)

.PHONY=dirs clean

dirs:
	mkdir -p build/kernel

clean:
	rm -r $(BUILD)/*
