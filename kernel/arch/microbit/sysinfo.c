#include <kernel/sysinfo.h>

struct sysinfo get_sysinfo(void) {
	struct sysinfo info = {"Arm Cortex-M0", "ARM Thumb-1", "BBC micro:bit v1", 262144, 16384, VERSION};
	return info;
}