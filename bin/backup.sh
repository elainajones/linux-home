#! /bin/bash

root_dirs=($(find -maxdepth 1 -mindepth 1 -type d,l \
    ! -name 'dev' \
    ! -name 'proc' \
    ! -name 'sys' \
    ! -name 'tmp' \
    ! -name 'run' \
    ! -name 'home' \
    ! -name 'lost+found' \
));

rm -rf var/cache/*

time tar --exclude='var/lib/libvirt/images' \
    --exclude='usr/src' \
    --exclude='tmp/*' \
    -cvf $(cat etc/hostname)-rootfs-$(date +%Y%m%d).tar \
    ${root_dirs[*]} swapfile

