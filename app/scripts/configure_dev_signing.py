#!/usr/bin/env python3
from pathlib import Path

path = Path("android/app/build.gradle.kts")
text = path.read_text()
marker = "android {"
if marker not in text:
    raise SystemExit("android block not found")
if 'create("shDev")' in text:
    raise SystemExit("SH DEV signing already configured")

signing = '''android {
    signingConfigs {
        create("shDev") {
            storeFile = file(System.getProperty("user.home") + "/.android/debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
            storeType = "PKCS12"
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("shDev")
        }
    }
'''
path.write_text(text.replace(marker, signing, 1))
print("Configured SH DEV signing for debug APK.")
