#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include <libk/string.h>

typedef enum {
	VGA_BLACK = 0,
	VGA_BLUE = 1,
	VGA_GREEN = 2,
	VGA_CYAN = 3,
	VGA_RED = 4,
	VGA_MAGENTA = 5,
	VGA_BROWN = 6,
	VGA_LIGHT_GREY = 7,
	VGA_DARK_GREY = 8,
	VGA_LIGHT_BLUE = 9,
	VGA_LIGHT_GREEN = 10,
	VGA_LIGHT_CYAN = 11,
	VGA_LIGHT_RED = 12,
	VGA_LIGHT_MAGENTA = 13,
	VGA_LIGHT_BROWN = 14,
	VGA_WHITE = 15,
} VGA_Color;

const size_t VGA_WIDTH  = 80;
const size_t VGA_HEIGHT = 25;

typedef uint8_t Color_Tuple;

typedef struct {
	size_t row;
	size_t col;
	Color_Tuple color;
	uint16_t* buffer;
} Terminal;

Terminal terminal;

Color_Tuple vga_color(VGA_Color fg, VGA_Color bg)
{
	return fg | (bg << 4);
}

typedef uint16_t VGA_Char;

VGA_Char vga_char(unsigned char c, Color_Tuple color)
{
	return ((uint16_t) c) | ((uint16_t) color << 8);
}

void terminal_init()
{
	terminal.row = 0;
	terminal.col = 0;
	terminal.color = vga_color(VGA_LIGHT_GREY, VGA_BLACK);
	terminal.buffer = (uint16_t*) 0xB8000;
	for (size_t y = 0; y < VGA_HEIGHT; y++) {
		for (size_t x = 0; x < VGA_WIDTH; x++) {
			terminal.buffer[y * VGA_WIDTH + x] =
				vga_char(' ', terminal.color);
		}
	}
}

static void terminal_set(VGA_Char c, size_t row, size_t col)
{
	terminal.buffer[row * VGA_WIDTH + col] = c;
}

static VGA_Char terminal_get(size_t row, size_t col)
{
	return terminal.buffer[row * VGA_WIDTH + col];
}

static void terminal_scroll()
{
	if (terminal.row == VGA_HEIGHT - 1) {
		// Scroll everything up
		for (size_t y = 1; y < VGA_HEIGHT; y++) {
			for (size_t x = 0; x < VGA_WIDTH; x++) {
				terminal_set(terminal_get(y, x), y - 1, x);
			}
		}
		for (size_t x = 0; x < VGA_WIDTH; x++) {
			terminal_set(vga_char(' ', vga_color(VGA_BLACK, VGA_BLACK)), VGA_HEIGHT - 1, x);
		}
	} else {
		terminal.row++;
	}
}

void terminal_write_char(unsigned char c)
{
	switch (c) {
	case '\r': {
		terminal.col = 0;
	} break;
	case '\n': {
		terminal.col = 0;
		terminal_scroll();
	} break;
	default: {
		terminal_set(vga_char(c, terminal.color), terminal.row, terminal.col);
		terminal.col++;
		if (terminal.col >= VGA_WIDTH) {
			terminal.col = 0;
			terminal_scroll();
		}
	} break;
	}
}

void terminal_write(const char* data, size_t size)
{
	for (size_t i = 0; i < size; i++) {
		terminal_write_char(data[i]);
	}
}

void terminal_write_string(const char* str)
{
	terminal_write(str, string_length(str));
}
