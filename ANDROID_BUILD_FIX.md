# 🔧 Android Build Fix - November 22, 2025

## Error yang Diperbaiki

### Error 1: Desugar JDK Libs Version Mismatch
```
Dependency ':flutter_local_notifications' requires desugar_jdk_libs version to be
2.1.4 or above for :app, which is currently 2.0.4
```

**Solusi:**
File: `android/app/build.gradle.kts`
```kotlin
dependencies {
    // Sebelum: coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    // Sesudah:
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### Error 2: Gradle Kotlin Incremental Build Cache
```
IllegalArgumentException: this and base files have different roots:
C:\Users\Miftah\pub_cache\... and D:\Mobile_Developer\...
```

**Penyebab:**
- Kotlin incremental compilation cache corrupted
- Path mismatch antara pub_cache dan project directory

**Solusi:**
1. Clean build folder:
   ```powershell
   Remove-Item -Path "build" -Recurse -Force
   Remove-Item -Path "android\.gradle" -Recurse -Force
   flutter clean
   ```

2. Clean Gradle cache:
   ```powershell
   cd android
   ./gradlew clean
   cd ..
   ```

3. Rebuild:
   ```bash
   flutter pub get
   flutter run -d emulator-5554
   ```

---

## Langkah Troubleshooting Lengkap

### 1. Basic Clean
```bash
flutter clean
flutter pub get
```

### 2. Advanced Clean (jika masih error)
```powershell
# Hapus build folders
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "android\.gradle" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "android\app\build" -Recurse -Force -ErrorAction SilentlyContinue

# Flutter clean
flutter clean

# Gradle clean
cd android
./gradlew clean
cd ..

# Reinstall dependencies
flutter pub get
```

### 3. Nuclear Option (jika masih error juga)
```powershell
# Hapus semua cache
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".dart_tool" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "android\.gradle" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "android\app\build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "android\build" -Recurse -Force -ErrorAction SilentlyContinue

# Clean global Gradle cache (hati-hati, ini akan hapus semua cache Gradle)
Remove-Item -Path "$env:USERPROFILE\.gradle\caches" -Recurse -Force -ErrorAction SilentlyContinue

flutter clean
flutter pub get
```

---

## Tips Menghindari Error di Masa Depan

### 1. Selalu Update Dependencies
```bash
flutter pub upgrade --major-versions
```

### 2. Gunakan Flutter Clean Setelah Update
```bash
flutter pub upgrade
flutter clean
flutter pub get
```

### 3. Cek Compatibility
Sebelum upgrade package, cek di pub.dev untuk memastikan compatibility dengan:
- Flutter SDK version
- Android SDK version
- Kotlin version
- Gradle version

### 4. Test di Chrome Dulu
Sebelum test di Android emulator, test dulu di Chrome:
```bash
flutter run -d chrome
```
Chrome lebih cepat dan tidak ada masalah dengan Gradle.

---

## File yang Diubah

### android/app/build.gradle.kts
```diff
dependencies {
-   coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
+   coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

---

## Command Reference

### Build Commands
```bash
# Clean build
flutter clean

# Pub get
flutter pub get

# Run di Android
flutter run -d emulator-5554

# Run di Chrome (lebih cepat)
flutter run -d chrome

# Build APK
flutter build apk

# Build dengan verbose untuk debugging
flutter run -d emulator-5554 -v
```

### Gradle Commands
```bash
cd android

# Clean
./gradlew clean

# Build
./gradlew assembleDebug

# Build dengan stacktrace
./gradlew assembleDebug --stacktrace

# Build dengan info log
./gradlew assembleDebug --info

cd ..
```

### Cache Management
```powershell
# Clean Flutter cache
flutter clean

# Clean Gradle cache (di project)
Remove-Item -Path "android\.gradle" -Recurse -Force

# Clean Gradle cache (global) - HATI-HATI!
Remove-Item -Path "$env:USERPROFILE\.gradle\caches" -Recurse -Force
```

---

## Verification

Setelah fix, verifikasi dengan:

### 1. Check Build
```bash
cd android
./gradlew assembleDebug
```

### 2. Check Dependencies
```bash
flutter pub get
flutter pub deps
```

### 3. Check Doctor
```bash
flutter doctor -v
```

### 4. Test Run
```bash
flutter run -d chrome  # Test di browser dulu
flutter run -d emulator-5554  # Baru test di Android
```

---

## Common Android Build Errors

### Error: SDK Version Mismatch
```
minSdk 21 cannot be smaller than version 23
```
**Fix:** Update `android/app/build.gradle.kts`:
```kotlin
minSdk = 23
```

### Error: Java Version
```
Unsupported class file major version 61
```
**Fix:** Update Java version:
```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}
```

### Error: Gradle Version
```
Could not determine the dependencies of task ':app:compileDebugJavaWithJavac'
```
**Fix:** Update `android/gradle/wrapper/gradle-wrapper.properties`:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.11-all.zip
```

---

## Kesimpulan

✅ **Perbaikan Utama:**
- Update `desugar_jdk_libs` dari `2.0.4` ke `2.1.4`
- Clean Gradle dan Flutter cache
- Rebuild dari scratch

✅ **Best Practice:**
- Selalu test di Chrome dulu sebelum Android
- Clean cache setelah update dependencies
- Gunakan `flutter doctor` untuk check environment

⚠️ **Warning:**
- Android build lebih lama dari Chrome (3-5 menit pertama kali)
- Jangan interrupt Gradle saat building
- Pastikan emulator sudah running sebelum `flutter run`

---

**Last Updated:** 22 November 2025  
**Status:** ✅ Fixed - Ready to build on Android
