#!/bin/sh
#media_production_packages
mp(){
#From Official Repo
sudo pacman -Sy --noconfirm blender shotcut kdenlive openshot pitivi avidemux-qt avidemux-cli flowblade ardour audacity lmms jackminimix python-jack-client hydrogen mixxx carla qtractor zynaddsubfx yoshimi gimp inkscape handbrake handbrake-cli darktable rawtherapee krita digikam hugin shotwell
#From AUR Repo
yay -Sy cinelerra  olive rawstudio  
}
