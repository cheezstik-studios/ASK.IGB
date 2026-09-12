arm-none-eabi-as -mcpu=cortex-m0 -mthumb kernel.s -o kernel.o
arm-none-eabi-ld -T link.ld kernel.o -o kernel.elf
arm-none-eabi-objcopy -O ihex kernel.elf kernel.hex
qemu-system-arm -M microbit -device loader,file=kernel.hex -serial stdio