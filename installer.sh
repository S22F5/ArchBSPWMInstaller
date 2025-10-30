#!/usr/bin/env bash
set -eEo pipefail
###----------------------------variables---------------------------###
# Install Drive (!!!will be wiped!!!)
DRIVE='/dev/sda'
# Main User
USER_NAME='user'
# Root User Password (please use a strong one)
ROOT_PASSWORD='root'
# Main User Password (please use a strong one)
USER_PASSWORD='pass'
#LUKS Password (please use a strong one) (empty for no disk encryption)
LUKS_PASSWORD='luks'
#GRUB Password (please use a strong one)
GRUB_PASSWORD='grub'
# Keymap
KEYMAP='us'
# Mirror Country (lowercase)
MIRROR_COUNTRY='germany'
# Timezone in "Zone/City" Format
TIMEZONE='Europe/Vienna'
# Locale
LOCALE='en_US.UTF-8'
# Swap File Size in GB (0=do not create) (excessive usage of swap will cause wear on SSDs)
SWAPFILE_SIZE_GB=0
# Laptop Install (add firmware updater, laptop power management)
LAPTOP_INSTALL=true
# Use Lockscreen (recommended for laptop)
LOCKSCREEN=true
###-------------------------output_function-----------------------###
echo "  __.__                                       "
echo "  | * |        ArchBSPWMInstaller         ___ "
echo " _|___|_            by s22f5             _|_|_"
echo " (*~ ~*)                                 (*~*)"
echo "  Made for: | Intel CPU | AMD GPU | SDD Drive "
echo "  Will Install my Personal BSPWM/Tint2 System "
sleep 1
#output function
function output() {
	clear
	spacelen=$((34 - $1 + 1))
	printf "[ "
	eval "printf '#%.0s' {1..$1}"
	eval "printf ' %.0s' {1..$spacelen}"
	printf ']\n'
}

echo "extracting files"
#extract files used
tar -xf files.tar.gz
clear
###--------------------------sanity_checks-------------------------###
#check internet connection
if ! ping 8.8.8.8 -c 1 > /dev/null 2>&1; then
	echo "[E] Network Error"
	exit
fi
#check if the drive exists
if [ ! -e "$DRIVE" ]; then
	echo "[E] Drive ""$DRIVE"" does not exist!"
	exit
fi
##------------------------------------------------------------------##
#check for uefi(0=bios,1=uefi)
if [ -d "/sys/firmware/efi" ]; then
	UEFI=1
else
	UEFI=0
fi

output 1 #checked for UEFI
##------------------------------------------------------------------##
#set time using ntp
timedatectl set-ntp true

output 2 #set time using ntp
##------------------------------------------------------------------##
dd if=/dev/zero of="$DRIVE" bs=100M count=10 status=progress
parted "$DRIVE" --script mklabel gpt

output 3 #erased $DRIVE
##------------------------------------------------------------------##
if [[ $UEFI -gt 0 ]]; then
	#create EFI partition
	parted "$DRIVE" --script mklabel gpt
	parted "$DRIVE" --script mkpart ESP fat32 1MiB 512MiB
	parted "$DRIVE" --script set 1 boot on
	parted "$DRIVE" --script name 1 efi
else
	#create BIOS partition
	#parted "$DRIVE" --script mklabel msdos
	parted "$DRIVE" --script mklabel gpt
	parted "$DRIVE" --script mkpart primary 1MiB 8MiB
	parted "$DRIVE" --script set 1 boot off
	parted "$DRIVE" --script set 1 bios_grub on
fi

output 4 #created "$DRIVE"1
##------------------------------------------------------------------##
if [[ $UEFI -gt 0 ]]; then
	BASE=512
else
	BASE=8
fi
#create  root partition
parted "$DRIVE" --script mkpart primary $BASE"MiB" 100%
parted "$DRIVE" --script name 2 root

output 5 #created "$DRIVE"2
##------------------------------------------------------------------##
if [[ $UEFI -gt 0 ]]; then
	if [[ -z "$LUKS_PASSWORD" ]]; then
		mkfs.ext4 "$DRIVE"2
		mount "$DRIVE"2 /mnt
	else
		mkfs.ext4 "$DRIVE"2
		printf "%s" "$LUKS_PASSWORD" | cryptsetup -q luksFormat "$DRIVE"2
		printf "%s" "$LUKS_PASSWORD" | cryptsetup open "$DRIVE"2 cryptroot
		mkfs.ext4 /dev/mapper/cryptroot
		mount /dev/mapper/cryptroot /mnt
	fi
else
	if [[ -z "$LUKS_PASSWORD" ]]; then
		mkfs.ext4 "$DRIVE"2
		mount "$DRIVE"2 /mnt
	else
		printf "%s" "$LUKS_PASSWORD" | cryptsetup -q luksFormat --type luks1 "$DRIVE"2
		printf "%s" "$LUKS_PASSWORD" | cryptsetup open "$DRIVE"2 cryptroot
		mkfs.ext4 /dev/mapper/cryptroot
		mount /dev/mapper/cryptroot /mnt
	fi
fi

if [[ $UEFI -gt 0 ]]; then
	#format EFI partition
	mkfs.fat -F 32 "$DRIVE"1
fi

output 6 #formated and mounted partitions
##------------------------------------------------------------------##
reflector --country $MIRROR_COUNTRY -l 10 --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

output 7 #got fastest mirror in "$MIRROR_COUNTRY" using reflector
##------------------------------------------------------------------##
pacstrap /mnt base linux-hardened linux-firmware mesa iwd efibootmgr xf86-video-amdgpu vulkan-radeon xf86-video-ati xf86-video-amdgpu freetype2 vim xorg-server xorg-xinit xterm feh libva-mesa-driver xorg tint2 jgmenu pavucontrol qt5-base xfce4-settings pulseaudio ntfs-3g exfat-utils dhcpcd nano git zip unzip picom gvfs gvfs-mtp pcmanfm sudo bspwm sxhkd alsa-firmware alsa-lib alsa-plugins ffmpeg gst-libav gst-plugins-base gst-plugins-good gstreamer qt6-base libmad libmatroska pamixer pulseaudio-alsa xdg-user-dirs arandr dunst exo gnome-keyring gsimplecal wmctrl man-pages man-db 7zip terminus-font xorg-xset xorg-xsetroot dmenu rxvt-unicode git htop base-devel xbindkeys playerctl adapta-gtk-theme htop rofi wget intel-ucode torsocks mpv neovim redshift torbrowser-launcher firejail clang bash-completion wireguard-tools arch-audit adapta-gtk-theme vbindiff dog cdrtools flac gcc gcc-libs gdb gzip tar innoextract llvm llvm-libs perl-image-exiftool nmap wine sed shfmt grep shellcheck ssh-audit strace tree feh mpv scrot

if [[ "$LAPTOP_INSTALL" = true ]]; then
	pacstrap /mnt tlp fwupd acpi cbatticon
	echo 'DEVICES_TO_ENABLE_ON_STARTUP="wifi"' >> /mnt/etc/tlp.conf
	echo "USB_AUTOSUSPEND=0" >> /mnt/etc/tlp.conf
	arch-chroot /mnt systemctl enable tlp
fi

if [[ "$LOCKSCREEN" = true ]]; then
	cat > /mnt/etc/X11/xorg.conf << EOF
Section "ServerFlags"
    Option "DontVTSwitch" "true"
EndSection
EOF
	pacstrap /mnt slock
	cat > /mnt/etc/systemd/system/slock@.service << EOF
[Unit]
Description=Lock X session using slock for user %i
Before=sleep.target

[Service]
User=%i
Environment=DISPLAY=:0
ExecStart=/usr/bin/slock

[Install]
WantedBy=sleep.target
EOF
fi

cat > /mnt/etc/X11/xorg.conf << EOF
Section "ServerFlags"
    Option "DontZap"      "True"
EndSection
EOF

output 8 #installed essential packages & changed configs
##------------------------------------------------------------------##
genfstab -U /mnt >> /mnt/etc/fstab

output 9 #generated fstab
##------------------------------------------------------------------##
if [[ "$SWAPFILE_SIZE_GB" -gt 0 ]]; then
	mkswap -U clear --size "$SWAPFILE_SIZE_GB"G --file /mnt/swapfile
	echo "/swapfile none swap defaults 0 0" >> /mnt/etc/fstab
fi
##------------------------------------------------------------------##
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
mkdir -p /mnt/var/lib/iwd/
cp /var/lib/iwd/*.psk /mnt/var/lib/iwd/

output 10 #copied some configs
##------------------------------------------------------------------##
arch-chroot /mnt passwd << EOD
$ROOT_PASSWORD
$ROOT_PASSWORD
EOD

output 11 #set root password
##------------------------------------------------------------------##
arch-chroot /mnt useradd -m -G users,video,log,rfkill,wheel,tty -s /bin/bash $USER_NAME

output 12 #added "$USER_NAME"
##------------------------------------------------------------------##
arch-chroot /mnt passwd $USER_NAME -d
echo "%wheel ALL=(ALL:ALL) ALL" >> /mnt/etc/sudoers
printf "cd /home/%s && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm" "$USER_NAME" | arch-chroot /mnt /bin/bash -c "su $USER_NAME"
rm -R /mnt/home/"$USER_NAME"/yay-bin/
output 13 #installed yay
##------------------------------------------------------------------##
arch-chroot /mnt passwd $USER_NAME << EOD
$USER_PASSWORD
$USER_PASSWORD
EOD

output 14 #set "$USER_NAME" password
##------------------------------------------------------------------##
arch-chroot /mnt pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
arch-chroot /mnt pacman-key --lsign-key 3056513887B78AEB
arch-chroot /mnt pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
echo "[chaotic-aur]" >> /mnt/etc/pacman.conf
echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /mnt/etc/pacman.conf
sed -i "s/#Color/Color/g" /mnt/etc/pacman.conf

output 15 #added chaotic repository
##------------------------------------------------------------------##
arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

output 16 #set timezone to "$TIMEZONE"
##------------------------------------------------------------------##
arch-chroot /mnt hwclock --systohc

output 17 #set time using bios clock
##------------------------------------------------------------------##
sed -i "s/^#\($LOCALE.*\)/\1/g" /mnt/etc/locale.gen
echo "LANG=$LOCALE" > /mnt/etc/locale.conf
arch-chroot /mnt locale-gen

output 18 #generated "$LOCALE" locale
##------------------------------------------------------------------##
touch /mnt/etc/vconsole.conf
echo "KEYMAP=$KEYMAP" > /mnt/etc/vconsole.conf
echo "FONT=lat9u-16" >> /mnt/etc/vconsole.conf
cat >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf << EOF
Section "InputClass"
    Identifier 		"system-keyboard"
    MatchIsKeyboard	"on"
    Option		"XkbLayout" "$KEYMAP"
EndSection
EOF
arch-chroot /mnt localectl set-x11-keymap "$KEYMAP"

output 19 #set installation keymap to "$KEYMAP"
##------------------------------------------------------------------##
if [[ "$LUKS_PASSWORD" != "" ]]; then
	dd bs=512 count=4 if=/dev/random iflag=fullblock | install -m 600 /dev/stdin /mnt/etc/cryptsetup-keys.d/cryptlvm.key
	printf "%s" "$LUKS_PASSWORD" | cryptsetup -v luksAddKey /dev/sda2 /mnt/etc/cryptsetup-keys.d/cryptlvm.key
	sed -i 's/FILES=()/FILES=(\/etc\/cryptsetup-keys.d\/cryptlvm.key)/g' /mnt/etc/mkinitcpio.conf
	#mkinitcpio find "keyboard" and replace with "keyboard encrypt"
	sed -i 's/(base.*/(base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck)/g' /mnt/etc/mkinitcpio.conf
fi

#generate initcpio
arch-chroot /mnt mkinitcpio -P

output 20 #created initcpio
##------------------------------------------------------------------##
echo "[multilib]" >> /mnt/etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> /mnt/etc/pacman.conf

output 21 #enabled multilib mirrors
##------------------------------------------------------------------##
arch-chroot /mnt wget "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" -O /etc/hosts
sed -i "17s/.*/127.0.1.1 placeholder/" /mnt/etc/hosts
#set iptables rules
mkdir -p /mnt/etc/iptables/
cp -f files/rules.v4 /mnt/etc/iptables/iptables.rules
#enable network services
arch-chroot /mnt systemctl enable iwd
arch-chroot /mnt systemctl enable dhcpcd
arch-chroot /mnt systemctl enable systemd-networkd
arch-chroot /mnt systemctl enable iptables
#set system hostname
touch /mnt/etc/hostname
echo "placeholder" > /mnt/etc/hostname

output 22 #setup networking
##------------------------------------------------------------------##
arch-chroot /mnt xbindkeys --defaults > /mnt/home/$USER_NAME/.xbindkeysrc || true

output 23 #setup xbinkeys
##------------------------------------------------------------------##
arch-chroot /mnt mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat > /mnt/etc/systemd/system/getty@tty1.service.d/skip-username.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -- $USER_NAME' --noclear --skip-login - $TERM
EOF
arch-chroot /mnt systemctl enable getty@tty1.service

output 24 #enabled autologin
##------------------------------------------------------------------##
#create grub password
grub_passhash="$(printf "%s\n%s" "$GRUB_PASSWORD" "$GRUB_PASSWORD" | grub-mkpasswd-pbkdf2 | sed 's/.*grub/grub/g' | tail -n1)"

if [[ $UEFI -gt 0 ]]; then
	#install and setup grub2 for uefi
	arch-chroot /mnt pacman -Sy chaotic-aur/grub-improved-luks2-git --noconfirm
	arch-chroot /mnt mkdir /boot/EFI
	arch-chroot /mnt mount "$DRIVE"1 /boot/EFI
	sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT="slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 pti=on randomize_kstack_offset=on vsyscall=none debugfs=off oops=panic module.sig_enforce=1 lockdown=confidentiality fs.protected_fifos=2 fs.protected_regular=2 kernel.kptr_restrict=1 kernel.modules_disabled=1 kernel.sysrq=0 net.ipv4.conf.all.log_martians=1 net.ipv4.conf.default.log_martians=1 ipv6.disable=1 quiet loglevel=0"' /mnt/etc/default/grub
	if [[ "$LUKS_PASSWORD" != "" ]]; then
		uuid="$(blkid "$DRIVE"2 -o value | head -n 1)"
		sed -i "s|GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$uuid:cryptroot root=/dev/mapper/cryptroot cryptkey=rootfs:/etc/cryptsetup-keys.d/cryptlvm.key\"|" /mnt/etc/default/grub
		echo "GRUB_ENABLE_CRYPTODISK=y" >> /mnt/etc/default/grub
	fi
	printf "set superusers=root\npassword_pbkdf2 root %s\n" "$grub_passhash" >> /mnt/etc/grub.d/40_custom
	arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub_uefi --removable
	sed -i "/\$os/s/grub_quote)'/grub_quote)' --unrestricted/" /mnt/etc/grub.d/10_linux
	sed -i "/\$os/s/grub_quote)'/grub_quote)' --unrestricted/" /mnt/etc/grub.d/20_linux_xen
	arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
else
	#install and setup grub2 for mbr/bios
	arch-chroot /mnt pacman -Sy core/grub --noconfirm
	sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT="slab_nomerge init_on_alloc=1 init_on_free=1 pti=on randomize_kstack_offset=on vsyscall=none debugfs=off oops=panic lockdown=confidentiality fs.protected_fifos=2 fs.protected_regular=2 kernel.kptr_restrict=1 kernel.modules_disabled=1 kernel.sysrq=0 net.ipv4.conf.all.log_martians=1 net.ipv4.conf.default.log_martians=1 ipv6.disable=1 quiet loglevel=0"' /mnt/etc/default/grub
	uuid="$(blkid "$DRIVE"2 -o value | head -n 1)"
	if [[ "$LUKS_PASSWORD" != "" ]]; then
		sed -i "s|GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$uuid:cryptroot root=/dev/mapper/cryptroot cryptkey=rootfs:/etc/cryptsetup-keys.d/cryptlvm.key\"|" /mnt/etc/default/grub
		echo "GRUB_ENABLE_CRYPTODISK=y" >> /mnt/etc/default/grub
	fi
	printf "set superusers=root\npassword_pbkdf2 root %s\n" "$grub_passhash" >> /mnt/etc/grub.d/40_custom
	sed -i "/\$os/s/grub_quote)'/grub_quote)' --unrestricted/" /mnt/etc/grub.d/10_linux
	sed -i "/\$os/s/grub_quote)'/grub_quote)' --unrestricted/" /mnt/etc/grub.d/20_linux_xen
	arch-chroot /mnt grub-install --target=i386-pc "$DRIVE"
	arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
fi

output 25 #configured grub
##------------------------------------------------------------------##
#setup configs
cp -r -f files/home/user/. /mnt/home/$USER_NAME/
echo "feh --bg-fill /home/$USER_NAME/.bg.png" >> /mnt/home/$USER_NAME/.xprofile

output 26
##------------------------------------------------------------------##
#install yay packages
arch-chroot /mnt sudo -u $USER_NAME yay --sudoflags -S -S cmus macchanger libreoffice qdirstat noto-fonts noto-fonts-extra noto-fonts-cjk ttf-liberation wmname yt-dlp icecat-bin lynis newsboat ytsub-bin qbittorrent chkrootkit cudatext-qt6-bin detect-it-easy-bin iat qdirstat arc-solid-gtk-theme flacon winetricks mason.nvim neovim-nightfox openbsd-netcat libsixel pkgconf --noconfirm --needed << EOF
${USER_PASSWORD}
EOF

arch-chroot /mnt sudo -u $USER_NAME yay -Scc --noconfirm

cp files/archlabs-icons-1.4-2-x86_64.pkg.tar.zst /mnt/usr/share/themes/
cp files/archlabs-themes-1.5.9-1-x86_64-nomurrine.pkg.tar.xz /mnt/usr/share/themes/
arch-chroot /mnt pacman -U --noconfirm /usr/share/themes/archlabs-icons-1.4-2-x86_64.pkg.tar.zst
arch-chroot /mnt pacman -U --noconfirm /usr/share/themes/archlabs-themes-1.5.9-1-x86_64-nomurrine.pkg.tar.xz
rm /mnt/usr/share/themes/archlabs-icons-1.4-2-x86_64.pkg.tar.zst
rm /mnt/usr/share/themes/archlabs-themes-1.5.9-1-x86_64-nomurrine.pkg.tar.xz

arch-chroot /mnt locale-gen

output 27 #setup themes
##------------------------------------------------------------------##
printf "install uvcvideo /bin/false" >> /mnt/etc/modprobe.d/webcam_block.conf
#can cause no audio output
#printf "install snd_hda_intel /bin/false" >> /mnt/etc/modprobe.d/microphone_block.conf
chmod 600 /mnt/etc/modprobe.d/*.conf

output 28 #blocked webcam modules
##------------------------------------------------------------------##
mkdir -p /mnt/etc/sysctl.d/
cp files/security.conf /mnt/etc/sysctl.d/security.conf

output 29 #added kernel parameters
##------------------------------------------------------------------##
touch /mnt/etc/machine-id
arch-chroot /mnt chown root /etc/machine-id
chmod 664 /mnt/etc/machine-id
#disable coredumps
printf "%s\n%s\n" "* hard core 0" "* soft core 0" >> /mnt/etc/security/limits.conf

output 30 #changed configs
##------------------------------------------------------------------##
#setup cmus
mkdir -p "/mnt/home/$USER_NAME/.config/cmus/"
arch-chroot /mnt /bin/bash -c "cd /home/$USER_NAME/.config/cmus/ && git clone https://github.com/S22F5/cmus_sixel.git && cd cmus_sixel && gcc -O3 main.c -o cmus_sixel -lsixel -lavformat -lavcodec -lswscale -lavutil && cp cmus_sixel.conf ../ && cp cmus_sixel ../cmus_sixel-tmp"
rm -Rvf /mnt/home/"$USER_NAME"/.config/cmus/cmus-sixel
mv /mnt/home/"$USER_NAME"/.config/cmus/cmus_sixel-tmp /mnt/home/"$USER_NAME"/.config/cmus/cmus_sixel
arch-chroot /mnt /bin/bash -c "cmus & sleep 1 && cmus-remote -C 'set status_display_program=~/.config/cmus/cmus-sixel'" || true #doesnt work currently

output 31 #installed extra packages
##------------------------------------------------------------------##
curl -s "https://www.behindthename.com/top/lists/$MIRROR_COUNTRY/2000" | grep "nlcm" | sed 's/.*nlcm">//g' | cut -d "<" -f 1 | sed "s/$/'s iPhone/" >> files/hostnames
curl -s "https://www.behindthename.com/top/lists/$MIRROR_COUNTRY/2000" | grep "nlcm" | sed 's/.*nlcm">//g' | cut -d "<" -f 1 | sed "s/$/'s iPad/" >> files/hostnames
cp files/hostnames /mnt/etc/hostnames
cp files/change_hostname.sh /mnt/usr/bin/change_hostname.sh
cp files/hostname_changer.service /mnt/etc/systemd/system/hostname_changer.service
chmod 644 /mnt/etc/systemd/system/hostname_changer.service
arch-chroot /mnt systemctl enable hostname_changer
printf "\nnoipv6\nnoipv6rs\nnohook resolv.conf\n" >> /mnt/etc/dhcpcd.conf
echo "nameserver 127.0.0.53" > /mnt/etc/resolv.conf
echo "options edns0 trust-ad" >> /mnt/etc/resolv.conf
chattr +i /mnt/etc/resolv.conf
mkdir /mnt/etc/systemd/resolved.conf.d
cat >> /mnt/etc/systemd/resolved.conf.d/dns_over_tls.conf << EOF
[Resolve]                                                                                                                                                                                                                                                              
DNS=9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net 1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com
DNSOverTLS=yes
Domains=~.
EOF
arch-chroot /mnt systemctl enable systemd-resolved
sed -i 's/agetty --noreset/agetty --nohostname --noreset/g' /mnt/lib/systemd/system/getty@.service
sed -i 's/\\u@\\h/\\[\\e[1m\\]\\u\\[\\e[0m\\]/g' /mnt/etc/bash.bashrc
if [[ "$LOCKSCREEN" = true ]]; then
	arch-chroot /mnt systemctl enable slock@"$USER_NAME".service
fi

output 32
##------------------------------------------------------------------##
cp files/issue /mnt/etc/issue
cp files/issue /mnt/etc/issue.net
echo "Banner /etc/issue" >> /mnt/etc/ssh/sshd_config
echo "TMOUT=300" >> /mnt/etc/profile
arch-chroot /mnt /bin/bash -c "install -m 0640 /dev/null /etc/at.allow"
arch-chroot /mnt /bin/bash -c "install -m 0640 /dev/null /etc/at.deny"
arch-chroot /mnt /bin/bash -c "install -m 0640 /dev/null /etc/cron.allow"
arch-chroot /mnt chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/
arch-chroot /mnt /bin/bash -c "sudo -u $USER_NAME dbus-run-session -- dconf load / < /home/$USER_NAME/.config/dconf/restore"
arch-chroot /mnt /bin/bash -c "sudo -u $USER_NAME xdg-user-dirs-update"
if [[ "$LAPTOP_INSTALL" = true ]]; then
	sed -i 's/wmname.*/wmname LG3D \&\ncbatticon \&/g' /mnt/home/$USER_NAME/.xinitrc
fi
output 33
##------------------------------------------------------------------##
umount /mnt
if [[ "$LUKS_PASSWORD" != "" ]]; then
	cryptsetup close cryptroot
fi
umount "$DRIVE"1 || true
output 34
###----------------------------------------------------------------###
printf " *DONE*\nthanks for using this script.\n\a"
exit
