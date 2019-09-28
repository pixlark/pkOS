#!/usr/bin/env python3

import os.path
from scripter import *

def do(cmd):
	print(cmd)
	res = run(cmd)
	if res.code != 0:
		print("Ran into error! Stderr:\n{0}".format(res.err))
		exit(1)

def make_obj(name):
	# Make directory for build if nonexistent
	dirname = os.path.dirname(name)
	do("mkdir -p build/{0}".format(dirname))

	# Try .c, then .s
	sourceType = ".c"	
	if not os.path.isfile("src/{0}.c".format(name)):
		sourceType = ".s"

	# Build object
	cmd = "i686-elf-gcc -c src/{0}{1} -o build/{0}.o -std=c99 -ffreestanding -O2 -Wall -Wextra -nostdlib -Iinclude" \
		.format(name, sourceType)
	do(cmd)

def main():	
	# 1: Build all objects
	names = [
		"boot",
		"kernel/kernel",
		"kernel/tty",
	]
	for n in names:
		make_obj(n)
	# 2: Link .bin file
	objects = ' '.join(map(lambda n: "build/{0}.o".format(n), names))
	do("i686-elf-gcc -T src/linker.ld {0} -o build/pkos.bin -ffreestanding -O2 -nostdlib -lgcc"
	   .format(objects))
	## 2.5: Check that multiboot is valid
	do("tools/check-multiboot build/pkos.bin")
	# 3: Make iso
	do("mkdir -p build/isodir/boot/grub")
	do("cp build/pkos.bin build/isodir/boot/")
	do("cp src/grub.cfg build/isodir/boot/grub/")
	do("grub-mkrescue -o build/pkos.iso build/isodir")

if __name__ == '__main__':
	main()
