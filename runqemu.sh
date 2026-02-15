#!/bin/bash
# Script to run QEMU for Buildroot as the default configuration qemu_aarch64_virt_defconfig.
# Host forwarding:
#   - Host port 10022 -> guest port 22 (SSH)
#   - Host port 9000  -> guest port 9000 (aesdsocket)
# Author: Siddhant Jajoo.

# Pseudocode Block 4: boot the AArch64 VM and expose ports needed for assignment testing.
# - Keep SSH forwarding for remote login and copy operations.
# - Add 9000 forwarding so host-side nc/telnet clients can reach aesdsocket.
qemu-system-aarch64 \
    -M virt \
    -cpu cortex-a53 -nographic -smp 1 \
    -kernel buildroot/output/images/Image \
    -append "rootwait root=/dev/vda console=ttyAMA0" \
    -netdev user,id=eth0,hostfwd=tcp::10022-:22,hostfwd=tcp::9000-:9000 \
    -device virtio-net-device,netdev=eth0 \
    -drive file=buildroot/output/images/rootfs.ext4,if=none,format=raw,id=hd0 \
    -device virtio-blk-device,drive=hd0 -device virtio-rng-pci
