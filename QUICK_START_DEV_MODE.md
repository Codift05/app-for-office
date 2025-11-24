# 🚀 Quick Start - Development Mode

## Cara Cepat Bypass Login

### 1️⃣ **Cara Termudah - Dev Navigation Screen**

Di file `lib/main.dart`, set:

```dart
initialRoute: '/dev',  // Buka Dev Menu
```

Kemudian run:
```bash
flutter run -d chrome
```

Akan muncul menu seperti ini:

```
🛠️ DEVELOPMENT NAVIGATION

[Authentication Screens]
→ Login Screen
→ Sign Up Screen

[Employee Screens]
→ Employee Home
→ Create Report
→ All Reports

[Cleaner Screens]
→ Cleaner Home
→ My Tasks

[Admin Screens]
→ Admin Dashboard
→ Analytics

[Shared Screens]
→ Profile
→ Settings
→ Notifications

[Inventory Screens]
→ Inventory List
```

**Tinggal klik screen yang mau diedit!** ✨

---

### 2️⃣ **Langsung ke Screen Tertentu**

Di `lib/main.dart`, uncomment route yang diinginkan:

```dart
// Pilih salah satu:
initialRoute: '/dev',                         // Dev Menu (RECOMMENDED)
// initialRoute: '/home_employee',            // Employee Home
// initialRoute: '/home_cleaner',             // Cleaner Home
// initialRoute: '/home_admin',               // Admin Dashboard
// initialRoute: '/inventory',                // Inventory
// initialRoute: '/profile',                  // Profile
```

---

## Workflow Development

1. **Set Dev Mode** di `main.dart`:
   ```dart
   initialRoute: '/dev',
   ```

2. **Run App**:
   ```bash
   flutter run -d chrome
   ```

3. **Pilih Screen** dari Dev Menu

4. **Edit Screen** yang dipilih

5. **Save** (Ctrl+S) - Hot reload otomatis!

6. **Back** ke Dev Menu untuk pilih screen lain

---

## Hot Reload Commands

```
r  = Hot reload (update UI cepat)
R  = Hot restart (restart app)
q  = Quit (keluar)
```

---

## File yang Diubah

### 1. `lib/main.dart`
```dart
// Tambahan di initialRoute:
initialRoute: '/dev',  // Development Menu

// Tambahan di routes:
'/dev': (context) => const DevNavigationScreen(),
```

### 2. `lib/screens/dev_navigation_screen.dart` ✨ [NEW]
File baru untuk menu development.

---

## Cara Login Normal (kalau perlu)

### Sistem Role Otomatis:
- Email dengan "**admin**" → Role: Admin
- Email dengan "**cleaner**" atau "**petugas**" → Role: Cleaner
- Email lainnya → Role: Employee

### Contoh:
| Email | Role |
|-------|------|
| admin@cleanoffice.com | Admin |
| cleaner@cleanoffice.com | Cleaner |
| employee@company.com | Employee |

---

## ⚠️ Sebelum Production

**Jangan lupa kembalikan ke login!**

```dart
// Di lib/main.dart
initialRoute: AppConstants.loginRoute,  // Back to login
```

---

## 🎯 Kesimpulan

✅ **Dev Mode Aktif** - Tidak perlu login!  
✅ **Bisa akses semua screen** dari Dev Menu  
✅ **Hot reload** untuk edit UI cepat  
✅ **Fokus ke frontend** tanpa repot auth  

**Happy Coding!** 🚀
