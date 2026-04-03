#! /usr/bin/env bash

declare base=(
    # Filesystems
    "net-fs/cifs-utils"
    "net-fs/sshfs"
    "sys-fs/jmtpfs"
    "sys-fs/ntfs3g"
    "sys-fs/dosfstools"
    "sys-fs/exfatprogs"
    # Archive tools
    "app-arch/unzip"
    "app-arch/zip"
    # Developer tools
    "app-vim/gnupg"
    "app-editors/vim"
    "dev-vcs/git"
    "app-text/dos2unix"
    "dev-util/ctags" # ctags needed for jump to definition in vim
    "app-eselect/eselect-python"
    # dev-lang/go
    # Networking
    "net-analyzer/netcat"
    "net-analyzer/arp-scan"
    "net-analyzer/nmap"
    "net-misc/networkmanager"
    # System/Admin tools
    "sys-apps/pciutils"
    "sys-apps/usbutils"
    "sys-apps/smartmontools"
    "app-misc/tmux"
    "app-misc/screen"
    "sys-process/htop"
    "app-portage/gentoolkit" # 'equery uses <package>' to see available use flags
    "sys-fs/cryptsetup"
    "sys-process/fcron"
    "app-admin/sysklogd"
    "app-eselect/eselect-repository"
    # Bash tools
    "app-admin/sudo"
    "app-shells/bash-completion"
    # Multimedia
    "app-text/ghostscript-gpl"
    "media-libs/exiftool"
    # Web
    "www-client/links"
)

declare desktop=(
    # Fonts
    "media-fonts/joypixels"
    "media-fonts/noto"
    "media-fonts/noto-cjk"
    "media-fonts/noto-emoji"
    "media-fonts/fontawesome"
    "media-fonts/liberation-fonts"
    "media-fonts/dejavu"
    "media-fonts/terminus-font"
    # Spelling
    "app-dicts/aspell-en"
    "app-dicts/myspell-en"
    # Web
    "www-client/firefox"
    "www-client/google-chrome"
    # Multimedia
    "app-text/atril"
    "app-office/libreoffice"
    "app-text/xournalpp"
    "media-gfx/ristretto"
    "media-video/mpv"
    "media-video/vlc"
    "media-gfx/inkscape"
    "app-text/pdfarranger"
    # XFCE
    # "x11-misc/redshift"
    # "x11-themes/numix-gtk-theme"
    # "xfce-base/xfce4-meta"
    # "xfce-extra/xfce4-battery-plugin"
    # "xfce-extra/xfce4-clipman-plugin"
    # "xfce-extra/xfce4-cpufreq-plugin"
    # "xfce-extra/xfce4-cpugraph-plugin"
    # "xfce-extra/xfce4-notifyd"
    # "xfce-extra/xfce4-screenshooter"
    # "xfce-extra/xfce4-systemload-plugin"
    # "xfce-extra/xfce4-taskmanager"
    # "gnome-extra/nm-applet"
)

args=()
case $1 in
    base)
         args=(${base[@]})
        ;;
    desktop)
         args=(${desktop[@]})
        ;;
    *)
        exit
esac

emerge --ask ${args[@]}

# emerge --oneshot --ask \
#     app-portage/cpuid2cpuflags
