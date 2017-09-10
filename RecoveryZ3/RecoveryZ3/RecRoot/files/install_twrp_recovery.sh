#!/data/local/tmp/mm_twrp_recovery_install/busybox sh

BUSYBOX=/data/local/tmp/mm_twrp_recovery_install/busybox

# remount /system rw
${BUSYBOX} mount -o remount,rw /system

if [ ! -e /system/etc/mm_twrp_recovery ]; then

	${BUSYBOX} mkdir /system/etc/mm_twrp_recovery
	${BUSYBOX} chmod 0755 /system/etc/mm_twrp_recovery
	
fi

# copy busybox to system
${BUSYBOX} cp /data/local/tmp/mm_twrp_recovery_install/busybox /system/xbin/busybox
${BUSYBOX} chown 0.2000 /system/xbin/busybox
${BUSYBOX} chmod 755 /system/xbin/busybox

BUSYBOX=/system/xbin/busybox

# symlinking busybox applets
for i in $(${BUSYBOX} --list); do

	${BUSYBOX} ln -sf ${BUSYBOX} "/system/xbin/$i"
	
done

# copy busybox to system
${BUSYBOX} cp /data/local/tmp/mm_twrp_recovery_install/recbox /system/etc/mm_twrp_recovery/busybox
${BUSYBOX} chown 0.2000 /system/etc/mm_twrp_recovery/busybox
${BUSYBOX} chmod 755 /system/etc/mm_twrp_recovery/busybox

# copy twrp recovery
${BUSYBOX} cp /data/local/tmp/mm_twrp_recovery_install/recovery.twrp.cpio.lzma /system/etc/mm_twrp_recovery/recovery.twrp.cpio.lzma
${BUSYBOX} chown 0.0 /system/etc/mm_twrp_recovery/recovery.twrp.cpio.lzma
${BUSYBOX} chmod 644 /system/etc/mm_twrp_recovery/recovery.twrp.cpio.lzma

# copy reboot twrp recovery script
${BUSYBOX} cp /data/local/tmp/mm_twrp_recovery_install/boot_twrp_recovery.sh /system/etc/mm_twrp_recovery/boot_twrp_recovery.sh
${BUSYBOX} chown 0.0 /system/etc/mm_twrp_recovery/boot_twrp_recovery.sh
${BUSYBOX} chmod 755 /system/etc/mm_twrp_recovery/boot_twrp_recovery.sh

# chargemon hack
if [ ! -e "/system/bin/chargemon.stock" ]; then

	${BUSYBOX} mv /system/bin/chargemon /system/bin/chargemon.stock
	
fi
${BUSYBOX} cp /data/local/tmp/mm_twrp_recovery_install/chargemon.sh /system/bin/chargemon
${BUSYBOX} chown 0.0 /system/bin/chargemon
${BUSYBOX} chmod 755 /system/bin/chargemon

# remount /system ro
${BUSYBOX} mount -o remount,ro /system

# first boot goes to recovery
if [ -e /cache/recovery/ ]; then
	busybox touch /cache/recovery/boot
else
	busybox mkdir /cache/recovery/
	busybox touch /cache/recovery/boot
fi
