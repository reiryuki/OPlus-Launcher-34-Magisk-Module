# space
ui_print " "

# var
UID=`id -u`
[ ! "$UID" ] && UID=0
FIRARCH=`grep_get_prop ro.bionic.arch`
SECARCH=`grep_get_prop ro.bionic.2nd_arch`
ABILIST=`grep_get_prop ro.product.cpu.abilist`
if [ ! "$ABILIST" ]; then
  ABILIST=`grep_get_prop ro.system.product.cpu.abilist`
fi
if [ "$FIRARCH" == arm64 ]\
&& ! echo "$ABILIST" | grep -q arm64-v8a; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,arm64-v8a"
  else
    ABILIST=arm64-v8a
  fi
fi
if [ "$FIRARCH" == x64 ]\
&& ! echo "$ABILIST" | grep -q x86_64; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,x86_64"
  else
    ABILIST=x86_64
  fi
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST" | grep -q armeabi; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,armeabi"
  else
    ABILIST=armeabi
  fi
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST" | grep -q armeabi-v7a; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,armeabi-v7a"
  else
    ABILIST=armeabi-v7a
  fi
fi
if [ "$SECARCH" == x86 ]\
&& ! echo "$ABILIST" | grep -q x86; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,x86"
  else
    ABILIST=x86
  fi
fi
ABILIST32=`grep_get_prop ro.product.cpu.abilist32`
if [ ! "$ABILIST32" ]; then
  ABILIST32=`grep_get_prop ro.system.product.cpu.abilist32`
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST32" | grep -q armeabi; then
  if [ "$ABILIST32" ]; then
    ABILIST32="$ABILIST32,armeabi"
  else
    ABILIST32=armeabi
  fi
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST32" | grep -q armeabi-v7a; then
  if [ "$ABILIST32" ]; then
    ABILIST32="$ABILIST32,armeabi-v7a"
  else
    ABILIST32=armeabi-v7a
  fi
fi
if [ "$SECARCH" == x86 ]\
&& ! echo "$ABILIST32" | grep -q x86; then
  if [ "$ABILIST32" ]; then
    ABILIST32="$ABILIST32,x86"
  else
    ABILIST32=x86
  fi
fi
if [ ! "$ABILIST32" ]; then
  [ -f /system/lib/libandroid.so ] && ABILIST32=true
fi

# log
if [ "$BOOTMODE" != true ]; then
  FILE=/data/media/"$UID"/$MODID\_recovery.log
  ui_print "- Log will be saved at $FILE"
  exec 2>$FILE
  ui_print " "
fi

# optionals
OPTIONALS=/data/media/"$UID"/optionals.prop
if [ ! -f $OPTIONALS ]; then
  touch $OPTIONALS
fi

# debug
if [ "`grep_prop debug.log $OPTIONALS`" == 1 ]; then
  ui_print "- The install log will contain detailed information"
  set -x
  ui_print " "
fi

# recovery
if [ "$BOOTMODE" != true ]; then
  MODPATH_UPDATE=`echo $MODPATH | sed 's|modules/|modules_update/|g'`
  rm -f $MODPATH/update
  rm -rf $MODPATH_UPDATE
fi

# run
. $MODPATH/function.sh

# info
MODVER=`grep_prop version $MODPATH/module.prop`
MODVERCODE=`grep_prop versionCode $MODPATH/module.prop`
ui_print " ID=$MODID"
ui_print " Version=$MODVER"
ui_print " VersionCode=$MODVERCODE"
if [ "$KSU" == true ]; then
  ui_print " KSUVersion=$KSU_VER"
  ui_print " KSUVersionCode=$KSU_VER_CODE"
  ui_print " KSUKernelVersionCode=$KSU_KERNEL_VER_CODE"
  sed -i 's|#k||g' $MODPATH/post-fs-data.sh
else
  ui_print " MagiskVersion=$MAGISK_VER"
  ui_print " MagiskVersionCode=$MAGISK_VER_CODE"
fi
ui_print " "

# sdk
NUM=34
if [ "$API" -lt $NUM ]; then
  ui_print "! Unsupported SDK $API."
  ui_print "  You have to upgrade your Android version"
  ui_print "  at least SDK $NUM to use this module."
  abort
else
  ui_print "- SDK $API"
  ui_print " "
fi

# oplus core
FILE=/data/adb/modules/OPlusCore/module.prop
NUM=`grep_prop versionCode $FILE`
if [ ! -f $FILE ]; then
  ui_print "! OPlus Core Magisk Module is not installed."
  ui_print "  Please read github installation guide!"
  abort
elif [ "$NUM" -lt 3 ]; then
  ui_print "! This version requires OPlus Core Magisk Module"
  ui_print "  v0.3 or above."
  abort
else
  rm -f /data/adb/modules/OPlusCore/remove
  rm -f /data/adb/modules/OPlusCore/disable
fi

# recovery
mount_partitions_in_recovery

# sepolicy
FILE=$MODPATH/sepolicy.rule
DES=$MODPATH/sepolicy.pfsd
if [ "`grep_prop sepolicy.sh $OPTIONALS`" == 1 ]\
&& [ -f $FILE ]; then
  mv -f $FILE $DES
fi

# cleaning
ui_print "- Cleaning..."
PKGS="`cat $MODPATH/package.txt` com.oneplus.launcher"
if [ "$BOOTMODE" == true ]; then
  for PKG in $PKGS; do
    FILE=`find /data/app -name *$PKG*`
    if [ "$FILE" ]; then
      RES=`pm uninstall $PKG 2>/dev/null`
    fi
  done
fi
remove_sepolicy_rule
ui_print " "

# function
conflict() {
for NAME in $NAMES; do
  DIR=/data/adb/modules_update/$NAME
  if [ -f $DIR/uninstall.sh ]; then
    sh $DIR/uninstall.sh
  fi
  rm -rf $DIR
  DIR=/data/adb/modules/$NAME
  rm -f $DIR/update
  touch $DIR/remove
  FILE=/data/adb/modules/$NAME/uninstall.sh
  if [ -f $FILE ]; then
    sh $FILE
    rm -f $FILE
  fi
  rm -rf /metadata/magisk/$NAME
  rm -rf /mnt/vendor/persist/magisk/$NAME
  rm -rf /persist/magisk/$NAME
  rm -rf /data/unencrypted/magisk/$NAME
  rm -rf /cache/magisk/$NAME
  rm -rf /cust/magisk/$NAME
done
}

# conflict
NAMES=OnePlusLauncher
conflict

# recents
NUM=34
if [ "`grep_prop oplus.recents $OPTIONALS`" == 1 ]; then
  if [ "$API" -ge $NUM ]; then
    RECENTS=true
  else
    RECENTS=false
    ui_print "- The recents provider is only for SDK $NUM and up"
    ui_print " "
  fi
else
  RECENTS=false
fi
if [ "$RECENTS" == true ]; then
  NAME=*RecentsOverlay.apk
  ui_print "- $MODNAME recents provider will be activated"
  ui_print "- Quick Switch module will be disabled"
  ui_print "- Renaming any other else module $NAME"
  ui_print "  to $NAME.bak"
  touch /data/adb/modules/quickstepswitcher/disable
  touch /data/adb/modules/quickswitch/disable
  sed -i 's|#r||g' $MODPATH/post-fs-data.sh
  FILES=`find /data/adb/modules* ! -path "*/$MODID/*" -type f -name $NAME`
  for FILE in $FILES; do
    mv -f $FILE $FILE.bak
  done
  ui_print " "
  DIR=/overlay/PixelConfigOverlayCommon
  if [ -d /product$DIR ]; then
    REPLACE="$REPLACE /system/product$DIR"
  fi
  if [ -f /product$DIR.apk ]; then
    mktouch $MODPATH/system/product$DIR.apk
  fi
  if [ -d /vendor$DIR ]; then
    REPLACE="$REPLACE /system/vendor$DIR"
  fi
  if [ -f /vendor$DIR.apk ]; then
    mktouch $MODPATH/system/vendor$DIR.apk
  fi
  if [ -d /odm$DIR ]\
  && [ "`realpath /odm$DIR`" == /odm$DIR ]; then
    REPLACE="$REPLACE /system/odm$DIR"
  fi
  if [ -f /odm$DIR.apk ]\
  && [ "`realpath /odm$DIR.apk`" == /odm$DIR.apk ]; then
    mktouch $MODPATH/system/odm$DIR.apk
  fi
  if [ -d /vendor/odm$DIR ]\
  && [ "`realpath /vendor/odm$DIR`" == /vendor/odm$DIR ]; then
    REPLACE="$REPLACE /system/vendor/odm$DIR"
  fi
  if [ -f /vendor/odm$DIR.apk ]\
  && [ "`realpath /vendor/odm$DIR.apk`" == /vendor/odm$DIR.apk ]; then
    mktouch $MODPATH/system/vendor/odm$DIR.apk
  fi
else
  rm -rf $MODPATH/system/product/overlay\
   `find $MODPATH -name *thena*`
fi
if [ "$RECENTS" == true ]; then
  if [ "`grep_prop overlay.location $OPTIONALS`" == odm ]\
  && [ -d /odm/overlay ]\
  && [ "`realpath /odm/overlay`" == /odm/overlay ]; then
    if grep /odm /data/adb/magisk/magisk\
    || grep /odm /data/adb/magisk/magisk64\
    || grep /odm /data/adb/magisk/magisk32; then
      ui_print "- Using /odm/overlay/ instead of /product/overlay/"
      mkdir -p $MODPATH/system/odm
      cp -rf $MODPATH/system/product/overlay $MODPATH/system/odm
      rm -rf $MODPATH/system/product/overlay
      ui_print " "
    else
      ui_print "! Kitsune Mask/Magisk Delta is not installed or"
      ui_print "  the version doesn't support /odm"
      ui_print " "
    fi
  elif [ "`grep_prop overlay.location $OPTIONALS`" == odm ]\
  && [ -d /vendor/odm/overlay ]\
  && [ "`realpath /vendor/odm/overlay`" == /vendor/odm/overlay ]; then
    ui_print "- Using /vendor/odm/overlay/ instead of /product/overlay/"
    mkdir -p $MODPATH/system/vendor/odm
    cp -rf $MODPATH/system/product/overlay $MODPATH/system/vendor/odm
    rm -rf $MODPATH/system/product/overlay
    ui_print " "
  elif [ ! -d /product/overlay ]\
  || [ "`grep_prop overlay.location $OPTIONALS`" == vendor ]; then
    ui_print "- Using /vendor/overlay/ instead of /product/overlay/"
    mkdir -p $MODPATH/system/vendor
    cp -rf $MODPATH/system/product/overlay $MODPATH/system/vendor
    rm -rf $MODPATH/system/product/overlay
    ui_print " "
  fi
fi

# media
unused() {
if [ ! -d /product/media ] && [ -d /system/media ]; then
  ui_print "- Using /system/media instead of /product/media"
  mv -f $MODPATH/system/product/media $MODPATH/system
  ui_print " "
elif [ ! -d /product/media ] && [ ! -d /system/media ]; then
  ui_print "! /product/media & /system/media not found"
  ui_print " "
fi
}

# function
cleanup() {
if [ -f $DIR/uninstall.sh ]; then
  sh $DIR/uninstall.sh
fi
DIR=/data/adb/modules_update/$MODID
if [ -f $DIR/uninstall.sh ]; then
  sh $DIR/uninstall.sh
fi
}

# cleanup
DIR=/data/adb/modules/$MODID
FILE=$DIR/module.prop
PREVMODNAME=`grep_prop name $FILE`
if [ "`grep_prop data.cleanup $OPTIONALS`" == 1 ]; then
  sed -i 's|^data.cleanup=1|data.cleanup=0|g' $OPTIONALS
  ui_print "- Cleaning-up $MODID data..."
  cleanup
  ui_print " "
#elif [ -d $DIR ]\
#&& [ "$PREVMODNAME" != "$MODNAME" ]; then
#  ui_print "- Different module name is detected"
#  ui_print "  Cleaning-up $MODID data..."
#  cleanup
#  ui_print " "
fi

# function
permissive_2() {
sed -i 's|#2||g' $MODPATH/post-fs-data.sh
}
permissive() {
FILE=/sys/fs/selinux/enforce
FILE2=/sys/fs/selinux/policy
if [ "`toybox cat $FILE`" = 1 ]; then
  chmod 640 $FILE
  chmod 440 $FILE2
  echo 0 > $FILE
  if [ "`toybox cat $FILE`" = 1 ]; then
    ui_print "  Your device can't be turned to Permissive state."
    ui_print "  Using Magisk Permissive mode instead."
    permissive_2
  else
    echo 1 > $FILE
    sed -i 's|#1||g' $MODPATH/post-fs-data.sh
  fi
else
  sed -i 's|#1||g' $MODPATH/post-fs-data.sh
fi
}

# permissive
if [ "`grep_prop permissive.mode $OPTIONALS`" == 1 ]; then
  ui_print "- Using device Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive
  ui_print " "
elif [ "`grep_prop permissive.mode $OPTIONALS`" == 2 ]; then
  ui_print "- Using Magisk Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive_2
  ui_print " "
fi

# function
extract_lib() {
for APP in $APPS; do
  FILE=`find $MODPATH/system -type f -name $APP.apk`
  if [ -f `dirname $FILE`/extract ]; then
    ui_print "- Extracting..."
    DIR=`dirname $FILE`/lib/"$ARCHLIB"
    mkdir -p $DIR
    rm -rf $TMPDIR/*
    DES=lib/"$ABILIB"/*
    unzip -d $TMPDIR -o $FILE $DES
    cp -f $TMPDIR/$DES $DIR
    ui_print " "
  fi
done
}
hide_oat() {
for APP in $APPS; do
  REPLACE="$REPLACE
  `find $MODPATH/system -type d -name $APP | sed "s|$MODPATH||g"`/oat"
done
}

# extract
APPS="`ls $MODPATH/system/priv-app`
      `ls $MODPATH/system/app`"
ARCHLIB=arm64
ABILIB=arm64-v8a
extract_lib
ARCHLIB=arm
if echo "$ABILIST" | grep -q armeabi-v7a; then
  ABILIB=armeabi-v7a
  extract_lib
elif echo "$ABILIST" | grep -q armeabi; then
  ABILIB=armeabi
  extract_lib
else
  ABILIB=armeabi-v7a
  extract_lib
fi
ARCHLIB=x64
ABILIB=x86_64
extract_lib
ARCHLIB=x86
ABILIB=x86
extract_lib
rm -f `find $MODPATH/system -type f -name extract`
# hide
hide_oat

# function
warning() {
ui_print "  If you are disabling this module,"
ui_print "  then you need to reinstall this module, reboot,"
ui_print "  & reinstall again to re-grant permissions."
}
warning_2() {
ui_print "  If android.permission.INTERACT_ACROSS_USERS_FULL"
ui_print "  still not granted, then you need to reinstall this module"
ui_print "  again after reboot."
}
patch_runtime_permisions() {
ui_print "- Granting permissions"
ui_print "  Please wait..."
# patching other than 0 causes bootloop
FILES=`find /data/system/users/0 /data/misc_de/0 -type f -name runtime-permissions.xml`
for FILE in $FILES; do
  chmod 0600 $FILE
  if grep -q '<shared-user name="oppo.uid.launcher" />' $FILE; then
    sed -i 's|<shared-user name="oppo.uid.launcher" />|\
<shared-user name="oppo.uid.launcher">\
<permission name="android.permission.INPUT_CONSUMER" granted="true" flags="0" />\
<permission name="android.permission.WRITE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.READ_WALLPAPER_INTERNAL" granted="true" flags="0" />\
<permission name="android.permission.POST_NOTIFICATIONS" granted="true" flags="0" />\
<permission name="android.permission.MODIFY_AUDIO_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.SYSTEM_ALERT_WINDOW" granted="true" flags="0" />\
<permission name="android.permission.START_TASKS_FROM_RECENTS" granted="true" flags="0" />\
<permission name="android.permission.MONITOR_INPUT" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_COMPONENT_ENABLED_STATE" granted="true" flags="0" />\
<permission name="android.permission.INTERNAL_SYSTEM_WINDOW" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACTIVITY_TASKS" granted="true" flags="0" />\
<permission name="android.permission.RECEIVE_BOOT_COMPLETED" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ROLE_HOLDERS" granted="true" flags="0" />\
<permission name="android.permission.DEVICE_POWER" granted="true" flags="0" />\
<permission name="android.permission.REMOVE_TASKS" granted="true" flags="0" />\
<permission name="android.permission.EXPAND_STATUS_BAR" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.ACTION_DEEP_PROTECT_START_APP" granted="true" flags="0" />\
<permission name="android.permission.INTERNET" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.HOTSEAT_EDU" granted="true" flags="0" />\
<permission name="android.permission.REORDER_TASKS" granted="true" flags="0" />\
<permission name="android.permission.ROTATE_SURFACE_FLINGER" granted="true" flags="0" />\
<permission name="android.permission.READ_EXTERNAL_STORAGE" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACCESSIBILITY" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.WRITE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.CONTROL_REMOTE_APP_TRANSITION_ANIMATIONS" granted="true" flags="0" />\
<permission name="android.permission.INTERACT_ACROSS_USERS_FULL" granted="true" flags="0" />\
<permission name="android.permission.BIND_APPWIDGET" granted="true" flags="0" />\
<permission name="android.permission.STOP_APP_SWITCHES" granted="true" flags="0" />\
<permission name="android.permission.WRITE_SECURE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.STATUS_BAR_SERVICE" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.READ_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.READ_PRIVILEGED_PHONE_STATE" granted="true" flags="0" />\
<permission name="android.permission.CALL_PHONE" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_IMAGES" granted="true" flags="0" />\
<permission name="android.permission.SUBSTITUTE_NOTIFICATION_APP_NAME" granted="true" flags="0" />\
<permission name="android.permission.SYSTEM_APPLICATION_OVERLAY" granted="true" flags="0" />\
<permission name="android.permission.SET_ORIENTATION" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_USERS" granted="true" flags="0" />\
<permission name="android.permission.SET_PREFERRED_APPLICATIONS" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER_COMPONENT" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_NETWORK_STATE" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_CONFIGURATION" granted="true" flags="0" />\
<permission name="android.permission.INTERACT_ACROSS_USERS" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER" granted="true" flags="0" />\
<permission name="android.permission.WAKEUP_SURFACE_FLINGER" granted="true" flags="0" />\
<permission name="android.permission.BROADCAST_CLOSE_SYSTEM_DIALOGS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_SHORTCUTS" granted="true" flags="0" />\
<permission name="android.permission.REQUEST_DELETE_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.ADD_TRUSTED_DISPLAY" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER_HINTS" granted="true" flags="0" />\
<permission name="android.permission.ALLOW_SLIPPERY_TOUCHES" granted="true" flags="0" />\
<permission name="android.permission.VIBRATE" granted="true" flags="0" />\
<permission name="android.permission.CAPTURE_BLACKOUT_CONTENT" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_APP_HIBERNATION" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACTIVITY_STACKS" granted="true" flags="0" />\
<permission name="android.permission.MODIFY_APPWIDGET_BIND_PERMISSIONS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_WIFI_STATE" granted="true" flags="0" />\
<permission name="android.permission.USE_BIOMETRIC" granted="true" flags="0" />\
<permission name="android.permission.STATUS_BAR" granted="true" flags="0" />\
<permission name="android.permission.READ_FRAME_BUFFER" granted="true" flags="0" />\
<permission name="android.permission.QUERY_ALL_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.READ_DEVICE_CONFIG" granted="true" flags="0" />\
<permission name="android.permission.UNLIMITED_TOASTS" granted="true" flags="0" />\
<permission name="android.permission.INJECT_EVENTS" granted="true" flags="0" />\
<permission name="android.permission.DELETE_PACKAGES" granted="true" flags="0" />\
</shared-user>\n|g' $FILE
    warning
  elif grep -q '<shared-user name="oppo.uid.launcher"/>' $FILE; then
    sed -i 's|<shared-user name="oppo.uid.launcher"/>|\
<shared-user name="oppo.uid.launcher">\
<permission name="android.permission.INPUT_CONSUMER" granted="true" flags="0" />\
<permission name="android.permission.WRITE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.READ_WALLPAPER_INTERNAL" granted="true" flags="0" />\
<permission name="android.permission.POST_NOTIFICATIONS" granted="true" flags="0" />\
<permission name="android.permission.MODIFY_AUDIO_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.SYSTEM_ALERT_WINDOW" granted="true" flags="0" />\
<permission name="android.permission.START_TASKS_FROM_RECENTS" granted="true" flags="0" />\
<permission name="android.permission.MONITOR_INPUT" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_COMPONENT_ENABLED_STATE" granted="true" flags="0" />\
<permission name="android.permission.INTERNAL_SYSTEM_WINDOW" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACTIVITY_TASKS" granted="true" flags="0" />\
<permission name="android.permission.RECEIVE_BOOT_COMPLETED" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ROLE_HOLDERS" granted="true" flags="0" />\
<permission name="android.permission.DEVICE_POWER" granted="true" flags="0" />\
<permission name="android.permission.REMOVE_TASKS" granted="true" flags="0" />\
<permission name="android.permission.EXPAND_STATUS_BAR" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.ACTION_DEEP_PROTECT_START_APP" granted="true" flags="0" />\
<permission name="android.permission.INTERNET" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.HOTSEAT_EDU" granted="true" flags="0" />\
<permission name="android.permission.REORDER_TASKS" granted="true" flags="0" />\
<permission name="android.permission.ROTATE_SURFACE_FLINGER" granted="true" flags="0" />\
<permission name="android.permission.READ_EXTERNAL_STORAGE" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACCESSIBILITY" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.WRITE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.CONTROL_REMOTE_APP_TRANSITION_ANIMATIONS" granted="true" flags="0" />\
<permission name="android.permission.INTERACT_ACROSS_USERS_FULL" granted="true" flags="0" />\
<permission name="android.permission.BIND_APPWIDGET" granted="true" flags="0" />\
<permission name="android.permission.STOP_APP_SWITCHES" granted="true" flags="0" />\
<permission name="android.permission.WRITE_SECURE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.STATUS_BAR_SERVICE" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.READ_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.READ_PRIVILEGED_PHONE_STATE" granted="true" flags="0" />\
<permission name="android.permission.CALL_PHONE" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_IMAGES" granted="true" flags="0" />\
<permission name="android.permission.SUBSTITUTE_NOTIFICATION_APP_NAME" granted="true" flags="0" />\
<permission name="android.permission.SYSTEM_APPLICATION_OVERLAY" granted="true" flags="0" />\
<permission name="android.permission.SET_ORIENTATION" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_USERS" granted="true" flags="0" />\
<permission name="android.permission.SET_PREFERRED_APPLICATIONS" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER_COMPONENT" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_NETWORK_STATE" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_CONFIGURATION" granted="true" flags="0" />\
<permission name="android.permission.INTERACT_ACROSS_USERS" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER" granted="true" flags="0" />\
<permission name="android.permission.WAKEUP_SURFACE_FLINGER" granted="true" flags="0" />\
<permission name="android.permission.BROADCAST_CLOSE_SYSTEM_DIALOGS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_SHORTCUTS" granted="true" flags="0" />\
<permission name="android.permission.REQUEST_DELETE_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.ADD_TRUSTED_DISPLAY" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER_HINTS" granted="true" flags="0" />\
<permission name="android.permission.ALLOW_SLIPPERY_TOUCHES" granted="true" flags="0" />\
<permission name="android.permission.VIBRATE" granted="true" flags="0" />\
<permission name="android.permission.CAPTURE_BLACKOUT_CONTENT" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_APP_HIBERNATION" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACTIVITY_STACKS" granted="true" flags="0" />\
<permission name="android.permission.MODIFY_APPWIDGET_BIND_PERMISSIONS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_WIFI_STATE" granted="true" flags="0" />\
<permission name="android.permission.USE_BIOMETRIC" granted="true" flags="0" />\
<permission name="android.permission.STATUS_BAR" granted="true" flags="0" />\
<permission name="android.permission.READ_FRAME_BUFFER" granted="true" flags="0" />\
<permission name="android.permission.QUERY_ALL_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.READ_DEVICE_CONFIG" granted="true" flags="0" />\
<permission name="android.permission.UNLIMITED_TOASTS" granted="true" flags="0" />\
<permission name="android.permission.INJECT_EVENTS" granted="true" flags="0" />\
<permission name="android.permission.DELETE_PACKAGES" granted="true" flags="0" />\
</shared-user>\n|g' $FILE
    warning
  elif grep -q '<shared-user name="oppo.uid.launcher">' $FILE; then
    {
    COUNT=1
    LIST=`cat $FILE | sed 's|><|>\n<|g'`
    RES=`echo "$LIST" | grep -A$COUNT '<shared-user name="oppo.uid.launcher">'`
    until echo "$RES" | grep -q '</shared-user>'; do
      COUNT=`expr $COUNT + 1`
      RES=`echo "$LIST" | grep -A$COUNT '<shared-user name="oppo.uid.launcher">'`
    done
    } 2>/dev/null
    if ! echo "$RES" | grep -q 'name="android.permission.DEVICE_POWER" granted="true"'\
    || ! echo "$RES" | grep -q 'name="android.permission.INTERACT_ACROSS_USERS_FULL" granted="true"'; then
      PATCH=true
    else
      PATCH=false
    fi
    if [ "$PATCH" == true ]; then
      sed -i 's|<shared-user name="oppo.uid.launcher">|\
<shared-user name="oppo.uid.launcher">\
<permission name="android.permission.INPUT_CONSUMER" granted="true" flags="0" />\
<permission name="android.permission.WRITE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.READ_WALLPAPER_INTERNAL" granted="true" flags="0" />\
<permission name="android.permission.POST_NOTIFICATIONS" granted="true" flags="0" />\
<permission name="android.permission.MODIFY_AUDIO_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.SYSTEM_ALERT_WINDOW" granted="true" flags="0" />\
<permission name="android.permission.START_TASKS_FROM_RECENTS" granted="true" flags="0" />\
<permission name="android.permission.MONITOR_INPUT" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_COMPONENT_ENABLED_STATE" granted="true" flags="0" />\
<permission name="android.permission.INTERNAL_SYSTEM_WINDOW" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACTIVITY_TASKS" granted="true" flags="0" />\
<permission name="android.permission.RECEIVE_BOOT_COMPLETED" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ROLE_HOLDERS" granted="true" flags="0" />\
<permission name="android.permission.DEVICE_POWER" granted="true" flags="0" />\
<permission name="android.permission.REMOVE_TASKS" granted="true" flags="0" />\
<permission name="android.permission.EXPAND_STATUS_BAR" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.ACTION_DEEP_PROTECT_START_APP" granted="true" flags="0" />\
<permission name="android.permission.INTERNET" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.HOTSEAT_EDU" granted="true" flags="0" />\
<permission name="android.permission.REORDER_TASKS" granted="true" flags="0" />\
<permission name="android.permission.ROTATE_SURFACE_FLINGER" granted="true" flags="0" />\
<permission name="android.permission.READ_EXTERNAL_STORAGE" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACCESSIBILITY" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.WRITE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.CONTROL_REMOTE_APP_TRANSITION_ANIMATIONS" granted="true" flags="0" />\
<permission name="android.permission.INTERACT_ACROSS_USERS_FULL" granted="true" flags="0" />\
<permission name="android.permission.BIND_APPWIDGET" granted="true" flags="0" />\
<permission name="android.permission.STOP_APP_SWITCHES" granted="true" flags="0" />\
<permission name="android.permission.WRITE_SECURE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.STATUS_BAR_SERVICE" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.READ_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.READ_PRIVILEGED_PHONE_STATE" granted="true" flags="0" />\
<permission name="android.permission.CALL_PHONE" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_IMAGES" granted="true" flags="0" />\
<permission name="android.permission.SUBSTITUTE_NOTIFICATION_APP_NAME" granted="true" flags="0" />\
<permission name="android.permission.SYSTEM_APPLICATION_OVERLAY" granted="true" flags="0" />\
<permission name="android.permission.SET_ORIENTATION" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_USERS" granted="true" flags="0" />\
<permission name="android.permission.SET_PREFERRED_APPLICATIONS" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER_COMPONENT" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_NETWORK_STATE" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_CONFIGURATION" granted="true" flags="0" />\
<permission name="android.permission.INTERACT_ACROSS_USERS" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER" granted="true" flags="0" />\
<permission name="android.permission.WAKEUP_SURFACE_FLINGER" granted="true" flags="0" />\
<permission name="android.permission.BROADCAST_CLOSE_SYSTEM_DIALOGS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_SHORTCUTS" granted="true" flags="0" />\
<permission name="android.permission.REQUEST_DELETE_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.ADD_TRUSTED_DISPLAY" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER_HINTS" granted="true" flags="0" />\
<permission name="android.permission.ALLOW_SLIPPERY_TOUCHES" granted="true" flags="0" />\
<permission name="android.permission.VIBRATE" granted="true" flags="0" />\
<permission name="android.permission.CAPTURE_BLACKOUT_CONTENT" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_APP_HIBERNATION" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACTIVITY_STACKS" granted="true" flags="0" />\
<permission name="android.permission.MODIFY_APPWIDGET_BIND_PERMISSIONS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_WIFI_STATE" granted="true" flags="0" />\
<permission name="android.permission.USE_BIOMETRIC" granted="true" flags="0" />\
<permission name="android.permission.STATUS_BAR" granted="true" flags="0" />\
<permission name="android.permission.READ_FRAME_BUFFER" granted="true" flags="0" />\
<permission name="android.permission.QUERY_ALL_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.READ_DEVICE_CONFIG" granted="true" flags="0" />\
<permission name="android.permission.UNLIMITED_TOASTS" granted="true" flags="0" />\
<permission name="android.permission.INJECT_EVENTS" granted="true" flags="0" />\
<permission name="android.permission.DELETE_PACKAGES" granted="true" flags="0" />\
</shared-user>\n<shared-user name="removed">|g' $FILE
      warning
    fi
  else
    sed -i 's|</runtime-permissions>|\
<shared-user name="oppo.uid.launcher">\
<permission name="android.permission.INPUT_CONSUMER" granted="true" flags="0" />\
<permission name="android.permission.WRITE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.READ_WALLPAPER_INTERNAL" granted="true" flags="0" />\
<permission name="android.permission.POST_NOTIFICATIONS" granted="true" flags="0" />\
<permission name="android.permission.MODIFY_AUDIO_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.SYSTEM_ALERT_WINDOW" granted="true" flags="0" />\
<permission name="android.permission.START_TASKS_FROM_RECENTS" granted="true" flags="0" />\
<permission name="android.permission.MONITOR_INPUT" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_COMPONENT_ENABLED_STATE" granted="true" flags="0" />\
<permission name="android.permission.INTERNAL_SYSTEM_WINDOW" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACTIVITY_TASKS" granted="true" flags="0" />\
<permission name="android.permission.RECEIVE_BOOT_COMPLETED" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ROLE_HOLDERS" granted="true" flags="0" />\
<permission name="android.permission.DEVICE_POWER" granted="true" flags="0" />\
<permission name="android.permission.REMOVE_TASKS" granted="true" flags="0" />\
<permission name="android.permission.EXPAND_STATUS_BAR" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.ACTION_DEEP_PROTECT_START_APP" granted="true" flags="0" />\
<permission name="android.permission.INTERNET" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.HOTSEAT_EDU" granted="true" flags="0" />\
<permission name="android.permission.REORDER_TASKS" granted="true" flags="0" />\
<permission name="android.permission.ROTATE_SURFACE_FLINGER" granted="true" flags="0" />\
<permission name="android.permission.READ_EXTERNAL_STORAGE" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACCESSIBILITY" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.WRITE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.CONTROL_REMOTE_APP_TRANSITION_ANIMATIONS" granted="true" flags="0" />\
<permission name="android.permission.INTERACT_ACROSS_USERS_FULL" granted="true" flags="0" />\
<permission name="android.permission.BIND_APPWIDGET" granted="true" flags="0" />\
<permission name="android.permission.STOP_APP_SWITCHES" granted="true" flags="0" />\
<permission name="android.permission.WRITE_SECURE_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.STATUS_BAR_SERVICE" granted="true" flags="0" />\
<permission name="com.android.launcher.permission.READ_SETTINGS" granted="true" flags="0" />\
<permission name="android.permission.READ_PRIVILEGED_PHONE_STATE" granted="true" flags="0" />\
<permission name="android.permission.CALL_PHONE" granted="true" flags="0" />\
<permission name="android.permission.READ_MEDIA_IMAGES" granted="true" flags="0" />\
<permission name="android.permission.SUBSTITUTE_NOTIFICATION_APP_NAME" granted="true" flags="0" />\
<permission name="android.permission.SYSTEM_APPLICATION_OVERLAY" granted="true" flags="0" />\
<permission name="android.permission.SET_ORIENTATION" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_USERS" granted="true" flags="0" />\
<permission name="android.permission.SET_PREFERRED_APPLICATIONS" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER_COMPONENT" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_NETWORK_STATE" granted="true" flags="0" />\
<permission name="android.permission.CHANGE_CONFIGURATION" granted="true" flags="0" />\
<permission name="android.permission.INTERACT_ACROSS_USERS" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER" granted="true" flags="0" />\
<permission name="android.permission.WAKEUP_SURFACE_FLINGER" granted="true" flags="0" />\
<permission name="android.permission.BROADCAST_CLOSE_SYSTEM_DIALOGS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_SHORTCUTS" granted="true" flags="0" />\
<permission name="android.permission.REQUEST_DELETE_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.ADD_TRUSTED_DISPLAY" granted="true" flags="0" />\
<permission name="android.permission.SET_WALLPAPER_HINTS" granted="true" flags="0" />\
<permission name="android.permission.ALLOW_SLIPPERY_TOUCHES" granted="true" flags="0" />\
<permission name="android.permission.VIBRATE" granted="true" flags="0" />\
<permission name="android.permission.CAPTURE_BLACKOUT_CONTENT" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_APP_HIBERNATION" granted="true" flags="0" />\
<permission name="android.permission.MANAGE_ACTIVITY_STACKS" granted="true" flags="0" />\
<permission name="android.permission.MODIFY_APPWIDGET_BIND_PERMISSIONS" granted="true" flags="0" />\
<permission name="android.permission.ACCESS_WIFI_STATE" granted="true" flags="0" />\
<permission name="android.permission.USE_BIOMETRIC" granted="true" flags="0" />\
<permission name="android.permission.STATUS_BAR" granted="true" flags="0" />\
<permission name="android.permission.READ_FRAME_BUFFER" granted="true" flags="0" />\
<permission name="android.permission.QUERY_ALL_PACKAGES" granted="true" flags="0" />\
<permission name="android.permission.READ_DEVICE_CONFIG" granted="true" flags="0" />\
<permission name="android.permission.UNLIMITED_TOASTS" granted="true" flags="0" />\
<permission name="android.permission.INJECT_EVENTS" granted="true" flags="0" />\
<permission name="android.permission.DELETE_PACKAGES" granted="true" flags="0" />\
</shared-user>\n</runtime-permissions>|g' $FILE
    warning_2
  fi
done
ui_print " "
}

# patch runtime-permissions.xml
if [ "$API" -lt 35 ]; then
  patch_runtime_permisions
fi







