#!/bin/bash
cd ..

#install some necesary things
sudo apt-get install ccache bc bash git-core build-essential zip curl make automake\
 autogen autoconf autotools-dev libtool shtool python m4 gcc libtool zlib1g-dev

#Download  Anykernel3
git clone https://github.com/aritzherrero4/anykernel3.git -b pie anykernel

#Download gcc

git clone https://github.com/kdrag0n/aarch64-elf-gcc -b 9.x --depth=3 gcc
git clone https://github.com/kdrag0n/arm-eabi-gcc -b 9.x --depth=3 gcc32
cd gcc
git checkout 14e746a95f594cf841bdf8c2e6122c274da7f70b
cd ../gcc32
git checkout 76c68effb613ff240ecad714f6c6f63368e91478
cd ..
