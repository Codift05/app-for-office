# 📥 Cara Download google-services.json

## 🎯 Langkah-langkah (dengan Screenshot Guide)

### **Step 1: Buka Project Settings**

Di Firebase Console yang sudah terbuka:
1. **Klik icon ⚙️ (gear/roda gigi)** di sebelah kiri atas, samping "Project Overview"
2. Pilih **"Project settings"**

---

### **Step 2: Cek Apakah Sudah Ada Android App**

Di halaman Project Settings:

1. **Scroll ke bawah** sampai bagian **"Your apps"**
2. **Lihat apakah ada icon Android (robot hijau)**
   
   **JIKA ADA Android App:**
   - ✅ Lanjut ke Step 3
   
   **JIKA BELUM ADA Android App:**
   - ⚠️ Perlu tambah dulu, lanjut ke Step 2B

---

### **Step 2B: Tambah Android App (Jika Belum Ada)**

Jika belum ada Android app:

1. **Klik tombol "+ Add app"** atau icon Android
2. **Pilih Android (icon robot)**
3. **Isi form:**
   ```
   Android package name: com.example.aplikasi_cleanoffice
   App nickname (optional): Clean Office App
   Debug signing certificate (optional): [kosongkan dulu]
   ```
4. **Klik "Register app"**
5. **Tunggu proses selesai**

---

### **Step 3: Download google-services.json**

Sekarang download file konfigurasi:

**Opsi A: Dari Project Settings**
1. Di bagian "Your apps"
2. Cari **Android app** (icon robot hijau)
3. Klik **icon "⚙️" di sebelah kanan app**
4. **Scroll ke bawah**
5. Lihat bagian **"SDK setup and configuration"**
6. Klik tombol **"google-services.json"** (tombol biru/download)
7. **File akan terdownload** ke folder Downloads

**Opsi B: Dari Dashboard**
1. Jika baru register app, akan langsung muncul halaman download
2. Klik tombol **"Download google-services.json"**

---

### **Step 4: Copy File ke Project**

Setelah file terdownload:

1. **Buka folder Downloads** di komputer Anda
2. **Cari file:** `google-services.json`
3. **Copy file tersebut**
4. **Paste ke folder project:**
   ```
   D:\Mobile_Developer\Aplikasi-CleanOffice-main\android\app\
   ```
5. **Replace** file yang sudah ada (jika ada)

---

## 📸 Visual Guide - Apa yang Dicari

### Di Project Settings:
```
Project settings
├─ General
│  ├─ Public-facing name: cleanoffice-app
│  ├─ Project ID: cleanoffice-app-d83a2
│  └─ Web API Key: AIza...
│
└─ Your apps
   ├─ 🌐 Web app: aplikasi_cleanoffice (web)
   ├─ 🤖 Android app: aplikasi_cleanoffice (android)  ← CARI INI
   │    └─ ⚙️ (settings icon) ← KLIK INI
   │         └─ google-services.json ← DOWNLOAD INI
   └─ + Add app
```

---

## 🔍 Cara Cek Package Name

Buka file: `android/app/build.gradle.kts`

Cari baris:
```kotlin
namespace = "com.example.aplikasi_cleanoffice"  // ← INI PACKAGE NAME
```

Atau buka: `android/app/src/main/AndroidManifest.xml`
```xml
<manifest xmlns:android="..."
    package="com.example.aplikasi_cleanoffice">  <!-- INI -->
```

---

## ✅ Verifikasi File

Setelah copy, check apakah file ada:

**Lokasi yang benar:**
```
📁 Aplikasi-CleanOffice-main
└─ 📁 android
   └─ 📁 app
      └─ 📄 google-services.json  ← HARUS ADA DI SINI
```

**Isi file harus seperti ini:**
```json
{
  "project_info": {
    "project_number": "...",
    "project_id": "cleanoffice-app-d83a2",  ← CHECK INI
    "storage_bucket": "cleanoffice-app-d83a2..."
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:...",
        "android_client_info": {
          "package_name": "com.example.aplikasi_cleanoffice"
        }
      }
    }
  ]
}
```

---

## 🆘 Troubleshooting

### Tidak ada tombol download
**Solusi:** Klik icon ⚙️ di sebelah Android app → scroll ke "SDK setup"

### File tidak muncul di Downloads
**Solusi:** Check folder Downloads atau coba download ulang

### Ada multiple Android apps
**Solusi:** Pilih yang package name-nya: `com.example.aplikasi_cleanoffice`

### Error "Package name doesn't match"
**Solusi:** 
1. Check package name di `android/app/build.gradle.kts`
2. Register ulang dengan package name yang benar

---

## 📝 Checklist

Pastikan sudah:
- [ ] ✅ Buka Firebase Console
- [ ] ✅ Masuk ke Project Settings (icon ⚙️)
- [ ] ✅ Lihat bagian "Your apps"
- [ ] ✅ Ada Android app dengan package: `com.example.aplikasi_cleanoffice`
- [ ] ✅ Download `google-services.json`
- [ ] ✅ Copy ke folder: `android/app/`
- [ ] ✅ Verify file contains project_id: `cleanoffice-app-d83a2`

---

## 🎯 Next Step

Setelah file `google-services.json` sudah di folder `android/app/`:

**Langkah selanjutnya adalah update `firebase_options.dart`**

Saya akan buatkan script otomatis untuk extract config dari `google-services.json` dan update `firebase_options.dart`.

---

**Butuh bantuan?** Reply dengan screenshot jika ada kesulitan!
