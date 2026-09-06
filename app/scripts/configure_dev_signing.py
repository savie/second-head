#!/usr/bin/env python3
import re
from pathlib import Path

manifest_path = Path("android/app/src/main/AndroidManifest.xml")
manifest = manifest_path.read_text()

intent = '''        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="secondhead" />
        </intent-filter>'''

if 'android:scheme="secondhead"' not in manifest:
    activity_pattern = re.compile(r'(<activity\b[^>]*>)(.*?)(</activity>)', re.DOTALL)

    def add_callback(match):
        block = match.group(0)
        if (
            'android.intent.action.MAIN' in block
            and 'android.intent.category.LAUNCHER' in block
        ):
            return f"{match.group(1)}{match.group(2)}\n{intent}\n    {match.group(3)}"
        return block

    updated, count = activity_pattern.subn(add_callback, manifest, count=0)
    if count == 0 or updated == manifest:
        raise SystemExit("launcher activity not found")
    manifest_path.write_text(updated)

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
print("Configured SH DEV signing and secondhead auth callback scheme for debug APK.")
