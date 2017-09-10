#!/sbin/busybox sh

BUSYBOX="/sbin/busybox"
LOG="/cache/mm_twrp_recovery.log"

echo "boot_twrp_recovery.sh" >> ${LOG}

export PATH=/sbin:/system/xbin:/system/bin

# Stop init services
echo "  stop init services" >> ${LOG}
for SVCRUNNING in $(getprop | ${BUSYBOX} grep -E '^\[init\.svc\..*\]: \[running\]'); do
	SVCNAME=$(${BUSYBOX} expr ${SVCRUNNING} : '\[init\.svc\.\(.*\)\]:.*')
	if [ "${SVCNAME}" != "" ]; then
		stop ${SVCNAME}
		if [ -f "/system/bin/${SVCNAME}" ]; then
			${BUSYBOX} pkill -f /system/bin/${SVCNAME}
		fi
	fi
done

# Preemptive strike against locking applications
echo "  preemptive strike against locking applications" >> ${LOG}
for LOCKINGPID in `${BUSYBOX} lsof | ${BUSYBOX} awk '{print $1" "$2}' | ${BUSYBOX} grep "/bin\|/system\|/data\|/cache" | ${BUSYBOX} awk '{print $1}'`; do
	BINARY=$(cat /proc/${LOCKINGPID}/status | ${BUSYBOX} grep -i "name" | ${BUSYBOX} awk -F':\t' '{print $2}')
	if [ "$BINARY" != "" ]; then
		${BUSYBOX} killall $BINARY
	fi
done

${BUSYBOX} sync

# Partitions
echo "  unmount partitions" >> ${LOG}
${BUSYBOX} umount -l /dev 2>> ${LOG}
${BUSYBOX} umount -l /sys/fs/cgroup 2>> ${LOG}
${BUSYBOX} umount -l /mnt 2>> ${LOG}
${BUSYBOX} umount -l /tmp 2>> ${LOG}
${BUSYBOX} umount -l /data 2>> ${LOG}
${BUSYBOX} umount -l /lta-label 2>> ${LOG}
${BUSYBOX} umount -l /idd 2>> ${LOG}
${BUSYBOX} umount -l /storage 2>> ${LOG}

# System odex
echo "  unmount /system odex cache (if present)" >> ${LOG}
${BUSYBOX} umount /system/odex.app
${BUSYBOX} umount /system/odex.priv-app
${BUSYBOX} umount /system/odex.framework

# System
echo "  unmount /system" >> ${LOG}
${BUSYBOX} umount /system 2>> ${LOG}

# Cache
echo "  unmount /cache" >> ${LOG}
${BUSYBOX} umount -l /cache

${BUSYBOX} sync

# Turn off led
echo 0 > /sys/class/leds/led:rgb_red/brightness
echo 0 > /sys/class/leds/led:rgb_green/brightness
echo 0 > /sys/class/leds/led:rgb_blue/brightness

# Clean
${BUSYBOX} rm -rf etc init* uevent* default* sdcard

# Create recovery folder
cd /
${BUSYBOX} mkdir /recovery
cd /recovery

# Unpack
${BUSYBOX} cpio -i -u < /sbin/recovery.twrp.cpio

# Execute
cd /
${BUSYBOX} chroot /recovery /init

# Reboot if error occurs
reboot
