#!/sbin/sh

if [ ! -f /tmp/byeselinux.ko ]; then
	echo "Error patching kernel module. File not found."
	exit 1
fi

if [ ! -f /tmp/busybox ]; then
	echo "Error: busybox not found"
	exit 1
fi

/tmp/busybox mount /system
/tmp/busybox mount /dev/block/platform/msm_sdcc.1/by-name/system /system

if [ -f /tmp/modulecrcpatch ]; then
	for f in /system/lib/modules/*.ko; do
		/tmp/modulecrcpatch $f /tmp/byeselinux.ko
	done
fi

if [ ! -f /system/lib/modules/mhl_sii8620_8061_drv_orig.ko ]; then
	cp /system/lib/modules/mhl_sii8620_8061_drv.ko /system/lib/modules/mhl_sii8620_8061_drv_orig.ko
	chmod 644 /system/lib/modules/mhl_sii8620_8061_drv_orig.ko
fi

cp /tmp/byeselinux.ko /system/lib/modules/mhl_sii8620_8061_drv.ko
chmod 644 /system/lib/modules/mhl_sii8620_8061_drv.ko

echo "Installing of installbyeselinux.sh finished"
