# OPlus Launcher 34 Magisk Module

## DISCLAIMER
- OPlus apps and blobs are owned by OPlus™.
- The MIT license specified here is for the Magisk Module only, not for OPlus apps and blobs.

## Descriptions
- Home launcher app by OnePlus Ltd. ported and integrated as a Magisk Module for all supported and rooted devices with Magisk

## Sources
- https://apkmirror.com com.android.launcher (target SDK 34), com.oplus.athena, & com.oplus.uxdesign by OnePlus Ltd.
- libmagiskpolicy.so: Kitsune Mask R6687BB53

## Screenshots
- https://t.me/androidryukimods/2420

## Requirements
- NOT in OPlus ROM
- Android 14 (SDK 34) and up
- Magisk or Kitsune Mask or KernelSU or Apatch installed
- OPlus Core Magisk Module v0.2 or above installed https://github.com/reiryuki/OPlus-Core-Magisk-Module
- Full gesture navigation and double tap to sleep requires root permission (except in AOSP signatured ROM)

## Installation Guide & Download Link
- If you are using KernelSU, you need to disable Unmount Modules by Default in KernelSU app settings and install https://github.com/KernelSU-Modules-Repo/meta-overlayfs first
- Install OPlus Core Magisk Module v0.2 or above first: https://github.com/reiryuki/OPlus-Core-Magisk-Module
- If you want to activate the recents provider, READ Optionals bellow!
- Install this module https://www.pling.com/p/2181584/ via Magisk app or Kitsune Mask app or KernelSU app or Apatch app or Recovery if Magisk or Kitsune Mask installed
- Reboot
- If you are using KernelSU, you need to allow superuser list manually all package name listed in package.txt (enable show system apps) and reboot afterwards
- Change your default home to this launcher via Settings app (or you can copy the content of default.sh and paste it to Terminal/Termux app. Type su and grant root first!)
- If your device using hardware navigation bar, then run this terminal command to remove the empty space at the bottom screen:

  `su`
  
  `settings put secure settings_navigation_bar_combination 2`
  
  To reverse it back just change the value 2 to 0.
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
- The animation when opening an app looks a bit strange
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
- You can contribute ideas about this Magisk Module here: https://t.me/androidappsportdevelopment

## Sponsors
- https://t.me/ryukinotes/25


