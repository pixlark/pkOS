#include <kernel/tty.h>

void kernel_main()
{
	terminal_init();

	terminal_write_string("Hello, world!\n");
	terminal_write_string("How I would push my fingers through\n");
	terminal_write_string("Your mouth to make those muscles move\n");
	terminal_write_string("That made your voice so smooth and sweet\n");
}
