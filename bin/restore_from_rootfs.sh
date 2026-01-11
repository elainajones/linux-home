#! /bin/bash

parse_args() {
    args=$@;
    declare -gA PARSED_ARGS=();
    for key in $(echo ${args[*]} | grep -oP "(^|[^\S])\-\S+"); do
        # Why am I like this?
        val=$(
            echo ${args[*]} | \
            grep -oP "(?<=$key).+?(?=\s\-|\Z|\s)" | \
            grep -oP "\S+" \
        );
        PARSED_ARGS["$key"]="$val";
    done
}

print_help() {
    help_lines=(\
        "TODO: help" \
    );

    for i in ${!help_lines[*]}; do
        line=${help_lines[$i]};
        echo $line;
    done
}

confirm_yes() {
    declare prompt="$@"
    declare -l opt;
    read -p "$prompt" opt;
    if ! [[ $opt ]]; then
        return 1;
    elif [[ $opt == "y" ]] || [[ $opt == "yes" ]]; then
        return 0;
    else
        return 1;
    fi
}

list_block() {
    name=$(echo $1 | grep -oP "(?<=/dev/)\S+");
    lsblk -o name,fstype,size,mountpoints,uuid | grep $name | grep "";
}

is_partition() {
    match_part=$(sudo blkid | grep -P "^$1(?=:)" | grep "PARTUUID");
    if [[ $match_part ]]; then
        return 0
    else
        return 1
    fi
}

main() {
    args=$@;
    parse_args $args;

    if ! (( ${#PARSED_ARGS[@]} )); then
        print_help;
        exit 1;
    fi

    for key in ${!PARSED_ARGS[@]}; do
        val="${PARSED_ARGS[$key]}";
        case $key in
            "-i")
                declare input_file=$val;
                ;;
            "-o")
                declare output_file=$val;
                ;;
            "-h")
                print_help;
                ;;
            *)
                echo "invalid option '$key'"
                print_help;
                exit 1;
                ;;
        esac
    done

    if ! [[ $input_file ]] || ! [[ $output_file ]]; then
        echo "Missing file operand";
        exit 1;
    elif ! [[ -f $input_file ]]; then
        echo "No such file '$input_file'";
        exit 1;
    elif ! [[ -b $output_file ]]; then
        echo "No such block device '$output_file'";
        exit 1;
    elif is_partition "$output_file"; then
        echo "'$output_file' cannot be a partition";
        exit 1;
    fi

    sleep 1;
    list_block $output_file;
    lsblk -o name,fstype,size,mountpoints,uuid | grep "crypt-root" | grep ""
    confirm_yes "Restore $input_file to $output_file? (y/N): " || exit 0;
    clear;
    sudo fdisk $output_file;
    sleep 1;
    list_block $output_file;
    lsblk -o name,fstype,size,mountpoints,uuid | grep "crypt-root" | grep ""
    confirm_yes "Continue? (y/N): " || exit 0;
    echo "";
    sleep 1;
    list_block $output_file;
    lsblk -o name,fstype,size,mountpoints,uuid | grep "crypt-root" | grep ""

    echo "Enter Boot/EFI partition";
    read -p "$output_file" efi_part;
    efi_part="${output_file}${efi_part}";
    echo "Enter root partition";
    read -p "$output_file" root_part;
    root_part="${output_file}${root_part}";

    if ! is_partition $efi_part; then
        echo "No such partition";
        exit 1;
    elif ! is_partition $root_part; then
        echo "No such partition";
        exit 1;
    elif [[ $efi_part == $root_part ]]; then
        echo "Boot/EFI and root partitions cannot be the same";
        exit 1;
    fi

    confirm_yes "$efi_part: format fat32? (y/N): " || exit 0;
    sudo mkfs.vfat -F32 $efi_part;
    confirm_yes "$root_part: format luks? (y/N): " || exit 0;
    sudo cryptsetup luksFormat --block-size 512 $root_part;
    echo "";
    sleep 1;
    list_block $output_file;
    lsblk -o name,fstype,size,mountpoints,uuid | grep "crypt-root" | grep ""
    confirm_yes "$root_part: decrypt root? (y/N): " || exit 0;
    sudo cryptsetup luksOpen $root_part crypt-root;
    echo "";
    sleep 1;
    list_block $output_file;
    lsblk -o name,fstype,size,mountpoints,uuid | grep "crypt-root" | grep ""
    confirm_yes "/dev/mapper/crypt-root: format ext4? (y/N): " || exit 0;
    sudo mkfs.ext4 /dev/mapper/crypt-root;
    echo ""
    sudo mkdir -vp /mnt/chroot;
    sudo mount -v /dev/mapper/crypt-root /mnt/chroot;
    sudo mkdir -vp /mnt/chroot/boot/;
    sudo mount -v $efi_part /mnt/chroot/boot;
    echo "";
    sleep 1;
    list_block $output_file;
    lsblk -o name,fstype,size,mountpoints,uuid | grep "crypt-root" | grep ""
    confirm_yes "$input_file: Extract to /mnt/chroot? (y/N): " || exit 0;
    sudo tar -xvf $input_file -C /mnt/chroot;
    echo "";
    sleep 1;
    list_block $output_file;
    lsblk -o name,fstype,size,mountpoints,uuid | grep "crypt-root" | grep ""
    echo "Update /etc/fstab /boot UUID";
    cat /mnt/chroot/etc/fstab | grep -P "^UUID.+\s/boot\s" | grep "";
    confirm_yes "Edit fstab (copy efi UUID)? (y/N): " || exit 0;
    sudo vim /mnt/chroot/etc/fstab;

    echo "Update /etc/fstab / UUID";
    cat /mnt/chroot/etc/fstab | grep -P "^UUID.+\s/\s" | grep "";
    root_uuid=$(\
        cat /mnt/chroot/etc/fstab | \
        grep -P "^UUID.+\s/\s" | \
        grep -oP "(?<=UUID\=)\S+" \
    );
    efi_uuid=$(\
        cat /mnt/chroot/etc/fstab | \
        grep -P "^UUID.+\s/boot\s" | \
        grep -oP "(?<=UUID\=)\S+" \
    );

    echo "Enter UUID for '/'";
    read -p "($root_uuid):" opt;
    [[ $opt == "" ]] || root_uuid=$opt;

    echo "";
    sleep 1;
    list_block $output_file;
    lsblk -o name,fstype,size,mountpoints,uuid | grep "crypt-root" | grep ""
    echo "\: UUID=$root_uuid";
    confirm_yes "/dev/mapper/crypt-root: Change UUID? (y/N): " || exit 0;

    sudo umount -v /mnt/chroot/boot;
    sudo umount -v /mnt/chroot;

    echo "";
    sleep 1;
    list_block $output_file;
    lsblk -o name,fstype,size,mountpoints,uuid | grep "crypt-root" | grep ""
    confirm_yes "Continue? (y/N): " || exit 0;

    sudo e2fsck -f /dev/mapper/crypt-root;
    sudo tune2fs -U $root_uuid /dev/mapper/crypt-root
    sudo mount -v /dev/mapper/crypt-root /mnt/chroot;

    echo "";
    sleep 1;
    list_block $output_file;
    lsblk -o name,fstype,size,mountpoints,uuid | grep "crypt-root" | grep ""
    cat /mnt/chroot/etc/default/grub | grep "crypt_root=UUID";
    crypt_uuid=$(\
    	cat /mnt/chroot/etc/default/grub | \
	grep -oP "(?<=crypt_root=UUID=)\S+" \
    );
    echo "Enter UUID for '$root_part'";
    read -p "($crypt_uuid):" opt;
    [[ $opt == "" ]] || crypt_uuid=$opt;

    echo "";
    sleep 1;
    list_block $output_file;
    lsblk -o name,fstype,size,mountpoints,uuid | grep "crypt-root" | grep ""
    echo $root_part: UUID=$crypt_uuid;
    confirm_yes "$root_part: Change UUID? (y/N): " || exit 0;

    sudo umount -v /mnt/chroot;
    echo "";
    sleep 1;
    list_block $output_file;
    lsblk -o name,fstype,size,mountpoints,uuid | grep "crypt-root" | grep ""
    confirm_yes "Continue? (y/N): " || exit 0;
    sudo cryptsetup luksUUID $root_part --uuid "$crypt_uuid"

    echo "";
    list_block $output_file;
    lsblk -o name,fstype,size,mountpoints,uuid | grep "crypt-root" | grep ""

    echo "Restore completed!";
}

main $@;

