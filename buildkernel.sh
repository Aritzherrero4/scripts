#!/bin/bash
cd ..

#Options
T=""
while [ -n "$1" ]; do 
	case "$1" in
		-t | --test) 
			shift
			echo "Test build"
			T="-test"
			;;

    		-c | --clean)
			shift
			echo "Clean build"
        		cd kernel8998/
			make clean
			make mrproper
			rm -rf out/
			echo "Done. Starting build..."
			cd .. 
			;;

    		*) echo "Option $1 not recognized" ;;
    	esac
done


# Set Kernel Info
export T
export VERA="amethyst"
export VERB="$(date +%Y%m%d)"
VERSION="${VERA}-${VERB}${T}"

# Export User and Host 
export KBUILD_BUILD_USER=aritzherrero4
export KBUILD_BUILD_HOST=amethyst-build

#Set compiler
export COMPILER=GCC
export CROSS_COMPILE="$(pwd)/gcc/bin/aarch64-elf-"
export CROSS_COMPILE_ARM32="$(pwd)/gcc32/bin/arm-eabi-"
export STRIP="$(pwd)/gcc/bin/aarch64-elf-strip"
export ARCH=arm64 && export SUBARCH=arm64

# Export versions
export LOCALVERSION=`echo -${VERSION}`
export ZIPNAME="${VERSION}.zip"
#compilation
cd kernel8998
START=$(date +"%s")
make O=out ARCH=arm64 amethyst_defconfig
make -j$(nproc --all)  O=out ARCH=arm64

END=$(date +"%s")
DIFF=$((END - START))
cd ..

cp $(pwd)/kernel8998/out/arch/arm64/boot/Image.gz-dtb $(pwd)/anykernel

cd anykernel
#clear previous builds
rm *.zip
zip -r9 ${ZIPNAME} * -x README.md ${ZIPNAME}
CHECKER=$(ls -l ${ZIPNAME} | awk '{print $5}')
rm *.gz-dtb


if (($((CHECKER / 1048576)) > 5)); then
	echo "Build completed in $DIFF seconds"
	else
	echo "ERROR"
	exit 1;
fi
