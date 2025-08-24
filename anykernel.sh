# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=N0Kontzzz by bimoalfarrabi (thanks to EmanuelCN & Impqxr)
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=munch
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 750 750 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;

# Auto-detect variant from zip name
case "$ZIPFILE" in
  *N0Kernel*) v=default;;
  *-miui)     v=miui;;
esac

# Automatic miui detection
region="$(file_getprop /vendor/build.prop "ro.vendor.miui.build.region")"
case "$region" in
  cn|in|ru|id|eu|tr|tw|gb|global|mx|jp|kr|lm|cl|mi)
      v=miui
      ui_print "  -> MIUI ROM is detected!"
    ;;
esac

# Select default if still unset
[ -z "$v" ] && v=default

# Apply the right dtbo
ui_print " • Using $v DTBO"
if [ "$v" != default ]; then
  rm -f dtbo.img && mv "$v/dtbo.img" "dtbo.img"
fi

## AnyKernel install
dump_boot;

# Begin Ramdisk Changes

# migrate from /overlay to /overlay.d to enable SAR Magisk
if [ -d $ramdisk/overlay ]; then
  rm -rf $ramdisk/overlay;
fi;

write_boot;
## end install

## vendor_boot shell variables
block=/dev/block/bootdevice/by-name/vendor_boot;
is_slot_device=1;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

# reset for vendor_boot patching
reset_ak;

# vendor_boot install
dump_boot;

write_boot;
## end vendor_boot install
