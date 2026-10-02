#ifndef _SYSINFO_H
#define _SYSINFO_H

#include <stddef.h>

#define VERSION "0.3.1"

struct sysinfo {
	char *cpu;
	char *arch;
	char *platform;
	size_t nvol;
	size_t vol;
	char *version;
};

struct sysinfo get_sysinfo(void);

#endif