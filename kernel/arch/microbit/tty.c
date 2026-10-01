#include <kernel/tty.h>

extern void init(void);
extern void putc(char c);

void terminal_initialize(void) {
	init();
}

void terminal_putchar(char c) {
	putc(c);
}

void terminal_write(const char* data, size_t size) {
	for (size_t i = 0; i < size; i++)
		terminal_putchar(data[i]);
}