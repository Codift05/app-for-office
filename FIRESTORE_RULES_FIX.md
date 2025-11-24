# 🔥 Update Firestore Rules - PENTING!

## ⚠️ Masalah: "Network error" atau "Permission denied"

Ini terjadi karena Firestore rules di Firebase Console terlalu ketat atau belum diset.

---

## 🚀 Cara Update Firestore Rules

### **Step 1: Buka Firestore di Firebase Console**

1. **Buka link ini:**
   https://console.firebase.google.com/project/cleanoffice-app-d83a2/firestore

2. **Klik tab "Rules"** di bagian atas

---

### **Step 2: Copy Paste Rules Testing (Sementara)**

**HAPUS semua isi rules yang ada**, lalu paste rules ini:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // TEMPORARY - Allow all authenticated users (untuk testing login)
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Klik "Publish"** atau "Simpan"

---

### **Step 3: Test Login Lagi**

Setelah rules dipublish, coba login lagi di aplikasi:
- Email: `admin@cleanoffice.com`
- Password: `admin123`

Sekarang harusnya bisa login tanpa network error!

---

## 📋 Rules Production (Nanti Setelah Testing Berhasil)

Setelah login berhasil, ganti dengan rules yang lebih aman:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      // User bisa create profile sendiri saat login pertama
      allow create: if request.auth != null && request.auth.uid == userId;
      
      // User bisa read/write data mereka sendiri
      allow read, update: if request.auth != null && request.auth.uid == userId;
      
      // Admin bisa read semua users
      allow read: if request.auth != null &&
                     exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Reports collection
    match /reports/{reportId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && 
                               resource.data.userId == request.auth.uid;
    }
    
    // Requests collection
    match /requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null &&
                       request.resource.data.userId == request.auth.uid;
      allow update: if request.auth != null;
    }
    
    // Inventory collection
    match /inventory/{itemId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null &&
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Stock requests
    match /stockRequests/{requestId} {
      allow read, create: if request.auth != null;
      allow update: if request.auth != null;
    }
    
    // Notifications
    match /notifications/{notificationId} {
      allow read: if request.auth != null &&
                     resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
                       resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## 🎯 Checklist

- [ ] ✅ Buka Firestore Console: https://console.firebase.google.com/project/cleanoffice-app-d83a2/firestore
- [ ] ✅ Klik tab "Rules"
- [ ] ✅ Hapus rules lama
- [ ] ✅ Paste rules testing (yang singkat)
- [ ] ✅ Klik "Publish"
- [ ] ✅ Test login di aplikasi
- [ ] ✅ Jika berhasil, ganti dengan rules production

---

## 🐛 Troubleshooting

### Masih error "Permission denied"
**Solusi:** Tunggu 1-2 menit setelah publish rules, lalu coba lagi

### Error "Network error"
**Solusi:** 
1. Pastikan Authentication sudah enabled
2. Pastikan user sudah dibuat di Firebase Console
3. Restart aplikasi

### Login berhasil tapi crash
**Solusi:** Check console log, mungkin ada field yang missing di user profile

---

**PENTING:** Rules testing di atas **TIDAK AMAN** untuk production. Gunakan hanya untuk testing, lalu ganti dengan rules production setelah semua fitur tested!
