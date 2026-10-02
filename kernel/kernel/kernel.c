#include <stdio.h>

#include <kernel/tty.h>
#include <kernel/sysinfo.h>

void kernel_main(void) {
	terminal_initialize();
	printf("\033[H\033[2J\033[33m--- ASK.IGB ---\n-- Version %s --\n- %s -", get_sysinfo().version, get_sysinfo().platform);
}