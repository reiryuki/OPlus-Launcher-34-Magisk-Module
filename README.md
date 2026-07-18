# OPlus Launcher 34 Magisk Module

## DISCLAIMER
- OPlus apps and blobs are owned by OPlus™.
- The MIT license specified here is for the Magisk Module only, not for OPlus apps and blobs.

## Descriptions
Home launcher app by OnePlus Ltd. ported and integrated as a Magisk Module for all supported and rooted devices with Magisk

## Sources
- https://apkmirror.com com.android.launcher (target SDK 34), com.oplus.athena, & com.oplus.uxdesign by OnePlus Ltd.
- libmagiskpolicy.so: Magisk (stable) 30.7 (30700)

## Changelog

v1.5
- Android 16 support
- Add workaround to disable swipe up vibration (Read Troubleshootings below)
- Fix crash
- Fix create shortcut
- Fix getDisplay method logic
- Fix bug in cleaner.sh
- Fix selinux denial
- Prepare /storage/emulated/"$UID"/Android/data/$PKG/files and cache directories
- Update libmagiskpolicy.so from Magisk (stable) 30.7 (30700)
- Resets module folders/files permissions at post-fs-data
- Move _uninstall.log to /data/adb/logs/

v1.4
- Fix wrong target in latest KernelSU
- Fix denial if executing default.sh

v1.3
- Fix a crash

v1.2
- Disable launch on boot
- Fix permission

v1.1
- Re-fix crash NoSuchMethodError typeCasting in Bliss OS ROM
- Fix descriptors
- Re-fix conflict with PixelConfigOverlayCommon.apk

v1.0
- Fix crash AbstractMethodError setHandoffHandler
- Removes conflicted overlay PixelConfigOverlayCommon.apk systemlessly if oplus.recents=1

v0.9
- Android 15 QPR2 (BP1A) support
- Fix recents UI bug while pressing recents button from splitscreen mode
- Fix some methods

v0.8
- Fix crashes in NothingOS ROM

v0.7
- Fix crashes
- Remove conflicted classes
- Minimum SDK 34 (because it's actually doesn't work in SDK 33)
- Fix permission

v0.6
- Fix crashes
- Fix some methods
- Change module name
- Add Action button to clear apps caches
- Fix bug in uninstall.sh

## Screenshots
https://t.me/androidryukimods/2420

## Requirements
- NOT in OPlus ROM
- Android 14 (SDK 34) and up
- Magisk or Kitsune Mask or KernelSU or Apatch installed
- OPlus Core Magisk Module v0.2 or above installed https://github.com/reiryuki/OPlus-Core-Magisk-Module
- Double tap to sleep requires root permission

## Installation Guide & Download Link
- If you are using KernelSU, you need to disable Unmount Modules by Default in KernelSU app settings and install https://github.com/KernelSU-Modules-Repo/meta-overlayfs or https://github.com/KernelSU-Modules-Repo/magic_mount_rs or https://github.com/KernelSU-Modules-Repo/hybrid_mount or https://github.com/maxsteeel/nomount first depending on ROM compatibility
- Install OPlus Core Magisk Module v0.2 or above first: https://github.com/reiryuki/OPlus-Core-Magisk-Module
- If you want to activate the recents provider, READ Optionals bellow!
- Install this module https://devuploads.com/tqu32hmeja6x via Magisk app or Kitsune Mask app or KernelSU app or Apatch app or Recovery if Magisk or Kitsune Mask installed
- Reboot
- If you are using KernelSU, you need to allow superuser list manually all package name listed in package.txt (enable show system apps) and reboot afterwards
- Change your default home to this launcher via Settings app (or you can copy the content of default.sh and paste it to Terminal/Termux app. Type su and grant root first!)
- If you are using multi user or Work Profile, don't forget to allow "Display over other apps" manually at the App Info or you can run this terminal command instead:

  `su`

  `appops set com.oplus.launcher SYSTEM_ALERT_WINDOW allow`


## Optionals
- https://t.me/ryukinotes/5
- Global: https://t.me/ryukinotes/35

## Troubleshootings
- https://t.me/ryukinotes/5
- Global: https://t.me/ryukinotes/34

## Known Issues
- Full gesture navigation doesn't work
- Icons option doesn't work
- No freeform window option in the recents provider if it's activated
- Recents button doesn't work from splitscreen mode
- Does not support navbar overlay in Android 15 QPR2 ROMs and up if recents provider is activated

## Support & Bug Report
- https://t.me/ryukinotes/54
- If you don't do above, issues will be closed immediately

## Credits and Contributors
- @KaldirimMuhendisi
- https://t.me/androidryukimodsdiscussions
- https://t.me/androidappsportdevelopment

## Sponsors
https://t.me/ryukinotes/25


