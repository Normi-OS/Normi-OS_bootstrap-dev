
install_gpu_drivers(){
case $1 in
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
install_gpu_drivers $gpu
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

install_wine_deps
install_steam_and_lutris(){
        echo "Installing Steam and lutris"
        sudo pacman -S --noconfirm  steam lutris
}
install_steam_and_lutris

