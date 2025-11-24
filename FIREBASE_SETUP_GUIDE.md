# 🔥 Firebase Configuration Guide - cleanoffice-app-d83a2

## 📝 Cara Connect ke Firebase Project Anda

Project Firebase: `cleanoffice-app-d83a2`
URL: https://console.firebase.google.com/project/cleanoffice-app-d83a2

---

## 🚀 Langkah Setup (Manual)

### **Step 1: Setup Android App**

1. **Buka Firebase Console:**
   - Go to: https://console.firebase.google.com/project/cleanoffice-app-d83a2
   - Pilih project settings (icon ⚙️)

2. **Download google-services.json:**
   - Scroll ke bagian "Your apps"
   - Pilih Android app (atau buat baru jika belum ada)
   - Package name: `com.example.aplikasi_cleanoffice`
   - Download `google-services.json`

3. **Copy ke Project:**
   - Copy file `google-services.json` ke folder:
     ```
     android/app/google-services.json
     ```
   - **Replace** file yang sudah ada

---

### **Step 2: Setup Web App**

1. **Buka Firebase Console:**
   - Go to: https://console.firebase.google.com/project/cleanoffice-app-d83a2
   - Pilih project settings (icon ⚙️)

2. **Get Web Config:**
   - Scroll ke "Your apps"
   - Pilih Web app (atau buat baru jika belum ada)
   - Copy configuration code

3. **Update firebase_options.dart:**
   - Buka file: `lib/firebase_options.dart`
   - Update bagian `web` dan `android` dengan konfigurasi dari Firebase Console

---

## 📋 Template firebase_options.dart

Setelah mendapatkan config dari Firebase Console, update file ini:

```dart
// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      // ... other platforms
    }
  }

  // UPDATE INI dengan config dari Firebase Console (Web App)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',                    // Ganti dengan API Key Anda
    appId: 'YOUR_WEB_APP_ID',                      // Ganti dengan App ID Anda
    messagingSenderId: 'YOUR_SENDER_ID',           // Ganti dengan Sender ID
    projectId: 'cleanoffice-app-d83a2',            // ✅ Ini sudah benar
    authDomain: 'cleanoffice-app-d83a2.firebaseapp.com',
    storageBucket: 'cleanoffice-app-d83a2.firebasestorage.app',
  );

  // UPDATE INI dengan config dari Firebase Console (Android App)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',                // Ganti dengan API Key Anda
    appId: 'YOUR_ANDROID_APP_ID',                  // Ganti dengan App ID Anda
    messagingSenderId: 'YOUR_SENDER_ID',           // Ganti dengan Sender ID
    projectId: 'cleanoffice-app-d83a2',            // ✅ Ini sudah benar
    storageBucket: 'cleanoffice-app-d83a2.firebasestorage.app',
  );
}
```

---

## 🔑 Cara Mendapatkan Config dari Firebase Console

### **Untuk Web:**
1. Buka: https://console.firebase.google.com/project/cleanoffice-app-d83a2/settings/general
2. Scroll ke "Your apps" → Pilih Web app
3. Klik "Config" atau "</>" icon
4. Copy semua nilai:
   - `apiKey`
   - `appId`
   - `messagingSenderId`
   - `projectId`
   - `authDomain`
   - `storageBucket`

### **Untuk Android:**
1. Buka: https://console.firebase.google.com/project/cleanoffice-app-d83a2/settings/general
2. Scroll ke "Your apps" → Pilih Android app
3. Download `google-services.json`
4. Copy nilai dari json untuk `firebase_options.dart`:
   ```json
   {
     "project_info": {
       "project_id": "cleanoffice-app-d83a2",
       "project_number": "...",
       "storage_bucket": "..."
     },
     "client": [{
       "client_info": {
         "mobilesdk_app_id": "...",  // Ini adalah appId
       },
       "api_key": [{
         "current_key": "..."  // Ini adalah apiKey
       }]
     }]
   }
   ```

---

## ✅ Enable Authentication di Firebase

Setelah config, enable authentication methods:

1. **Buka Authentication:**
   - Go to: https://console.firebase.google.com/project/cleanoffice-app-d83a2/authentication/users

2. **Enable Email/Password:**
   - Klik tab "Sign-in method"
   - Enable "Email/Password"
   - Save

3. **Buat Test Users:**
   - Klik tab "Users"
   - Klik "Add user"
   - Email: `admin@cleanoffice.com`
   - Password: (pilih password Anda, misal: `admin123`)
   - Add user

4. **Tambahkan Users Lain:**
   ```
   Email: employee@cleanoffice.com
   Password: employee123
   
   Email: cleaner@cleanoffice.com
   Password: cleaner123
   ```

---

## 🔧 Update Firestore Rules (Optional)

Jika menggunakan Firestore, update rules:

1. **Buka Firestore:**
   - Go to: https://console.firebase.google.com/project/cleanoffice-app-d83a2/firestore

2. **Update Rules:**
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Allow authenticated users to read/write
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

---

## 🎯 Testing Connection

Setelah setup, test koneksi:

### **1. Test di Chrome:**
```bash
flutter run -d chrome
```

### **2. Test Login:**
- Buka aplikasi
- Klik "Login"
- Masukkan:
  - Email: `admin@cleanoffice.com`
  - Password: `admin123`
- Klik "Login"

### **3. Check Console:**
Jika berhasil, akan muncul:
```
✅ Connected to Firebase
User logged in: admin@cleanoffice.com
```

---

## 🐛 Troubleshooting

### Error: "No Firebase App"
**Solusi:** Pastikan `firebase_options.dart` sudah diupdate dengan benar

### Error: "Invalid API Key"
**Solusi:** 
1. Check API Key di Firebase Console
2. Update di `firebase_options.dart`
3. Restart app

### Error: "User not found"
**Solusi:**
1. Buka Firebase Console → Authentication → Users
2. Tambahkan user baru
3. Enable Email/Password authentication

### Error: "Firebase: Error (auth/wrong-password)"
**Solusi:** Password salah, coba reset atau buat user baru

---

## 📚 File Checklist

Pastikan file-file ini sudah benar:

- [ ] ✅ `lib/firebase_options.dart` - Updated dengan project ID `cleanoffice-app-d83a2`
- [ ] ✅ `android/app/google-services.json` - Downloaded dari Firebase Console
- [ ] ✅ Firebase Authentication enabled (Email/Password)
- [ ] ✅ Test users sudah dibuat
- [ ] ✅ Firestore rules sudah diupdate (jika pakai Firestore)

---

## 🎉 Next Steps

Setelah Firebase connected:

1. **Test Login** dengan user yang sudah dibuat
2. **Check role** - pastikan role assignment bekerja
3. **Test di Android** - run di emulator
4. **Setup Firestore** - jika perlu database

---

## 📝 Quick Commands

```bash
# Run di Chrome
flutter run -d chrome

# Run di Android
flutter run -d emulator-5554

# Check Firebase connection
# Lihat log di console saat startup
```

---

**Last Updated:** 22 November 2025  
**Project ID:** `cleanoffice-app-d83a2`  
**Status:** ⚠️ Waiting for Firebase configuration
