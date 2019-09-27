/* This linker script defines how the output object will be structured */

ENTRY(_start) /* Which symbol points to the first executed instruction? */

SECTIONS
{
	. = 1M; /* Move the location counter to 1M -- that's where .text will be located */

	.text BLOCK(4K) : ALIGN(4K)
	{
		/* The * is a wildcard meaning from *all* of the input
		files. .multiboot means to take all the multiboot sections
		from all the input files. */
		*(.multiboot)
		/* `boot.o(.multiboot)` works just as well! */
		*(.text)
	}

	.rodata BLOCK(4K) : ALIGN(4K)
	{
		*(.rodata)
	}

	.data BLOCK(4K) : ALIGN(4K)
	{
		*(.data)
	}

	.bss BLOCK(4K) : ALIGN(4K)
	{
		/* COMMON includes all common symbols. In C terms, these are
		global variables left uninitialized, for the purpose of having
		multiple external defintions under a common symbol. We don't
		have to worry about them, just throw them in .bss with the
		other global variables (which are under *(.bss)) */
		*(COMMON)
		*(.bss)
	}
}
