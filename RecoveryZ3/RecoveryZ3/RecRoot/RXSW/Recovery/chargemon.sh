#!/system/xbin/busybox sh

BUSYBOX=/system/xbin/busybox

VIB=/sys/class/timed_output/vibrator/enable
R_LED=/sys/class/leds/led:rgb_red/brightness
G_LED=/sys/class/leds/led:rgb_green/brightness
B_LED=/sys/class/leds/led:rgb_blue/brightness

LOG="/cache/mm_twrp_recovery.log"
WORKDIR="/cache/mm_twrp_recovery_keycheck"

MKDIR="${BUSYBOX} mkdir"
CHOWN="${BUSYBOX} chown"
CHMOD="${BUSYBOX} chmod"
TOUCH="${BUSYBOX} touch"
CAT="${BUSYBOX} cat"
SLEEP="${BUSYBOX} sleep"
KILL="${BUSYBOX} kill"
RM="${BUSYBOX} rm"
PS="${BUSYBOX} ps"
GREP="${BUSYBOX} grep"
AWK="${BUSYBOX} awk"
EXPR="${BUSYBOX} expr"
MOUNT="${BUSYBOX} mount"
LS="${BUSYBOX} ls"
HEXDUMP="${BUSYBOX} hexdump"
CP="${BUSYBOX} cp"

${RM} -f ${LOG}
echo "chargemon" >> ${LOG}

BOOTTWRP=0

if [ -e "/cache/recovery/boot" ]; then

	echo "  /cache/recovery/boot file found" >> ${LOG}
	
	${RM} -f /cache/recovery/boot
	
	echo 255 > ${R_LED}
	echo 0 > ${G_LED}
	echo 255 > ${B_LED}
	
	BOOTTWRP=1

else

	if [ ! -d "${WORKDIR}" ]; then
		
		${MKDIR} ${WORKDIR}
		${CHOWN} system.cache ${WORKDIR}
		${CHMOD} 770 ${WORKDIR}
		
	fi

	if [ ! -e ${WORKDIR}/keycheck ]; then
		
		${RM} ${WORKDIR}/keyevent*
		${RM} ${WORKDIR}/keycheck_down
		${RM} ${WORKDIR}/ps*
		
	fi
	
	echo 0 > ${R_LED}
	echo 255 > ${G_LED}
	echo 0 > ${B_LED}
	
	echo 150 > ${VIB}
	
	for EVENTDEV in $(${LS} /dev/input/event* ); do
	
		SUFFIX="$(${EXPR} ${EVENTDEV} : '/dev/input/event\(.*\)')"
		${CAT} ${EVENTDEV} > ${WORKDIR}/keyevent${SUFFIX} &
		
	done
	
	${SLEEP} 2

	${PS} > ${WORKDIR}/ps.log
	${CHMOD} 660 ${WORKDIR}/ps.log

	for CATPROC in $(${PS} | ${GREP} /dev/input/event | ${GREP} -v grep | ${AWK} '{print $1}'); do
	
		${KILL} -9 ${CATPROC}
	   
	done
	
	${HEXDUMP} ${WORKDIR}/keyevent* | ${GREP} -e '^.* 0001 0072 .... ....$' > ${WORKDIR}/keycheck_down

	if [ -s ${WORKDIR}/keycheck_down ]; then

		echo "  keycheck volume down - ok" >> ${LOG}
	
		echo 255 > ${R_LED}
		echo 0 > ${G_LED}
		echo 255 > ${B_LED}
		
		BOOTTWRP=1

	fi
	
fi

if [ $BOOTTWRP -eq 1 ]; then

	echo "  remount rootfs rw" >> ${LOG}
	mount -o remount,rw rootfs / 2>> ${LOG}
	
	echo "  copy busybox to /sbin" >> ${LOG}
	${CP} /system/etc/mm_twrp_recovery/busybox /sbin
	${CHOWN} 0.2000 /sbin/busybox
	${CHMOD} 755 /sbin/busybox
	
	BUSYBOX=/sbin/busybox
	
	echo "  copy boot_twrp_recovery.sh to /sbin" >> ${LOG}
	${CP} /system/etc/mm_twrp_recovery/boot_twrp_recovery.sh /sbin
	${CHOWN} 0.0 /sbin/boot_twrp_recovery.sh
	${CHMOD} 755 /sbin/boot_twrp_recovery.sh

	echo "  copy recovery.twrp.cpio.lzma to /sbin" >> ${LOG}
	${CP} /system/etc/mm_twrp_recovery/recovery.twrp.cpio.lzma /sbin
	${CHOWN} 0.0 /sbin/recovery.twrp.cpio.lzma
	${CHMOD} 644 /sbin/recovery.twrp.cpio.lzma
	
	echo "  unpack recovery.twrp.cpio.lzma" >> ${LOG}
	${BUSYBOX} lzma -d /sbin/recovery.twrp.cpio.lzma
	
	echo "  exec boot_twrp_recovery.sh (twrp boot)" >> ${LOG}
	exec /sbin/boot_twrp_recovery.sh

fi

echo 0 > ${B_LED}
echo 0 > ${R_LED}
echo 0 > ${G_LED}

echo "  exec chargemon.stock (regular boot)" >> ${LOG}
exec /system/bin/chargemon.stock
exit 0
