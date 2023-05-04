#!/bin/sh
# == MY ARCH SETUP INSTALLER == #
#part1
printf '\033c'
echo "Welcome to Normi-OS installer script"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
lsblk
echo "Enter the drive: "
read drive
cfdisk $drive
echo "Enter the linux partition: "
read partition
mkfs.ext4 $partition
read -p "Did you also create efi partition? [y/n]" answer
if [[ $answer = y ]] ; then
  echo "Enter EFI partition: "
  read efipartition
  mkfs.vfat -F 32 $efipartition
fi
mount $partition /mnt
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit

#part2
printf '\033c'
pacman -S --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P
passwd
pacman --noconfirm -S grub efibootmgr os-prober

printf " Select one of the method to install bootloader: \n For gpt+efi Type: ge \n For mbr(dos)+legacy Type: ml\n For mbr(dos)+efi+legacy Type: mepl" 
  read bl
  case $bl in
  	ge)	     
	echo "Enter EFI partition: "
	read efipartition
	mkdir /boot/efi
	mount $efipartition /boot/efi
	grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
	sed -i 's/quiet/pci=noaer/g' /etc/default/grub
	sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
	grub-mkconfig -o /boot/grub/grub.cfg	
	;;
	ml)
	echo "Enter the drive: "
	read drive
	grub-install --target=i386-pc --debug --boot-directory=/boot $drive
	sed -i 's/quiet/pci=noaer/g' /etc/default/grub
	sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
	grub-mkconfig -o /boot/grub/grub.cfg
	;;
	mepl)
	echo "Enter EFI partition: "
	read efipartition
	mkdir /boot/efi
	mount $efipartition /boot/efi
	grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB_MBR
	sed -i 's/quiet/pci=noaer/g' /etc/default/grub
	grub-mkconfig -o /boot/grub/grub.cfg
	echo "Enter the drive: "
	read drive
	grub-install --target=i386-pc --debug --boot-directory=/boot $drive
	grub-mkconfig -o /boot/grub/grub.cfg
	;;
  esac


pacman -Sy --noconfirm xorg bluez bluez-utils networkmanager \
		       mpv firefox libreoffice-still vlc chromium alacritty \
                       noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono ttf-joypixels ttf-font-awesome \
                       adobe-source-code-pro-fonts adobe-source-sans-pro-fonts adobe-source-serif-pro-fonts \
                       ttf-jetbrains-mono-nerd ttf-liberation \
                       git cups 

printf "Select a Desktop Environment: \n For xfce4 Type: xfce \n For KDE-Plasma Type: kde\n For Gnome Type: gnome\n" 
  read de
  case $de in
  	xfce)	     
	pacman -Sy --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
	systemctl enable lightdm
	;;
	kde)
	pacman -Sy --noconfirm sddm plasma plasma-meta
	systemctl enable sddm 
	;;
	gnome)
	pacman -Sy --noconfirm gdm gnome gnome gnome-extra
	systemctl start gdm
	;;
  esac

systemctl enable NetworkManager.service
systemctl enable bluetooth
systemctl enable cups
rm /bin/sh
ln -s dash /bin/sh
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "Enter Username: "
read username
useradd -m -G wheel -s /bin/zsh $username
passwd $username
echo "Pre-Installation Finish Reboot now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username
exit

#part3
printf '\033c'
cd $HOME

#dotfiles
git clone https://github.com/iamvk1437k/dotfiles ~/.local/src/dotfiles
rm -vrf ~/.config ; cp -vrf ~/.local/src/dotfiles/.config/ ~/
sudo cp -vrf ~/.local/src/dotfiles/etc/X11/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/20-intel.conf
sudo cp -vrf ~/.local/src/dotfiles/etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
sudo cp -vrf ~/.local/src/dotfiles/etc/pacman.conf /etc/pacman.conf
sudo mkdir -pv /etc/NetworkManager/conf.d/
sudo cp -vrf ~/.local/src/dotfiles/etc/NetworkManager/conf.d/any-user.conf /etc/NetworkManager/conf.d/any-user.conf 
rm -rf ~/.local/src/dotfiles 

#Install aur-helper
cd
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -sfri 
rm -vrf ~/yay-bin

yay -Sy telegram-desktop-bin xdman lexend-fonts-git dracula-icons-git dracula-cursors-git dracula-gtk-theme dracula-alacritty-git  

###Some Install###
#install bat
bat_ver=$(curl -s "https://api.github.com/repos/tshakalekholoane/bat/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
cd /usr/local/bin ; sudo curl -Lo bat "https://github.com/tshakalekholoane/bat/releases/download/${bat_ver}/bat" ; sudo chmod +x bat ; sudo ./bat threshold 60 ; sudo ./bat persist 60


# Configure Hardware acceleration on video encoding and decoding. 
printf "Select a GPU To Configure Hardware acceleration :- \n Fot intel Only. Type: intel \n Fot AMD Only. Type: amd\n For AMD+Nvidia Type: amd+nv \n For INTEL+Nvidia Type: intel+nv" 
  read gpu
  case $gpu in
  intel)
  #INTEL
  sudo pacman -Sy  --noconfirm xf86-video-intel vulkan-intel libva-intel-driver libva-vdpau-driver  libvdpau-va-gl intel-gpu-tools libva-utils intel-media-driver
  echo "export LIBVA_DRIVER_NAME=iHD" >> ~/.zprofile
  echo "export VDPAU_DRIVER=va_gl"  >> ~/.zprofile
  ;;
  amd)
  #AMD
  sudo pacman -Sy --noconfirm libva-mesa-driver mesa-vdpau xf86-video-amdgpu
  echo "export LIBVA_DRIVER_NAME=radeonsi" >> ~/.zprofile
  ;;
  amd+nv)
  #AMD
  sudo pacman -Sy --noconfirm libva-mesa-driver mesa-vdpau xf86-video-amdgpu
  echo "export LIBVA_DRIVER_NAME=radeonsi" >> ~/.zprofile
  #Nvidia
  sudo pacman -Sy --noconfirm libva-mesa-driver mesa-vdpau xf86-video-nouveau
  echo "export LIBVA_DRIVER_NAME=nouveau" >> ~/.zprofile
  echo "export VDPAU_DRIVER=nouveau" >> ~/.zprofile
  ;;
  intel+nv)
  #INTEL
  sudo pacman -Sy  --noconfirm xf86-video-intel vulkan-intel libva-intel-driver libva-vdpau-driver  libvdpau-va-gl intel-gpu-tools libva-utils intel-media-driver
  echo "export LIBVA_DRIVER_NAME=iHD" >> ~/.zprofile
  echo "export VDPAU_DRIVER=va_gl" >> ~/.zprofile

  #Nvidia
  sudo pacman -Sy --noconfirm libva-mesa-driver mesa-vdpau xf86-video-nouveau
  echo "export LIBVA_DRIVER_NAME=nouveau" >> ~/.zprofile
  echo "export VDPAU_DRIVER=nouveau"  >> ~/.zprofile
  ;;
esac

printf " Select a profile do you want to install:\n   For 'Normi profile' -> Type: normi\n   For 'Gaming Profile' -> Type: g\n   For 'Pentensting Profile' -> Type: pt\n   For 'Media Protection Profile' -> mp"
read pr
case $pr in
	normi)
	install_gpu_drivers
	;;	
	g)
	install_gpu_drivers
	install_wine_deps
	install_steam_and_lutris
	;;
	pt)
	install_gpu_drivers
	#Installing BlackARch Repo
	sudo sh -c "$(curl -fsSL https://blackarch.org/strap.sh)" 
	;;
	mp)
	install_gpu_drivers
	m_p	
	;;
esac


install_gpu_drivers(){
case $gpu in
  intel)
  #INTEL
  echo "Installing intelGPU Drivers for gaming ..."
        sudo pacman -S --needed lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
  ;;
  amd)
  #AMD
  echo "Installing AMDgpu Drivers gaming ..."
        sudo pacman -S --needed lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader 
  ;;
  amd+nv)
  #AMD
  echo "Installing AMDgpu Drivers gaming ..."
        sudo pacman -S --needed lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
  #Nvidia
  echo "Installing nvidia Drivers for gaming, if not installed already..."
        sudo pacman -S --needed nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader 
  ;;
  intel+nv)
  #INTEL
  echo "Installing intelGPU Drivers for gaming ..."
        sudo pacman -S --needed lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader 
  #Nvidia
  echo "Installing nvidia Drivers for gaming, if not installed already..."
        sudo pacman -S --needed nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader 
  ;;
esac

}

#Installing 'Wine' Dependencies
install_wine_deps(){
        echo "Checking  and Installing latest Updates..."
        sudo pacman -Syu --noconfirm
        echo "Installing Wine Dependencies..."
        sudo pacman -S --needed --noconfirm  wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls \
                mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error \
                lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo \
                sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama \
                ncurses lib32-ncurses ocl-icd lib32-ocl-icd libxslt lib32-libxslt libva lib32-libva gtk3 \
                lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader
}

install_steam_and_lutris(){
        echo "Installing Steam and lutris"
        sudo pacman -S --noconfirm  steam lutris
}

m_p(){
#From Official Repo
sudo pacman -Sy --noconfirm blender shotcut kdenlive openshot pitivi avidemux-qt avidemux-cli flowblade ardour audacity lmms jackminimix python-jack-client hydrogen mixxx carla qtractor zynaddsubfx yoshimi gimp inkscape handbrake handbrake-cli darktable rawtherapee krita digikam hugin shotwell
#From AUR Repo
yay -Sy cinelerra  olive rawstudio  
}

###Default dracula theming ###

sudo pacman -Sy --noconfirm  aria2 git curl unzip

#gtk theme 'dracula'
cd /usr/share/themes ; pwd ; sudo aria2c https://github.com/dracula/gtk/releases/download/v3.0/Dracula.tar.xz ; sudo tar -xvf Dracula.tar.xz ; sudo rm -v *.tar.xz ; cd

#icons 'dracula-icons'  and cursor theme 'dracula-cursors'
cd /usr/share/icons ; pwd ; sudo aria2c https://github.com/dracula/gtk/releases/download/v3.0/Dracula-cursors.tar.xz ; sudo git clone https://github.com/m4thewz/dracula-icons ; sudo rm -vrf dracula-icons/.git ; sudo rm -v dracula-icons/Preview.png ; sudo tar -vxf Dracula-cursors.tar.xz ; sudo rm -v *.tar.xz ; cd
sudo gtk-update-icon-cache /usr/share/icons/dracula-icons/


#wallpaper
sudo mkdir /usr/share/backgrounds  ; cd /usr/share/backgrounds ; sudo aria2c https://raw.githubusercontent.com/dracula/wallpaper/master/first-collection/arch.png ; cd

exit
