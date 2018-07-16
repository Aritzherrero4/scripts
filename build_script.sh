#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Copyright (C) 2018 Aritz Herrero
# Based on Nathan Chancellor script
# Kernel compilation script for my setup

day=`date +"%d-%m-%Y"`
###############         
#  FUNCTIONS  #           
###############

function sign_kernel() {
cd
java -jar "zipsigner-2.1.jar" \
              "flash-AH.zip" \
              "flash-AH-$day.zip"
}

function zip_kernel() {
cd 
cd ${AK2}
zip -r9 flash-AH.zip * -x README.md flash-AH.zip
cd
mv ${AK2}/flash-AH.zip /home/aritzherrero4/
}

# Clean up
function clean_up() {
    # Clean AnyKernel2 folder if building a zip
        cd 
        cd "${AK2}" || die "AnyKernel2 source is missing!"
        git checkout  ${AK2_branch}
        git clean -fxd 
 

    # clean kernel
    cd 
    cd "${k}" || die "Kernel source is missing!"
    git checkout ${kernel_branch}
    git clean -fxd
       
}

function build_kernel() {
   cd 
   cd ${k}
   #make 2 compilations, for OOS and custom
   make O=out/oos ARCH=arm64 flash-oos_defconfig

   make -j$(nproc --all) O=out/oos \
                      ARCH=arm64 \
                      CC="${clang}/bin/clang" \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${gcc}/bin/aarch64-linux-gnu-"
 

   make O=out/custom ARCH=arm64 flash-custom_defconfig

   make -j$(nproc --all) O=out/custom \
                      ARCH=arm64 \
                      CC="${clang}/bin/clang" \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${gcc}/bin/aarch64-linux-gnu-"
 
}
function end_info() {
    echo "SCRIPT FINISHED!"

    END=$(date +"%s")
    DURATION=(${START} - ${END})

    echo "${RED}DURATION: ${DURATION}${RST}"
    echo
    echo "\a"
    exit
}

function move_img() {
kdir=/arch/arm64/boot/Image.gz-dtb
cd
cd ${AK2}
mkdir kernels
cd kernels
mkdir oos
mkdir custom
cd
mv ${k}/out/oos${kdir} ${AK2}/kernels/oos
mv ${k}/out/custom${kdir} ${AK2}/kernels/custom

}
################
#  VARIABLES   #
################

#AnyKernel2folder
AK2=/home/aritzherrero4/AK2
#Anykernel2 branch
AK2_branch=op5-flash-8.x
#kernel folder
k=/home/aritzherrero4/flash
#kernel-branch
kernel_branch=8.1.0-unified
#compiler folder
gcc=/home/aritzherrero4/gcc
#clang folder
clang=/home/aritzherrero4/clang



################
#              #
# SCRIPT START #
################

# Start tracking time
START=$(date +"%s")

clear
echo "${RED}"
echo
echo "================================================================================================"
echo
echo
echo "  ___________________________________  __   ______ _______________________   ________________   "
echo "  ___  ____/__  /___    |_  ___/__  / / /   ___  //_/__  ____/__  __ \__  | / /__  ____/__  /   "
echo "  __  /_   __  / __  /| |____ \__  /_/ /    __  ,<  __  __/  __  /_/ /_   |/ /__  __/  __  /    "
echo "  _  __/   _  /___  ___ |___/ /_  __  /     _  /| | _  /___  _  _, _/_  /|  / _  /___  _  /___  "
echo "  /_/      /_____/_/  |_/____/ /_/ /_/      /_/ |_| /_____/  /_/ |_| /_/ |_/  /_____/  /_____/  "
echo
echo
echo
echo "================================================================================================"
echo


#################
# MAKING KERNEL #
#################


# Clean up the source
clean_up

# Build kernel
build_kernel

# After build tasks
move_img
zip_kernel
sign_kernel
# Print file info and time
end_info -s  

