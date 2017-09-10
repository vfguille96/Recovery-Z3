@echo off

cd files

adb kill-server
adb start-server
adb wait-for-device

echo.
echo Device Detected!

echo.
echo Installing ...
echo.
adb shell "mkdir /data/local/tmp/mm_twrp_recovery_install"
adb push boot_twrp_recovery.sh /data/local/tmp/mm_twrp_recovery_install
adb push chargemon.sh /data/local/tmp/mm_twrp_recovery_install
adb push recovery.twrp.cpio.lzma /data/local/tmp/mm_twrp_recovery_install
adb push busybox /data/local/tmp/mm_twrp_recovery_install
adb push recbox /data/local/tmp/mm_twrp_recovery_install
adb push install_twrp_recovery.sh /data/local/tmp/mm_twrp_recovery_install
adb shell "chmod 755 /data/local/tmp/mm_twrp_recovery_install/busybox"
adb shell "chmod 755 /data/local/tmp/mm_twrp_recovery_install/recbox"
adb shell "chmod 755 /data/local/tmp/mm_twrp_recovery_install/install_twrp_recovery.sh"
adb shell "su -c 'mount -o remount,rw /system'"
adb shell "su -c /data/local/tmp/mm_twrp_recovery_install/install_twrp_recovery.sh"
adb shell "rm -r /data/local/tmp/mm_twrp_recovery_install"

echo.
echo Finished!

echo.
echo Rebooting into TWRP recovery ...
adb reboot

adb kill-server

echo.
pause
