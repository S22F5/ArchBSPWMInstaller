# Install Drive (!!!will be wiped!!!)
DRIVE='/dev/sdX'
#
# Hostname
HOSTNAME='hostname'
#
# Root User Password.
ROOT_PASSWORD='root'
#
# Main User
USER_NAME='user'
#
# Main User Password
USER_PASSWORD='pass'
#
# Keymap
KEYMAP='en'
#
# Mirror Country
MIRROR_COUNTRY='Canada'
#
# Timezone in "Zone/City" Format
TIMEZONE='America/Los Angeles'
#
# Locale
LOCALE='en_US.UTF-8'


#---------------------------------------------------------------------------#
echo "  __.__                                       "
echo "  | * |                                   ___ "
echo " _|___|_                                 _|_|_"
echo " (*~ ~*)ArchBSPWMInstaller by s22f5 v2.29(*~*)"
echo "  Made for: | Intel CPU | AMD GPU | SDD Drive "
echo "  Will Install my Personal BSPWM/Tint2 System "
sleep 3
#---------------------------------------------------------------------------#
outmsg=(
"[1] Checking Connection"
"[1-o] Found working network"
"[2] Set Keymap"
"[3] Set NTP-time"
"[4] Cleared SDD Memory Cells"
"[5] Nulled Disk"
"[6] Created EFI partition"
"[7] Created SWAP partition"
"[8] Created ROOT partition"
"[9] Formated partitions"
"[10] Mounted and Swaped partitions"
"[11] Got Fasted Mirrors"
"[12] Installed Essential Packages"
"[13] Created fstab"
"[14] Setup System in Chroot"
)

echo ${outmsg[0]}
sleep 4
exit






#Start Install                                                              #
#1--------------------------------------------------------------------------#
#check connection
clear
echo "[1] Checking Connection"
ping 8.8.8.8 -c 1 >/dev/null 2>&1
if [ $? != "0" ]
then
    clear
    echo "!Network Error!"
    echo "Fix your Connection"
    exit
fi
#
clear
echo "[1] Checking Connection"
echo "[1o] Found working Connection"
#2--------------------------------------------------------------------------#
#set live-usb
loadkeys $KEYMAP
#
clear
echo "[1] Checking Connection"
echo "[1o] Found working Connection"
echo "[2] Set Keymap"
#3--------------------------------------------------------------------------#
#set time to ntp
timedatectl set-ntp true
#
clear
echo "[1] Checking Connection"
echo "[1-o] Found working network"
echo "[2] Set Keymap"
echo "[3] Set NTP-time"
#4--------------------------------------------------------------------------#
#clear ssd memory cell
hdparm --user-master u --security-set-pass pass "$DRIVE"
hdparm --user-master u --security-erase pass "$DRIVE"
hdparm -I "$DRIVE"
#
clear
echo "[1] Checking Connection"
echo "[1-o] Found working network"
echo "[2] Set Keymap"
echo "[3] Set NTP-time"
echo "[4] Cleared SDD Memory Cells"
#5--------------------------------------------------------------------------#
#erase disk
dd if=/dev/zero of="$DRIVE" bs=100M count=10 status=progress
#
clear
echo "[1] Checking Connection"
echo "[1-o] Found working network"
echo "[2] Set Keymap"
echo "[3] Set NTP-time"
echo "[4] Cleared SDD Memory Cells"
echo "[5] Nulled Disk"
#6--------------------------------------------------------------------------#
#create EFI partition
parted "$DRIVE" --script mklabel gpt
parted "$DRIVE" --script mkpart ESP fat32 1MiB 512MiB
parted "$DRIVE" --script set 1 boot on
parted "$DRIVE" --script name 1 efi
#
clear
echo "[1] Checking Connection"
echo "[1-o] Found working network"
echo "[2] Set Keymap"
echo "[3] Set NTP-time"
echo "[4] Cleared SDD Memory Cells"
echo "[5] Nulled Disk"
echo "[6] Created EFI partition"
#7--------------------------------------------------------------------------#
#create swap partition
parted "$DRIVE" --script mkpart linux-swap 512MiB 2598MiB
parted "$DRIVE" --script name 2 swap
#
clear
echo "[1] Checking Connection"
echo "[1-o] Found working network"
echo "[2] Set Keymap"
echo "[3] Set NTP-time"
echo "[4] Cleared SDD Memory Cells"
echo "[5] Nulled Disk"
echo "[6] Created EFI partition"
echo "[7] Created SWAP partition"
#8--------------------------------------------------------------------------#
#create root partition
parted "$DRIVE" --script mkpart primary 2598MiB 100%
parted "$DRIVE" --script name 3 root
#
clear
echo "[1] Checking Connection"
echo "[1-o] Found working network"
echo "[2] Set Keymap"
echo "[3] Set NTP-time"
echo "[4] Cleared SDD Memory Cells"
echo "[5] Nulled Disk"
echo "[6] Created EFI partition"
echo "[7] Created SWAP partition"
echo "[8] Created ROOT partition"
#9--------------------------------------------------------------------------#
#format root partition
mkfs.ext4 "$DRIVE"3
#format swap partition
mkswap "$DRIVE"2
#format EFI partition
mkfs.fat -F 32 "$DRIVE"1
#
clear
echo "[1] Checking Connection"
echo "[1-o] Found working network"
echo "[2] Set Keymap"
echo "[3] Set NTP-time"
echo "[4] Cleared SDD Memory Cells"
echo "[5] Nulled Disk"
echo "[6] Created EFI partition"
echo "[7] Created SWAP partition"
echo "[8] Created ROOT partition"
echo "[9] Formated partitions"
#10-------------------------------------------------------------------------#
#mount root partition
mount "$DRIVE"3 /mnt
#swapon swap partition
swapon "$DRIVE"2
#
clear
echo "[1] Checking Connection"
echo "[1-o] Found working network"
echo "[2] Set Keymap"
echo "[3] Set NTP-time"
echo "[4] Cleared SDD Memory Cells"
echo "[5] Nulled Disk"
echo "[6] Created EFI partition"
echo "[7] Created SWAP partition"
echo "[8] Created ROOT partition"
echo "[9] Formated partitions"
echo "[10] Mounted and Swaped partitions"
#11-------------------------------------------------------------------------#
#get fastest mirrorlist
reflector --country $MIRROR_COUNTRY -l 10 --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
#
clear
echo "[1] Checking Connection"
echo "[1-o] Found working network"
echo "[2] Set Keymap"
echo "[3] Set NTP-time"
echo "[4] Cleared SDD Memory Cells"
echo "[5] Nulled Disk"
echo "[6] Created EFI partition"
echo "[7] Created SWAP partition"
echo "[8] Created ROOT partition"
echo "[9] Formated partitions"
echo "[10] Mounted and Swaped partitions"
echo "[11] Got Fasted Mirrors"
#12-------------------------------------------------------------------------#
#install essential packages
pacstrap /mnt base linux linux-firmware grub iwd efibootmgr mesa xf86-video-amdgpu vulkan-radeon xf86-video-ati xf86-video-amdgpu vim xorg-server xorg-xinit xterm feh libva-mesa-driver xorg tint2 jgmenu pavucontrol qt5-base xfce4-settings alsa pulseaudio ntfs-3g exfat-utils dhcpcd nano mousepad git zip unzip compton gvfs gvfs-mtp thunar sudo bspwm sxhkd vlc alsa-firmware alsa-lib alsa-plugins ffmpeg gst-libav gst-plugins-base gst-plugins-good gstreamer qt6-base libmad libmatroska pamixer pulseaudio-alsa xdg-user-dirs arandr dunst exo gnome-keyring gsimplecal network-manager-applet volumeicon wmctrl man-pages man-db p7zip terminus-font xorg-xset xorg-xsetroot dmenu rxvt-unicode trayer git alacritty htop base-devel xbindkeys playerctl adapta-gtk-theme arc-solid-gtk-theme htop firefox rofi wget
#
clear
echo "[1] Checking Connection"
echo "[1-o] Found working network"
echo "[2] Set Keymap"
echo "[3] Set NTP-time"
echo "[4] Cleared SDD Memory Cells"
echo "[5] Nulled Disk"
echo "[6] Created EFI partition"
echo "[7] Created SWAP partition"
echo "[8] Created ROOT partition"
echo "[9] Formated partitions"
echo "[10] Mounted and Swaped partitions"
echo "[11] Got Fasted Mirrors"
echo "[12] Installed Essential Packages"
#13--------------------------------------------------------------------------#
#setup fstab
genfstab -U /mnt >> /mnt/etc/fstab
#
clear
echo "[1] Checking Connection"
echo "[1-o] Found working network"
echo "[2] Set Keymap"
echo "[3] Set NTP-time"
echo "[4] Cleared SDD Memory Cells"
echo "[5] Nulled Disk"
echo "[6] Created EFI partition"
echo "[7] Created SWAP partition"
echo "[8] Created ROOT partition"
echo "[9] Formated partitions"
echo "[10] Mounted and Swaped partitions"
echo "[11] Got Fasted Mirrors"
echo "[12] Installed Essential Packages"
echo "[13] Created fstab"
#14--------------------------------------------------------------------------#
#setting up system
#----------------------------------------------------------------------------#
#set root password
arch-chroot /mnt passwd << EOD
$ROOT_PASSWORD
$ROOT_PASSWORD
EOD
#add main user
arch-chroot /mnt useradd -m -G users,video,log,rfkill,wheel,tty -s /bin/bash $USER_NAME
#set main user password
arch-chroot /mnt passwd $USER_NAME << EOD
$USER_PASSWORD
$USER_PASSWORD
EOD
#setting timezone
arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
#setting time to bios hwclock
arch-chroot /mnt hwclock --systohc
#replace locale.gen
sed -i "s/^#\($LOCALE.*\)/\1/g" /mnt/etc/locale.gen
#create and edit locale
echo "$LOCALE" > /mnt/etc/locale.conf
#set permanent keymap
touch /mnt/etc/vconsole.conf
echo "KEYMAP=$KEYMAP" > /mnt/etc/vconsole.conf
#generate locale
arch-chroot /mnt locale-gen
#create initcpio
arch-chroot /mnt mkinitcpio -P
#Enable mutlilib mirror
echo "[multilib]" >> /mnt/etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> /mnt/etc/pacman.conf
#create and edit hosts file
cat > /mnt/etc/hosts << EOF
127.0.0.1	localhost
::1		localhost
127.0.1.1	$HOSTNAME
EOF
#enable network services
arch-chroot /mnt systemctl enable iwd
arch-chroot /mnt systemctl enable dhcpcd
arch-chroot /mnt systemctl enable systemd-networkd
#install yay
arch-chroot /mnt git clone https://aur.archlinux.org/yay-bin.git /tmp/1 && cp -arf /tmp/1/. . && makepkg -si --noconfirm
#setup xbinkeys
xbindkeys --defaults > /home/$USER_NAME/.xbindkeysrc
#add wheel group to sudoers
sed -i "s/# \(%wheel ALL=(ALL) ALL\)/\1/g" /mnt/etc/sudoers
#set system hostname
touch /mnt/etc/hostname
echo "$HOSTNAME" > /mnt/etc/hostname
# create home directory structures
arch-chroot /mnt xdg-user-dirs-update
#enable autologin 
arch-chroot /mnt mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat > /mnt/etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER_NAME --noclear %I 38400 linux
EOF
arch-chroot /mnt systemctl enable getty@tty1.service
#install and setup grub2
arch-chroot /mnt mkdir /boot/EFI
arch-chroot /mnt mount "$DRIVE"1 /boot/EFI
arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
#
clear
echo "[1] Checking Connection"
echo "[1-o] Found working network"
echo "[2] Set Keymap"
echo "[3] Set NTP-time"
echo "[4] Cleared SDD Memory Cells"
echo "[5] Nulled Disk"
echo "[6] Created EFI partition"
echo "[7] Created SWAP partition"
echo "[8] Created ROOT partition"
echo "[9] Formated partitions"
echo "[10] Mounted and Swaped partitions"
echo "[11] Got Fasted Mirrors"
echo "[12] Installed Essential Packages"
echo "[13] Created fstab"
echo "[14] Setup System in Chroot"
sleep 1
#----------------------------------------------------------------------------#
#copy configs
rm /mnt/home/$USER_NAME/.bash_profile
cat >> "/mnt/home/$USER_NAME/.bash_profile" <<\EOF
#add  ~/.local/bin to PATH
echo $PATH | grep -q "$HOME/.local/bin:" || export PATH="$HOME/.local/bin:$PATH"

#automatically run startx when logging in on tty1
[ -z "$DISPLAY" ] && [ $XDG_VTNR -eq 1 ] && startx
EOF
#setup startx
cat >> "/mnt/home/$USER_NAME/.xinitrc" <<\EOF
#!/bin/sh

#this file is run when calling startx

#default arch init scripts
if [ -d /etc/X11/xinit/xinitrc.d ]; then
	for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
		[ -x "$f"] && . "$f"
	done
fi

#user init scripts and settings
[ -r /etc/X11/xinit/.Xmodmap ] && xmodmap /etc/X11/xinit/.Xmodmap
[ -r ~/.Xmodmap ] && xmodmap ~/.Xmodmap
[ -r ~/.Xrecources ] && xrdb -merge ~/.Xresources
[ -r ~/.xprofile ] && . ~/.xprofile

pgrep -x sxhkd > /dev/null || sxhkd &
tint2 &
volumeicon &
#launch session, commands below this line will be ignored
exec bspwm
EOF
#setup bspwm config
mkdir -p /mnt/home/$USER_NAME/.config/bspwm/
cat >> /mnt/home/$USER_NAME/.config/bspwm/bspwmrc << EOF
#!/bin/sh

#set root pointer
xsetroot -cursor_name left_ptr

#set bsp configs
bspc monitor -d I II III IV V VI VII VIII IX X

bspc config window_gap 12
bspc config border_width 2

bspc config split_ratio 0.62
bspc config borderless_monocle true
bspc config gapless_monocle true

bspc config pointer_modifier mod1
bspc config pointer_action1 move
bspc config pointer_action2 resize_side
bspc config pointer_action3 resize_corner

EOF
#copy bg
mkdir -p /mnt/home/$USER_NAME/Pictures
cp bg.png /mnt/home/$USER_NAME/Pictures/
#.xprofile
cat >> /mnt/home/$USER_NAME/.xprofile <<\EOF
#!/bin/sh

#sourced by ~/.xinitrc

export XDG_CONFIG_HOME="$HOME/.config"
export PATH="$HOME/.local/bin:$PATH"


EOF
echo "feh --bg-fill /home/$USER_NAME/Pictures/bg.png" >> /mnt/home/$USER_NAME/.xprofile
#setup tint2rc
mkdir -p /mnt/home/$USER_NAME/.config/tint2
cat >> /mnt/home/$USER_NAME/.config/tint2/tint2rc <<\EOF
#-------------------------------------
# Gradients
#-------------------------------------
# Backgrounds
# Background 1: Active task
rounded = 0
border_width = 3
border_sides = T
background_color = #888888 0
border_color = #1793d1 100
background_color_hover = #888888 20
border_color_hover = #1793d1 100
background_color_pressed = #888888 20
border_color_pressed = #1793d1 100

# Background 2: Default task, Iconified task
rounded = 0
border_width = 0
border_sides = TBLR
background_color = #000000 0
border_color = #000000 0
background_color_hover = #888888 20
border_color_hover = #888888 20
background_color_pressed = #888888 20
border_color_pressed = #888888 20

# Background 3: Urgent task
rounded = 0
border_width = 3
border_sides = T
background_color = #888888 0
border_color = #e64141 100
background_color_hover = #888888 20
border_color_hover = #e64141 100
background_color_pressed = #888888 20
border_color_pressed = #e64141 100

# Background 4: Inactive desktop name, Inactive taskbar
rounded = 0
border_width = 0
border_sides = LR
background_color = #212121 90
border_color = #000000 0
background_color_hover = #888888 20
border_color_hover = #000000 0
background_color_pressed = #888888 20
border_color_pressed = #000000 0

# Background 5: Active desktop name, Active taskbar, Battery, Button, Clock, Launcher, Systray
rounded = 0
border_width = 0
border_sides = LR
background_color = #121212 90
border_color = #d8d8d8 0
background_color_hover = #d8d8d8 0
border_color_hover = #d8d8d8 0
background_color_pressed = #d8d8d8 0
border_color_pressed = #d8d8d8 0

# Background 6: Tooltip
rounded = 0
border_width = 0
border_sides = TBLR
background_color = #000000 100
border_color = #222222 90
background_color_hover = #2b303b 100
border_color_hover = #222222 90
background_color_pressed = #2b303b 100
border_color_pressed = #222222 90

#-------------------------------------
# Panel
panel_items = PLTSC
panel_size = 100% 24
panel_margin = 0 0
panel_padding = 0 0 0
panel_background_id = 0
wm_menu = 1
panel_dock = 0
panel_position = top center horizontal
panel_layer = bottom
panel_monitor = all
panel_shrink = 0
autohide = 0
autohide_show_timeout = 0.3
autohide_hide_timeout = 1.5
autohide_height = 6
strut_policy = follow_size
panel_window_name = tint2
disable_transparency = 0
mouse_effects = 1
font_shadow = 0
mouse_hover_icon_asb = 100 0 10
mouse_pressed_icon_asb = 100 0 0

#-------------------------------------
# Taskbar
taskbar_mode = multi_desktop
taskbar_hide_if_empty = 1
taskbar_padding = 0 0 0
taskbar_background_id = 4
taskbar_active_background_id = 5
taskbar_name = 1
taskbar_hide_inactive_tasks = 0
taskbar_hide_different_monitor = 1
taskbar_hide_different_desktop = 0
taskbar_always_show_all_desktop_tasks = 0
taskbar_name_padding = 4 4
taskbar_name_background_id = 0
taskbar_name_active_background_id = 0
taskbar_name_font = monospace 10
taskbar_name_font_color = #828282 100
taskbar_name_active_font_color = #a0a0bd 100
taskbar_distribute_size = 0
taskbar_sort_order = none
task_align = left

#-------------------------------------
# Task
task_text = 0
task_icon = 1
task_centered = 1
urgent_nb_of_blink = 20
task_maximum_size = 24 20
task_padding = 6 4 4
task_font = monospace 10
task_tooltip = 1
task_font_color = #828282 60
task_active_font_color = #828282 100
task_urgent_font_color = #ffffff 100
task_iconified_font_color = #d8d8d8 60
task_icon_asb = 80 0 0
task_active_icon_asb = 100 0 0
task_urgent_icon_asb = 100 0 0
task_iconified_icon_asb = 80 0 0
task_background_id = 2
task_active_background_id = 1
task_urgent_background_id = 3
task_iconified_background_id = 2
mouse_left = toggle_iconify
mouse_middle = close
mouse_right = none
mouse_scroll_up = toggle
mouse_scroll_down = iconify

#-------------------------------------
# System tray (notification area)
systray_padding = 8 2 4
systray_background_id = 5
systray_sort = right2left
systray_icon_size = 16
systray_icon_asb = 100 0 35
systray_monitor = 1
systray_name_filter =

#-------------------------------------
# Launcher
launcher_padding = 5 0 5
launcher_background_id = 5
launcher_icon_background_id = 0
launcher_icon_size = 16
launcher_icon_asb = 100 0 0
launcher_icon_theme = ArchLabs-Dark
launcher_icon_theme_override = 0
startup_notifications = 1
launcher_tooltip = 1
launcher_item_app = firefox
launcher_item_app = thunar
launcher_item_app = alacritty

#-------------------------------------
# Clock
time1_format = %H:%M
time2_format =
time1_font = sans 12
time1_timezone =
time2_font = sans 0
time2_timezone =
clock_font_color = #ffffff 100
clock_padding = 10 4
clock_background_id = 5
clock_tooltip =
clock_tooltip_timezone =
clock_lclick_command = gsimplecal
clock_rclick_command = alacritty -e htop
clock_mclick_command =
clock_uwheel_command =
clock_dwheel_command =

#-------------------------------------
# Button 1
button = new
button_icon = jgmenu
button_text =
button_lclick_command= jgmenu_run >/dev/null 2>&1 &
button_rclick_command= exo-open ~/.config/jgmenu/jgmenurc
button_mclick_command=
button_uwheel_command=
button_dwheel_command=
button_font_color = #000000 100
button_padding = 8 2
button_background_id = 5
button_centered = 1
button_max_icon_size = 22

#-------------------------------------
# Tooltip
tooltip_show_timeout = 0
tooltip_hide_timeout = 0
tooltip_padding = 10 6
tooltip_background_id = 6
tooltip_font_color = #d8d8d8 100
tooltip_font = sans 10
EOF

#setup sxhkd
mkdir -p /mnt/home/$USER_NAME/.config/sxhkd
cat >> /mnt/home/$USER_NAME/.config/sxhkd/sxhkdrc <<\EOF
super + shift + {Left,Down,Up,Right}
	dir={west,south,north,east}; \
	bspc node -s "$dir.local" --follow \
	    || bspc node -m "$dir" --follow



# web browser
super + w
    firefox

# terminal emulator
super + Return
    alacritty

# file manager
super + f
    thunar

# program launcher
super + @space
    rofi -show run

# program launcher
alt + F1
    rofi -show run

# make sxhkd reload its configuration files:
super + shift + r
    pkill -USR1 -x sxhkd

# close and kill
super + {_,shift + }q
    bspc node -{c,k}

# alternate between the tiled and monocle layout
super + shift + m
    bspc desktop -l next

# if the current node is automatic, send it to the last manual, otherwise pull the last leaf
super + y
    bspc query -N -n focused.automatic && bspc node -n last.!automatic || bspc node last.leaf -n focused

# swap the current node and the biggest node
super + g
    bspc node -s biggest

#
# state/flags
#

# set the window state
super + {t,shift + t,s,f}
    bspc node -t {tiled,pseudo_tiled,floating,fullscreen}

# set the node flags
super + ctrl + {x,y,z}
    bspc node -g {locked,sticky,private}

#
# focus/swap
#

# focus the node in the given direction
super + {_,shift + }{h,j,k,l}
    bspc node -{f,s} {west,south,north,east}

# focus the node for the given path jump
super + {p,b,comma,period}
    bspc node -f @{parent,brother,first,second}

# focus the next/previous node in the current desktop
super + {_,shift + }c
    bspc node -f {next,prev}.local

# focus the next/previous desktop in the current monitor
super + bracket{left,right}
    bspc desktop -f {prev,next}.local

# focus the last node/desktop
super + {grave,Tab,d
    bspc {node,desktop} -f last

# focus the older or newer node in the focus history
super + {o,i}
    bspc wm -h off; \
    bspc node {older,newer} -f; \
    bspc wm -h on

# focus or send to the given desktop
super + {_,shift + }{1-9,0}
    bspc {desktop -f,node -d} '^{1-9,10}'

#
# preselect
#

# preselect the direction
super + ctrl + {h,j,k,l}
    bspc node -p {west,south,north,east}

# preselect the ratio
super + ctrl + {1-9}
    bspc node -o 0.{1-9}

# cancel the preselection for the focused node
super + ctrl + space
    bspc node -p cancel

# cancel the preselection for the focused desktop
super + ctrl + shift + space
    bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel

#
# move/resize
#

# expand a window by moving one of its side outward
super + alt + {h,j,k,l}
    bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}

# contract a window by moving one of its side inward
super + alt + shift + {h,j,k,l}
    bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}

# move a floating window
super + {Left,Down,Up,Right}
    bspc node -v {-20 0,0 20,0 -20,20 0}

# volume control keys
XF86AudioMute
    pamixer -t
XF86AudioRaiseVolume
    pamixer -i 2
XF86AudioLowerVolume
    pamixer -d 2
XF86MonBrightnessUp
    xbacklight +10
XF86MonBrightnessDown
    xbacklight -10

# show desktop
super + d
	rofi -show window
	

EOF
echo "test"
sleep 3
#jgmenu
mkdir -p /mnt/home/$USER_NAME/.config/jgmenu

cat >> /mnt/home/$USER_NAME/.config/jgmenu/append.csv <<\EOF
^sep()
Exit,^checkout(exit),system-shutdown

exit,^tag(exit)
suspend,systemctl -i suspend,system-log-out
reboot,systemctl -i reboot,system-reboot
poweroff,systemctl -i poweroff,system-shutdown
EOF

cat >> /mnt/home/$USER_NAME/.config/jgmenu/prepend.csv <<\EOF
Firefox,firefox,firefox
File manager,thunar,system-file-manager
Terminal,xterm,utilities-terminal
^sep()
EOF

cat >> /mnt/home/$USER_NAME/.config/jgmenu/jgmenurc <<\EOF
# jgmenurc

stay_alive           = 1
#hide_on_startup     = 0
csv_cmd              = pmenu
tint2_look           = 1
at_pointer           = 0
terminal_exec        = xterm
terminal_args        = -e
#monitor             = 0

menu_margin_x        = 4
menu_margin_y        = 32
menu_width           = 200
menu_padding_top     = 10
menu_padding_right   = 2
menu_padding_bottom  = 5
menu_padding_left    = 2
menu_radius          = 0
menu_border          = 1
menu_halign          = left
menu_valign          = top

#sub_spacing         = 1
#sub_padding_top     = -1
#sub_padding_right   = -1
#sub_padding_bottom  = -1
#sub_padding_left    = -1
sub_hover_action     = 1

#item_margin_x       = 3
item_margin_y        = 5
item_height          = 30
item_padding_x       = 8
item_radius          = 0
item_border          = 0
#item_halign         = left

sep_height           = 5

font                 = monospace 12px
#font_fallback       = xtg
icon_size            = 24
#icon_text_spacing   = 10
#icon_theme          =
#icon_theme_fallback = xtg

#arrow_string        = ▸
#arrow_width         = 15

color_menu_bg        = #1C2023 100
color_menu_fg        = #A4A4A4 100
#color_menu_border   = #1C2023 8

color_norm_bg        = #1C2023 0
color_norm_fg        = #A4A4A4 100

color_sel_bg         = #8fa1b3 60
color_sel_fg         = #A4A4A4 100
#color_sel_border    = #1C2023 8

color_sep_fg         = #919BA0 40

#csv_name_format     = %n (%g)
EOF


#gsimplecal
mkdir -p /mnt/home/$USER_NAME/.config/gsimplecal/
cat >> /mnt/home/$USER_NAME/.config/gsimplecal/config << EOF
show_timezones = 1
show_week_numbers = 0
mark_today = 1
close_on_unfocus = 0
mainwindow_resizable = 1
mainwindow_sticky = 1
clock_label = Local
clock_tz= 
mainwindow_decorated = 0
mainwindow_keep_above = 1
mainwindow_skip_taskbar = 1
mainwindow_yoffset = 30
mainwindow_xoffset = 0
clock_format = %a %d %b %H:%M
EOF

#archlabs
cp -r themes/ArchLabs-Dark/ /mnt/usr/share/themes
cp -r icons/ArchLabs-Dark/ /mnt/usr/share/icons

mkdir -p "/mnt/home/$USER_NAME/.config/xfce4/xfce-perchannel-xml/"
cat >> "/mnt/home/$USER_NAME/.config/xfce4/xfce-perchannel-xml/xsettings.xml" <<\EOF
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="ArchLabs-Dark"/>
    <property name="IconThemeName" type="string" value="ArchLabs-Dark"/>
    <property name="DoubleClickTime" type="empty"/>
    <property name="DoubleClickDistance" type="empty"/>
    <property name="DndDragThreshold" type="empty"/>
    <property name="CursorBlink" type="empty"/>
    <property name="CursorBlinkTime" type="empty"/>
    <property name="SoundThemeName" type="empty"/>
    <property name="EnableEventSounds" type="empty"/>
    <property name="EnableInputFeedbackSounds" type="empty"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="empty"/>
    <property name="Antialias" type="empty"/>
    <property name="Hinting" type="empty"/>
    <property name="HintStyle" type="empty"/>
    <property name="RGBA" type="empty"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="CanChangeAccels" type="empty"/>
    <property name="ColorPalette" type="empty"/>
    <property name="FontName" type="empty"/>
    <property name="MonospaceFontName" type="empty"/>
    <property name="IconSizes" type="empty"/>
    <property name="KeyThemeName" type="empty"/>
    <property name="ToolbarStyle" type="empty"/>
    <property name="ToolbarIconSize" type="empty"/>
    <property name="MenuImages" type="empty"/>
    <property name="ButtonImages" type="empty"/>
    <property name="MenuBarAccel" type="empty"/>
    <property name="CursorThemeName" type="empty"/>
    <property name="CursorThemeSize" type="empty"/>
    <property name="DecorationLayout" type="empty"/>
    <property name="DialogsUseHeader" type="empty"/>
    <property name="TitlebarMiddleClick" type="empty"/>
  </property>
  <property name="Gdk" type="empty">
    <property name="WindowScalingFactor" type="empty"/>
  </property>
</channel>
EOF

#gtk-3.0
mkdir -p "/mnt/home/$USER_NAME/.config/gtk-3.0/"
cat >> "/mnt/home/$USER_NAME/.config/gtk-3.0/settings.ini" << EOF
[Settings]
gtk-theme-name=ArchLabs-Dark
gtk-icon-theme-name=ArchLabs-Dark
gtk-font-name=Monospace 11
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
EOF

#set xorg keymap
cat >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf << EOF
Section "InputClass"
    Identifier 		"system-keyboard"
    MatchIsKeyboard	"on"
    Option		"XkbLayout" "at"
EndSection
EOF

arch-chroot /mnt localectl set-x11-keymap "$KEYMAP"
#set owner
arch-chroot /mnt chown -R $USER_NAME home/$USER_NAME/
#unmount partitions
swapoff "$DRIVE"2
umount "$DRIVE"1
umount "$DRIVE"3
#
clear
echo "[1] Checking Connection"
echo "[1-o] Found working network"
echo "[2] Set Keymap"
echo "[3] Set NTP-time"
echo "[4] Cleared SDD Memory Cells"
echo "[5] Nulled Disk"
echo "[6] Created EFI partition"
echo "[7] Created SWAP partition"
echo "[8] Created ROOT partition"
echo "[9] Formated partitions"
echo "[10] Mounted and Swaped partitions"
echo "[11] Got Fasted Mirrors"
echo "[12] Installed Essential Packages"
echo "[13] Created fstab"
echo "[14] Setup System in Chroot"
echo "[15] Copied Config Files"
sleep 1
echo "[16] DONE thanks for using this scripty"
