#include <stddef.h>

size_t string_length(const char* string)
{
	size_t length = 0;
	while (*string != '\0') {
		string++;
		length++;
	}
	return length;
}
