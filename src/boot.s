	.set ALIGN,    1
	.set MEMINFO,  1 << 1
	.set FLAGS,    ALIGN | MEMINFO
	.set MAGIC,    0x1BADB002 /* Indicates Multiboot 1, kernel */
	.set CHECKSUM, -(MAGIC + FLAGS)

	/* https://www.gnu.org/software/grub/manual/multiboot/multiboot.html#OS-image-format */
	
	.section .multiboot
	.align 4 /* Must be 32-bit aligned (4 bytes) */
	.long MAGIC
	.long FLAGS
	.long CHECKSUM

	.section .bss
	.align 16
stack_bottom:
	.skip 16384 /* 16 KiB */
stack_top:
	
	.section .text
	.global _start
	.type _start, @function
_start:
	/* Set the stack pointer to the top of the stack -- this is for
	the C code in kernal_main! */
	mov $stack_top, %esp 
	call kernel_main
	cli /* Disable interrupts (*cl*ear *i*nterrupt flag) */
1:	hlt /* Wait for next interrupt (will never happen! they're disabled) */
	jmp 1b /* If some non-maskable interrupt occurs, go back to halting  */

	/* Set size of _start symbol to current location (.) minus _start. */
	.size _start, . - _start
