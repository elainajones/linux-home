#! /bin/bash

if ! mountpoint boot/; then
    echo '/boot is not mounted!'
    exit 1;
fi

root_dirs=($(find -maxdepth 1 -mindepth 1 -type d,l \
    ! -name 'dev' \
    ! -name 'proc' \
    ! -name 'sys' \
    ! -name 'tmp' \
    ! -name 'run' \
    ! -name 'home' \
    ! -name 'lost+found' \
));

# Clean the cache rather than exclude since this is
# safe and gives space back to the system.
rm -rf var/cache/*

time tar --exclude='var/lib/libvirt/images' \
    --exclude='usr/src' \
    --exclude='tmp/*' \
    --exclude='var/tmp/*' \
    --exclude='__pycache__/*' \
    --exclude='*\.iso' \
    --exclude='var/*\.log' \
    --exclude-vcs \
    -cvf $(cat etc/hostname)-rootfs-$(date +%Y%m%d).tar \
    ${root_dirs[*]} swapfile
