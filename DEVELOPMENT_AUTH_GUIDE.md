# 🔐 Panduan Authentikasi & Development Mode

## 📋 Daftar Isi
1. [Cara Login Normal](#cara-login-normal)
2. [Bypass Login untuk Development](#bypass-login-development)
3. [Tips Development Frontend](#tips-development)

---

## 🔒 Cara Login Normal (dengan Firebase)

### Sistem Authentikasi
Aplikasi ini menggunakan **Firebase Authentication** dengan email/password.

### Role Assignment Otomatis
Role ditentukan berdasarkan email saat pertama kali login:

```dart
// Di login_screen.dart, baris 38-45
String role = 'employee';  // Default role

if (user.email?.contains('admin') == true) {
  role = 'admin';
} else if (user.email?.contains('cleaner') == true || 
           user.email?.contains('petugas') == true) {
  role = 'cleaner';
}
```

### Contoh Email & Role:
| Email | Role | Home Screen |
|-------|------|-------------|
| `admin@cleanoffice.com` | admin | Admin Dashboard |
| `cleaner@cleanoffice.com` | cleaner | Cleaner Home |
| `petugas@cleanoffice.com` | cleaner | Cleaner Home |
| `employee@cleanoffice.com` | employee | Employee Home |
| `john.doe@company.com` | employee | Employee Home |

### Routing Berdasarkan Role:
```dart
// Di login_screen.dart, baris 103-112
switch (userRole) {
  case 'admin':
    route = AppConstants.homeAdminRoute;      // '/home_admin'
    break;
  case 'cleaner':
    route = AppConstants.homeCleanerRoute;    // '/home_cleaner'
    break;
  default:
    route = AppConstants.homeEmployeeRoute;   // '/home_employee'
}
```

---

## 🚀 Bypass Login untuk Development

### **Metode 1: Dev Navigation Screen** ⭐ (RECOMMENDED)

Screen khusus untuk navigasi ke semua screen tanpa login.

#### Setup:
Di `lib/main.dart`, set:
```dart
initialRoute: '/dev',  // Development Navigation Menu
```

#### Fitur:
- ✅ Menu navigasi ke semua screen
- ✅ Categorized by role (Admin, Employee, Cleaner)
- ✅ Visual dan mudah digunakan
- ✅ Tidak perlu edit code berkali-kali
- ✅ Warning development mode

#### Tampilan:
```
🛠️ DEVELOPMENT NAVIGATION
├─ Authentication Screens
│  ├─ Login Screen
│  └─ Sign Up Screen
├─ Employee Screens
│  ├─ Employee Home
│  ├─ Create Report
│  ├─ All Reports
│  └─ Create Request
├─ Cleaner Screens
│  ├─ Cleaner Home
│  ├─ My Tasks
│  └─ Pending Reports
├─ Admin Screens
│  ├─ Admin Dashboard
│  ├─ Analytics
│  └─ Reports Management
├─ Shared Screens
│  ├─ Profile
│  ├─ Settings
│  └─ Notifications
└─ Inventory Screens
   ├─ Inventory List
   └─ Inventory Dashboard
```

---

### **Metode 2: Direct Route**

Langsung masuk ke screen tertentu.

#### Setup:
Di `lib/main.dart`, uncomment route yang diinginkan:

```dart
// PILIH SALAH SATU:

initialRoute: '/dev',                            // Dev Menu
// initialRoute: AppConstants.loginRoute,        // Login Screen
// initialRoute: AppConstants.homeEmployeeRoute, // Employee Home
// initialRoute: AppConstants.homeCleanerRoute,  // Cleaner Home  
// initialRoute: AppConstants.homeAdminRoute,    // Admin Dashboard
// initialRoute: '/inventory',                   // Inventory
// initialRoute: '/profile',                     // Profile
```

#### Kapan Menggunakan:
- Testing satu screen spesifik
- Rapid iteration pada UI
- Testing navigation dari screen tertentu

---

### **Metode 3: Mock Auth (Manual)**

Buat custom auth provider untuk testing.

#### File: `lib/providers/mock_auth_provider.dart`
```dart
// Contoh implementasi (tidak included, buat jika diperlukan)
class MockAuthProvider {
  UserProfile getMockUser(String role) {
    return UserProfile(
      uid: 'mock-uid-123',
      email: 'mock@test.com',
      displayName: 'Mock User',
      role: role, // 'admin', 'cleaner', 'employee'
      status: 'active',
      joinDate: DateTime.now(),
    );
  }
}
```

---

## 💡 Tips Development Frontend

### 1. **Hot Reload**
Gunakan hot reload untuk perubahan UI cepat:
```
r  = Hot reload (update UI)
R  = Hot restart (restart app)
q  = Quit
```

### 2. **Disable Firebase (Opsional)**
Jika tidak butuh data Firebase, comment firebase initialization di `main.dart`:

```dart
// await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,
// );
```

**⚠️ Warning:** Beberapa screen akan error jika Firebase disabled.

### 3. **Firebase Emulator Mode**
Untuk testing tanpa production data, enable emulator di `main.dart`:

```dart
if (kDebugMode) {
  try {
    final emulatorHost = '127.0.0.1';
    
    await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
    await FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
    
    debugPrint('✅ Connected to Firebase Emulators');
  } catch (e) {
    debugPrint('⚠️ Failed to connect to emulators: $e');
  }
}
```

**Cara jalankan emulator:**
```bash
firebase emulators:start
```

### 4. **Mock Data**
Ada seed data service di `lib/services/seed_data_service.dart` untuk testing dengan data dummy.

### 5. **Comment Out Firebase Calls**
Jika screen specific error karena Firebase, comment Firebase calls:

```dart
// final userDoc = await FirebaseFirestore.instance
//   .collection('users')
//   .doc(uid)
//   .get();

// Ganti dengan mock data:
final userData = {
  'role': 'employee',
  'displayName': 'Test User',
  'email': 'test@test.com',
};
```

---

## 📱 Testing di Platform Berbeda

### Chrome (Web)
```bash
flutter run -d chrome
```
✅ Best untuk frontend development
✅ Hot reload tercepat
✅ Dev tools di browser

### Windows Desktop
```bash
flutter run -d windows
```
✅ Native performance
✅ Testing desktop layout
⚠️ Compile lebih lama

### Android Emulator
```bash
flutter run -d emulator-5554
```
✅ Testing mobile layout
✅ Testing gestures
⚠️ Butuh Android Studio

---

## 🔄 Workflow Development

### Recommended Workflow:

1. **Set Dev Mode:**
   ```dart
   initialRoute: '/dev',  // di main.dart
   ```

2. **Run App:**
   ```bash
   flutter run -d chrome
   ```

3. **Navigate ke Screen:**
   - Buka Dev Navigation Menu
   - Tap screen yang mau di-edit
   - Mulai edit UI

4. **Edit & Test:**
   - Edit file screen
   - Save (Ctrl+S)
   - Hot reload otomatis (atau tekan `r`)
   - Lihat perubahan di browser

5. **Back to Dev Menu:**
   - Klik back button
   - Pilih screen lain untuk testing

---

## 🎯 Skenario Development

### Skenario 1: Edit UI Employee Home
```dart
// 1. Set di main.dart
initialRoute: '/dev',

// 2. Run
flutter run -d chrome

// 3. Di Dev Menu, tap "Employee Home"

// 4. Edit file:
// lib/screens/employee/employee_home_screen.dart

// 5. Save dan lihat perubahan (hot reload otomatis)
```

### Skenario 2: Testing Navigation Flow
```dart
// 1. Set initial screen
initialRoute: AppConstants.homeEmployeeRoute,

// 2. Test navigation dari screen tersebut
// 3. Edit routing jika ada masalah
```

### Skenario 3: Edit Widget Shared
```dart
// 1. Set dev mode
initialRoute: '/dev',

// 2. Test widget di berbagai screen
//    - Employee Home
//    - Admin Dashboard
//    - Profile

// 3. Edit widget shared:
// lib/widgets/shared/custom_app_bar.dart

// 4. Check konsistensi di semua screen
```

---

## ⚠️ Important Notes

### Jangan Lupa:
1. ❌ **Jangan commit** dengan `initialRoute: '/dev'`
2. ❌ **Jangan deploy** dengan dev mode enabled
3. ✅ **Selalu test** dengan login normal sebelum production
4. ✅ **Comment** Firebase calls jika tidak digunakan

### Before Production:
```dart
// Set back to login
initialRoute: AppConstants.loginRoute,

// Enable Firebase
await Firebase.initializeApp(...);

// Disable dev route (optional - remove from routes)
// '/dev': (context) => const DevNavigationScreen(),
```

---

## 📚 File Locations

| File | Path | Fungsi |
|------|------|--------|
| Main Entry | `lib/main.dart` | App initialization & routing |
| Dev Menu | `lib/screens/dev_navigation_screen.dart` | Dev navigation screen |
| Login | `lib/screens/auth/login_screen.dart` | Login logic & role detection |
| Auth Service | `lib/services/auth_service.dart` | Firebase auth methods |
| Routes | `lib/core/constants/app_constants.dart` | Route constants |

---

## 🆘 Troubleshooting

### Screen Error "User not found"
**Solusi:** Comment Firebase calls atau gunakan mock data

### Navigation tidak jalan
**Solusi:** Check route definition di `main.dart`

### Hot reload tidak jalan
**Solusi:** 
- Tekan `R` (hot restart)
- Stop dan `flutter run` lagi

### Firebase connection error
**Solusi:**
- Comment Firebase initialization
- Atau gunakan emulator mode

---

## 🎨 Happy Coding!

Dengan dev mode ini, Anda bisa fokus edit frontend tanpa repot dengan authentikasi! 🚀

**Quick Start:**
```bash
# 1. Set dev mode
# di main.dart: initialRoute: '/dev',

# 2. Run
flutter run -d chrome

# 3. Pilih screen dari menu
# 4. Edit dan hot reload!
```

---

**Last Updated:** 20 November 2025  
**Author:** GitHub Copilot Assistant
