# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Ancient Kernel
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=platina
device.name2=platina-user
device.name3=MI 8 Lite
device.name4=Xiaomi
device.name5=
supported.versions=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chown -R root:root $ramdisk/*;


## AnyKernel install
dump_boot;

# begin ramdisk changes

# init.rc
#insert_line init.rc 'ancient' after 'import /init.\${ro.zygote}.rc' 'import /init.ancient.rc';

# Patch F2FS thanks Aradium
vft=/vendor/etc/fstab.qcom;
$bb mount -o rw,remount -t auto /system >/dev/null;
$bb mount -o rw,remount -t auto /vendor 2>/dev/null;
if [ -n $(grep "f2fs" $vft 2>/dev/null) != "" ]; then
  ui_print "";
  ui_print "";
  ui_print "Patching F2FS...";
backup_file $vft;
insert_line $vft 'f2fs-data' after '/dev/block/bootdevice/by-name/userdata' '/dev/block/bootdevice/by-name/userdata   /data                  f2fs   noatime,nosuid,nodev,nodiratime,fsync_mode=nobarrier,background_gc=off   wait,check,encryptable=footer,crashcheck,quota,reservedsize=128M';
insert_line $vft 'f2fs-cache' after '/dev/block/bootdevice/by-name/cache' '/dev/block/bootdevice/by-name/cache      /cache                 f2fs   noatime,nosuid,nodev,nodiratime,discard,fsync_mode=nobarrier,inline_xattr,inline_data,data_flush   wait';
else
  ui_print "";
  ui_print "";
  ui_print "Your ROM already support F2FS partitions";
fi;
$bb mount -o ro,remount -t auto /system >/dev/null;
$bb mount -o ro,remount -t auto /vendor 2>/dev/null;

# end ramdisk changes

write_boot;
## end install

