.RECIPEPREFIX := $(.RECIPEPREFIX) 
.DEFAULT_GOAL := build-iso

build-iso:
    @./build.sh; echo "make: ISO built, check $$(ls ./out/aerOS*.iso)." || echo "make: ISO not built, try again."; exit 1
build-update:
    @rm -rf work
    @echo "debug: unpacking image..."
    @mkdir work work/fs
    @7z e out/aerOS*.iso -o./work arch/x86_64/airootfs.sfs
    @unsquashfs -f -d ./work/fs ./work/airootfs.sfs
    @echo "debug: converting image..."
    @( cd ./work/fs && rm -rf etc/fstab etc/passwd etc/shadow etc/hostname etc/calamares etc/sudoers etc/group etc/gdm/custom.conf etc/xdg/Trolltech.conf etc/xdg/autostart/calamares.desktop )
    @( cd ./work/fs && rm -rf usr/bin/calamares usr/bin/calamares_polkit )
    @( cd ./work/fs && rm -rf usr/lib/calamares usr/lib/libcalamares* usr/lib/initcpio/hooks/archiso* && rm -rf usr/lib/firmware )
    @( cd ./work/fs && rm -rf boot dev home mnt proc root run srv sys tmp )
    @sed -i 's/archiso archiso_loop_mnt archiso_pxe_common archiso_pxe_nbd archiso_pxe_http archiso_pxe_nfs //g' ./work/fs/etc/mkinitcpio.conf
    @echo "debug: creating new image..."
    @( cd ./work/fs && tar -cf - . | pv -s $$(du -sb . | cut -f1) | gzip -1 > ../../out/update.tar.gz )
    @echo "make: image created, check $$(ls ./out/update.tar.gz)."
    @rm -rf work
