#pragma once
#include <stddef.h>

void terminal_init();
void terminal_write_char(unsigned char c);
void terminal_write(const char* data, size_t size);
void terminal_write_string(const char* str);
