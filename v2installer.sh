#!/bin/bash
###---------------------------variables--------------------------###
# Install Drive (!!!will be wiped!!!)
DRIVE='/dev/sda'
# Hostname
HOSTNAME='hostname'
# Main User
USER_NAME='user'
# Root User Password.
ROOT_PASSWORD='root'
# Main User Password
USER_PASSWORD='pass'
#LUKS Password
LUKS_PASSWORD='correcthorsebatterystaple'
# Keymap
KEYMAP='us'
# Mirror Country
MIRROR_COUNTRY='Germany'
# Timezone in "Zone/City" Format
TIMEZONE='Europe/Vienna'
# Locale
LOCALE='en_US.UTF-8'
###------------------------output_function-----------------------###
echo "  __.__                                       "
echo "  | * |        ArchBSPWMInstaller         ___ "
echo " _|___|_            by s22f5             _|_|_"
echo " (*~ ~*)                                 (*~*)"
echo "  Made for: | Intel CPU | AMD GPU | SDD Drive "
echo "  Will Install my Personal BSPWM/Tint2 System "
sleep 1
#output function
outmsg=(
"[01]Checked for UEFI"
"[02]set time to using ntp"
"[03]erased $DRIVE"
"[04]created partition '$DRIVE'1"
"[05]created partition '$DRIVE'2"
"[06]formated partitions"
"[07]mounted '$DRIVE' to /mnt"
"[08]got fastest mirror in '$MIRROR_COUNTRY' using reflector"
"[09]installed essential packages"
"[10]generated fstab"
"[11]copied some configs"
"[12]set root password"
"[13]added '$USER_NAME'"
"[14]generated xdg user directory structure"
"[15]installed yay"
"[16]set '$USER_NAME' password"
"[17]added chaotic repository"
"[18]set timezone to '$TIMEZONE'"
"[19]set time using bios clock"
"[20]generated '$LOCALE' locale"
"[21]set installation keymap to '$KEYMAP'"
"[22]created initcpio"
"[23]enabled multilib mirrors"
"[24]setup networking"
"[25]setup xbinkeys"
"[26]enabled autologin"
"[27]configured grub"
"[28]setup bash_profile"
"[29]setup xinitrc"
"[30]setup bspwmrc"
"[31]setup background"
"[32]setup xprofile"
"[33]setup tint2rc & sxhkd"
"[34]setup xterm"
"[35]setup jgmenu"
"[36]fixed gsimplecal"
"[37]setup themes"
"[38]fixed some permissions"
"[39]blocked webcam and microphone modules"
"[40]added kernel parameters"
"[41]changed configs"
"[42]installed extra packages"
"[43]setup macchanger"
"[44]unmounted partitions"
"[45]DONE! thanks for using this script"
)
function output() {
clear
printf '%s\n' "${outmsg[@]:0:$1}"
}
echo "extracting files"
#extract files used
tar -xf files.tar.gz
clear
###-------------------------sanity_checks------------------------###
#check internet connection
if ! ping 8.8.8.8 -c 1 >/dev/null 2>&1;
then
    echo "[E] Network Error"
    exit
fi
#check if the drive exists
if [ ! -e "$DRIVE" ]
then
	echo "[E] Drive ""$DRIVE"" does not exist!"
	exit
fi
#get network interface name
#INTERFACE=$(ip route get 1.1.1.1 | awk '{print $5}')
#--------------------------------01--------------------------------#
#check for uefi(0=bios,1=uefi)
if [ -d "/sys/firmware/efi" ]; then
	UEFI=1
else
	UEFI=0
fi

output 1 #checked for UEFI
#--------------------------------02--------------------------------#
#set time to using ntp
timedatectl set-ntp true

output 2 #set time to using ntp
#--------------------------------03--------------------------------#
dd if=/dev/zero of="$DRIVE" bs=100M count=10 status=progress
parted "$DRIVE" --script mklabel gpt

output 3 #erased $DRIVE
#--------------------------------04--------------------------------#
if [[ $UEFI -gt 0 ]]
then
	#create EFI partition
	parted "$DRIVE" --script mklabel gpt
	parted "$DRIVE" --script mkpart ESP fat32 1MiB 512MiB
	parted "$DRIVE" --script set 1 boot on
	parted "$DRIVE" --script name 1 efi
	#
	output 6
else
	#create BIOS partition
	#parted "$DRIVE" --script mklabel msdos
	parted "$DRIVE" --script mklabel gpt
	parted "$DRIVE" --script mkpart primary 1MiB 8MiB
	parted "$DRIVE" --script set 1 boot off
	parted "$DRIVE" --script set 1 bios_grub on
	output 5
	echo "[6] Created BIOS partition"
fi

output 4 #created "$DRIVE"1
#--------------------------------05--------------------------------#
if [[ $UEFI -gt 0 ]]
then
	BASE=512
else
	BASE=8
fi
#create  root partition
parted "$DRIVE" --script mkpart primary $BASE"MiB" 100%
parted "$DRIVE" --script name 2 root

output 5 #created "$DRIVE"2
#--------------------------------06--------------------------------#
if [[ $UEFI -gt 0 ]]
then
	printf "%s" "$LUKS_PASSWORD" | cryptsetup -q luksFormat "$DRIVE"2
else
	printf "%s" "$LUKS_PASSWORD" | cryptsetup -q luksFormat --type luks1 "$DRIVE"2
fi

printf "%s" "$LUKS_PASSWORD" | cryptsetup open "$DRIVE"2 cryptroot
mkfs.ext4 /dev/mapper/cryptroot

if [[ $UEFI -gt 1 ]]
then
#format EFI partition
mkfs.fat -F 32 "$DRIVE"1
fi

output 6 #formated partitions
#--------------------------------07--------------------------------#
mount /dev/mapper/cryptroot /mnt

output 7 #mounted "$DRIVE" to /mnt
#--------------------------------08--------------------------------#
reflector --country $MIRROR_COUNTRY -l 10 --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

output 8 #got fastest mirror in "$MIRROR_COUNTRY" using reflector
#--------------------------------09--------------------------------#
pacstrap /mnt base linux-hardened linux-firmware mesa iwd efibootmgr xf86-video-amdgpu vulkan-radeon xf86-video-ati xf86-video-amdgpu freetype2 vim xorg-server xorg-xinit xterm feh libva-mesa-driver xorg tint2 jgmenu pavucontrol qt5-base xfce4-settings pulseaudio ntfs-3g exfat-utils dhcpcd nano mousepad git zip unzip picom gvfs gvfs-mtp thunar sudo bspwm sxhkd alsa-firmware alsa-lib alsa-plugins ffmpeg gst-libav gst-plugins-base gst-plugins-good gstreamer qt6-base libmad libmatroska pamixer pulseaudio-alsa xdg-user-dirs arandr dunst exo gnome-keyring gsimplecal wmctrl man-pages man-db p7zip terminus-font xorg-xset xorg-xsetroot dmenu rxvt-unicode trayer git htop base-devel xbindkeys playerctl adapta-gtk-theme arc-solid-gtk-theme htop rofi wget intel-ucode torsocks mpv neovim redshift torbrowser-launcher firejail

output 9 #installed essential packages
#--------------------------------10--------------------------------#
genfstab -U /mnt >> /mnt/etc/fstab

output 10 #generated fstab
#--------------------------------11--------------------------------#
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
mkdir -p /mnt/var/lib/iwd/
cp /var/lib/iwd/*.psk /mnt/var/lib/iwd/

output 11 #copied some configs
#--------------------------------12--------------------------------#
arch-chroot /mnt passwd << EOD
$ROOT_PASSWORD
$ROOT_PASSWORD
EOD

output 12 #set root password
#--------------------------------13--------------------------------#
arch-chroot /mnt useradd -m -G users,video,log,rfkill,wheel,tty -s /bin/bash $USER_NAME

output 13 #added "$USER_NAME"
#--------------------------------14--------------------------------#
arch-chroot /mnt xdg-user-dirs-update

output 14 #generated xdg user directory structure
#--------------------------------15--------------------------------#
arch-chroot /mnt passwd $USER_NAME -d
echo "%wheel ALL=(ALL:ALL) ALL" >> /mnt/etc/sudoers
printf "cd /home/%s && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm" "$USER_NAME" | arch-chroot /mnt /bin/bash -c "su $USER_NAME"
rm -R /mnt/home/"$USER_NAME"/yay-bin/
output 15 #installed yay
#--------------------------------16--------------------------------#
arch-chroot /mnt passwd $USER_NAME << EOD
$USER_PASSWORD
$USER_PASSWORD
EOD

output 16 #set "$USER_NAME" password
#--------------------------------17--------------------------------#
arch-chroot /mnt pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
arch-chroot /mnt pacman-key --lsign-key 3056513887B78AEB
arch-chroot /mnt pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
echo "[chaotic-aur]" >> /mnt/etc/pacman.conf
echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /mnt/etc/pacman.conf

output 17 #added chaotic repository
#--------------------------------18--------------------------------#
arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

output 18 #set timezone to "$TIMEZONE"
#--------------------------------19--------------------------------#
arch-chroot /mnt hwclock --systohc

output 19 #set time using bios clock
#--------------------------------20--------------------------------#
sed -i "s/^#\($LOCALE.*\)/\1/g" /mnt/etc/locale.gen
echo "LANG=$LOCALE" > /mnt/etc/locale.conf
arch-chroot /mnt locale-gen

output 20 #generated "$LOCALE" locale
#--------------------------------21--------------------------------#
touch /mnt/etc/vconsole.conf
echo "KEYMAP=$KEYMAP" > /mnt/etc/vconsole.conf
cat >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf << EOF
Section "InputClass"
    Identifier 		"system-keyboard"
    MatchIsKeyboard	"on"
    Option		"XkbLayout" "$KEYMAP"
EndSection
EOF
arch-chroot /mnt localectl set-x11-keymap "$KEYMAP"

output 21 #set installation keymap to "$KEYMAP"
#--------------------------------22--------------------------------#
#mkinitcpio find "keyboard" and replace with "keyboard encrypt"
sed -i 's/(base.*/(base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck)/g' /mnt/etc/mkinitcpio.conf
#generate initcpio
arch-chroot /mnt mkinitcpio -P

output 22 #created initcpio
#--------------------------------23--------------------------------#
echo "[multilib]" >> /mnt/etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> /mnt/etc/pacman.conf

output 23 #enabled multilib mirrors
#--------------------------------24--------------------------------#
arch-chroot /mnt wget "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" -O /etc/hosts
sed -i "17s/.*/127.0.1.1 $HOSTNAME/" /mnt/etc/hosts
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
echo "$HOSTNAME" > /mnt/etc/hostname

output 24 #setup networking
#--------------------------------25--------------------------------#
arch-chroot /mnt xbindkeys --defaults > /mnt/home/$USER_NAME/.xbindkeysrc

output 25 #setup xbinkeys
#--------------------------------26--------------------------------#
arch-chroot /mnt mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat > /mnt/etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER_NAME --noclear %I 38400 linux
EOF
arch-chroot /mnt systemctl enable getty@tty1.service

output 26 #enabled autologin
#--------------------------------27--------------------------------#
if [[ $UEFI -gt 0 ]]
then
	#install and setup grub2 for uefi
	arch-chroot /mnt pacman -Sy chaotic-aur/grub-improved-luks2-git --noconfirm
	arch-chroot /mnt mkdir /boot/EFI
	arch-chroot /mnt mount "$DRIVE"1 /boot/EFI
	sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT="slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 pti=on randomize_kstack_offset=on vsyscall=none debugfs=off oops=panic module.sig_enforce=1 lockdown=confidentiality quiet loglevel=0"' /mnt/etc/default/grub
	uuid="$(blkid "$DRIVE"2 -o value | head -n 1)"
	sed -i "s|GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$uuid:cryptroot root=/dev/mapper/cryptroot\"|" /mnt/etc/default/grub
	echo "GRUB_ENABLE_CRYPTODISK=y" >> /mnt/etc/default/grub
	arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub_uefi --removable
	arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
else
	#install and setup grub2 for mbr/bios
	arch-chroot /mnt pacman -Sy core/grub --noconfirm
	sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT="slab_nomerge init_on_alloc=1 init_on_free=1 pti=on randomize_kstack_offset=on vsyscall=none debugfs=off oops=panic lockdown=confidentiality quiet loglevel=0"' /mnt/etc/default/grub
	uuid="$(blkid "$DRIVE"2 -o value | head -n 1)"
	sed -i "s|GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$uuid:cryptroot root=/dev/mapper/cryptroot\"|" /mnt/etc/default/grub
	echo "GRUB_ENABLE_CRYPTODISK=y" >> /mnt/etc/default/grub
	arch-chroot /mnt grub-install --target=i386-pc "$DRIVE"
	arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
fi

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

output 27 #configured grub
#--------------------------------28--------------------------------#
rm /mnt/home/$USER_NAME/.bash_profile
cp files/bash_profile /mnt/home/$USER_NAME/.bash_profile

output 28 #setup bash_profile
#--------------------------------29--------------------------------#
cp files/xinitrc /mnt/home/$USER_NAME/.xinitrc

output 29 #setup xinitrc
#--------------------------------30--------------------------------#
mkdir -p /mnt/home/$USER_NAME/.config/bspwm/
cp files/bspwmrc /mnt/home/$USER_NAME/.config/bspwm/bspwmrc

output 30 #setup bspwmrc
#--------------------------------31--------------------------------#
mkdir -p /mnt/home/$USER_NAME/Pictures
cp files/bg.png /mnt/home/$USER_NAME/.bg.png

output 31 #setup background
#--------------------------------32--------------------------------#
cp files/xprofile /mnt/home/$USER_NAME/.xprofile
echo "feh --bg-fill /home/$USER_NAME/.bg.png" >> /mnt/home/$USER_NAME/.xprofile

output 32 #setup xprofile
#--------------------------------33--------------------------------#
#setup tint2
mkdir -p /mnt/home/$USER_NAME/.config/tint2
cp files/tint2rc /mnt/home/$USER_NAME/.config/tint2/tint2rc

#setup sxhkd
mkdir -p /mnt/home/$USER_NAME/.config/sxhkd
cp files/sxhkdrc /mnt/home/$USER_NAME/.config/sxhkd/sxhkdrc

output 33 #setup tint2rc & sxhkdrc

#--------------------------------34--------------------------------#
cp files/Xdefaults /mnt/home/$USER_NAME/.Xdefaults

output 34 #setup xterm

#--------------------------------35--------------------------------#
mkdir -p /mnt/home/$USER_NAME/.config/jgmenu
cp files/jgmenu/* /mnt/home/$USER_NAME/.config/jgmenu/

output 35 #setup jgmenu
#--------------------------------36--------------------------------#
mkdir -p /mnt/home/$USER_NAME/.config/gsimplecal/
cp files/gsimplecal_config /mnt/home/$USER_NAME/.config/gsimplecal/config

output 36 #fixed gsimplecal
#--------------------------------37--------------------------------#
cp -r files/themes/ArchLabs-Dark/ /mnt/usr/share/themes
cp -r files/icons/ArchLabs-Dark/ /mnt/usr/share/icons
mkdir -p "/mnt/home/$USER_NAME/.config/xfce4/xfce-perchannel-xml/"
cp files/xsettings.xml /mnt/home/$USER_NAME/.config/xfce4/xfce-perchannel-xml/xsettings.xml
#gtk-3.0
mkdir -p "/mnt/home/$USER_NAME/.config/gtk-3.0/"
cp files/gtk3_settings.ini /mnt/home/$USER_NAME/.config/gtk-3.0/settings.ini

echo "dconf load / < /home/$USER_NAME/.config/dconf/restore" > /mnt/home/"$USER_NAME"/finish_install.sh
echo "yay -Sy mercury-browser-bin lynis-git chkrootkit --noconfirm" >> /mnt/home/"$USER_NAME"/finish_install.sh
echo "yes y | yay -Scc" >> /mnt/home/"$USER_NAME"/finish_install.sh
echo "mv /home/"$USER_NAME"/finish_install.sh /tmp" >> /mnt/home/"$USER_NAME"/finish_install.sh
chmod +x /mnt/home/"$USER_NAME"/finish_install.sh
arch-chroot /mnt locale-gen
mkdir -p /mnt/home/"$USER_NAME"/.config/dconf
cp files/dconf_user /mnt/home/"$USER_NAME"/.config/dconf/restore 

output 37 #setup themes
#--------------------------------38--------------------------------#
arch-chroot /mnt chown -R $USER_NAME home/$USER_NAME/

output 38 #fixed some permissions
#--------------------------------39--------------------------------#
printf "install uvcvideo /bin/false" >> /mnt/etc/modprobe.d/webcam_block.conf
printf "install snd_hda_intel /bin/false" >> /mnt/etc/modprobe.d/microphone_block.conf
chmod 600 /mnt/etc/modprobe.d/*.conf

output 39 #blocked webcam and microphone modules
#--------------------------------40--------------------------------#
mkdir -p /mnt/etc/sysctl.d/
cp files/security.conf /mnt/etc/sysctl.d/security.conf

output 40 #added kernel parameters
#--------------------------------41--------------------------------#
touch /mnt/etc/machine-id
arch-chroot /mnt chown "$USER_NAME" /etc/machine-id
chmod 664 /mnt/etc/machine-id
echo "dbus-uuidgen > /etc/machine-id" >> /mnt/home/"$USER_NAME"/.bashrc
echo "alias ls='ls -la --color=auto'" >> /mnt/home/"$USER_NAME"/.bashrc
echo "alias passgen='openssl rand -base64 48'" >> /mnt/home/"$USER_NAME"/.bashrc
echo "set number" >> /mnt/home/"$USER_NAME"/.vimrc

output 41 #changed configs
#--------------------------------42--------------------------------#
arch-chroot /mnt yay -Sy macchanger cmus libreoffice qdirstat noto-fonts noto-fonts-extra noto-fonts-cjk ttf-liberation --noconfirm
output 42 #installed extra packages
#--------------------------------43--------------------------------#
#cat >> /mnt/etc/systemd/system/macspoof@.service << EOF
#[Unit]
#Description=macchanger on %I
#Wants=network-pre.target
#Before=network-pre.target
#BindsTo=sys-subsystem-net-devices-%i.device
#After=sys-subsystem-net-devices-%i.device
#
#[Service]
#ExecStart=/usr/bin/macchanger -r %I
#Type=oneshot
#
#[Install]
#WantedBy=multi-user.target
#EOF
#arch-chroot /mnt systemctl enable macspoof@"$INTERFACE".service
#
#output 43 #setup macchanger
#--------------------------------44--------------------------------#
umount "$DRIVE"1
umount "$DRIVE"2
umount /mnt
output 44 #unmounted partitions
###--------------------------------------------------------------###
output 45 #DONE! thanks for using this script
printf "\n once rebooted run './finish_install.sh' in your home directory"
exit
