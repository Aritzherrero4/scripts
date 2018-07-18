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
RED="\033[01;31m"
RST="\033[0m"
function echo() {
    command echo -e "$@"
}

function die() {
    echo
    echo -e "${RED}${1}"
    [[ ${2} = "-h" ]] && ${0} -h
    echo  "${RST}"
    exit 1
}

function sign_kernel() {
echo "sign kernel"
cd
java -jar "zipsigner-2.1.jar" \
              "flash-AH.zip" \
              "flash-AH-$day.zip"
}

function zip_kernel() {
echo "zip kernel"
cd 
cd ${AK2}
zip -r9 ${kernel_name}.zip * -x README.md ${kernel_name}.zip
cd
mv ${AK2}/flash-AH.zip /home/aritzherrero4/
}

# Clean up and prepare anykernel2 for 5/5T
function clean_up() {
    # Clean AnyKernel2 folder if building a zip
        cd 
        cd "${AK2}" || die "AnyKernel2 source is missing!"
        git checkout  ${AK2_branch}
        git clean -fxd 
	mkdir kernels
	cd kernels
	for OS in ${OS_LIST}; do
		mkdir ${OS}
	done
     
}

function build_kernel() {

OS_LIST="OOS Custom"

for OS in ${OS_LIST}; do
	cd 
        cd "${k}" || die "Kernel source is missing!"
	git checkout ${kernel_branch}
   	git clean -fxd
        
        make O=out/${OS} ARCH=arm64 flash-${OS,,}_defconfig

   	make -j$(nproc --all) O=out/${OS} \
                      ARCH=arm64 \
                      CC="${clang}/bin/clang" \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${gcc}/bin/aarch64-linux-gnu-"
        mv ${k}/out/${OS}${kdir} ${AK2}/kernels/${OS}
done

}
function end_info() {
    echo "SCRIPT FINISHED!"

    END=$(date +"%s")
    
    ELAPSED=$((${END} - ${START}))
    echo "${RED}DURATION: $((${ELAPSED} / 3600))hrs $(((${ELAPSED} / 60) % 60))min $((${ELAPSED} % 60))sec"

    echo  "${RST}"
    echo
    echo "\a"
    exit
}

################
#  VARIABLES   #
################

#AnyKernel2folder
AK2=/home/aritzherrero4/AK2
#Anykernel2 branch
AK2_branch=op5-flash-8.x-treble
#kernel folder
k=/home/aritzherrero4/flash
#kernel-branch
kernel_branch=8.1.0-unified-treble
#compiler folder
gcc=/home/aritzherrero4/gcc
#clang folder
clang=/home/aritzherrero4/clang
#kernel name
kernel_name=flash-AH
#compiled, zip and signed out folder
kout=/home/aritzherrero4
#kernel image directory
kdir=/arch/arm64/boot/Image.gz-dtb
#OS_List
OS_LIST="OOS Custom"

################
# SCRIPT START #
################

# Start tracking time
START=$(date +"%s")

clear
echo "${RED}"
echo
echo "================================================================================================"
echo "  ___________________________________  __   ______ _______________________   ________________   "
echo "  ___  ____/__  /___    |_  ___/__  / / /   ___  //_/__  ____/__  __ \__  | / /__  ____/__  /   "
echo "  __  /_   __  / __  /| |____ \__  /_/ /    __  ,<  __  __/  __  /_/ /_   |/ /__  __/  __  /    "
echo "  _  __/   _  /___  ___ |___/ /_  __  /     _  /| | _  /___  _  _, _/_  /|  / _  /___  _  /___  "
echo "  /_/      /_____/_/  |_/____/ /_/ /_/      /_/ |_| /_____/  /_/ |_| /_/ |_/  /_____/  /_____/  "
echo "================================================================================================"
echo  "${RST}"


#################
# MAKING KERNEL #
#################


# Clean up the source
clean_up
# Build kernel
build_kernel
# After build tasks
zip_kernel
sign_kernel
# Print file info and time
end_info -s  

