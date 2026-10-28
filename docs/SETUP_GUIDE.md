# Snacks O'Clock — Setup & Operations Guide

This guide provides complete instructions for developers, QA engineers, and food-stall operators to install, build, run, test, and manage the **Snacks O'Clock POS** Flutter application on Android, desktop workstations, and optional cloud environments.

---

## 1. Prerequisites & Environment

### Mobile Application (Frontend)
- **Flutter SDK:** Version `3.47.x` or higher (Channel: stable)
- **Dart SDK:** Version `3.13.x` or higher
- **Java Development Kit (JDK):** JDK 17 or JDK 21 (required by Android Gradle Plugin 8.x)
- **Android SDK & Build Tools:**
  - `compileSdkVersion`: 35
  - `targetSdkVersion`: 35
  - `minSdkVersion`: 21 (Android 5.0 Lollipop+)
- **Device / Simulator:**
  - Any Android phone or tablet (e.g., Samsung Galaxy Tab, Redmi, Pixel) with USB debugging enabled.
  - Or an Android Emulator via Android Studio (API 31+ recommended).
  - Also runs natively on Windows/macOS/Linux via `sqflite_common_ffi` for rapid desktop testing.

### Optional Cloud Sync Backend
- **Node.js:** v18.x or v20.x LTS
- **npm / pnpm:** v9+
- **Database:** PostgreSQL v15+ (if enabling multi-stall centralized aggregation)

---

## 2. Project Directory Layout

```
snacks_oclock/
├── frontend/
│   └── flutter_app/          # Production Flutter POS Application
│       ├── android/          # Android Native Project & Gradle build files
│       ├── assets/           # Real food photography, PhonePe QR & UI assets
│       │   ├── food/         # 6 high-res food images (₹40 - ₹100)
│       │   ├── payments/     # karan1513.wallet@phonepe authentic QR asset
│       │   └── images/       # Menu poster & logos
│       ├── lib/              # Modular Clean Architecture source code
│       │   ├── core/         # Theme tokens, typography, currency formatters
│       │   ├── data/         # SQLite DB, DAOs, immutable models, atomic transactions
│       │   ├── features/     # Dashboard, Billing, Payments, History, Reports, Settings
│       │   └── shared/       # Tactile primary buttons, quantity steppers
│       ├── test/             # Unit tests (calculations, COGS snapshots) & widget tests
│       └── pubspec.yaml      # Dependencies & asset declarations
├── backend/                  # Optional cloud sync service (Express + TypeScript)
│   ├── src/                  # Routes, controllers, services, repositories
│   └── package.json          # Node dependencies
├── docs/                     # Architectural manifests & operational guides
│   ├── PROJECT_STRUCTURE.md  # Detailed component mapping
│   ├── UI_DESIGN_SYSTEM.md   # Colors, typography, Stitch tokens
│   ├── DATABASE_SCHEMA.md    # SQLite tables, indexes, snapshots
│   ├── BILLING_FLOW.md       # Step-by-step cashier checkout workflow
│   └── SETUP_GUIDE.md        # This operations & maintenance manual
└── README.md                 # Project root overview
```

---

## 3. Quick Start (Development & Local Run)

### Step 1: Open the Flutter Workspace
Open a terminal and navigate to the Flutter project folder:
```bash
cd frontend/flutter_app
```

### Step 2: Fetch Dependencies
```bash
flutter pub get
```

### Step 3: Run Static Analysis
Ensure code quality and zero analyzer errors:
```bash
flutter analyze
```

### Step 4: Run the Test Suite
Verify that billing calculations, cash change logic, and COGS snapshots execute flawlessly:
```bash
flutter test
```

### Step 5: Launch the Application
- **On Connected Android Phone / Tablet:**
  ```bash
  flutter run -d <device-id>
  ```
- **On Windows Workstation (Local POS Terminal):**
  ```bash
  flutter run -d windows
  ```

---

## 4. Building the Android Production APK

To generate an optimized APK for installation on the stall's Android tablet or cashier phone:

### Debug APK (Quick Testing / Sideloading):
```bash
cd frontend/flutter_app
flutter build apk --debug
```
*Output location:* `frontend/flutter_app/build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (Optimized for Daily Operations):
```bash
cd frontend/flutter_app
flutter build apk --release
```
*Output location:* `frontend/flutter_app/build/app/outputs/flutter-apk/app-release.apk`

### Installing directly onto an Android device via ADB:
```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## 5. Daily Food Stall Operations

### A. Opening the Stall (Morning Checklist)
1. Turn on the POS tablet and open **Snacks O'Clock**.
2. Tap the **Settings** icon in the bottom navigation bar or top app bar.
3. Verify or enter the **Active Cashier Name** (e.g., `Chef Karan`).
4. Set the **Opening Cash Drawer Float** (e.g., `₹1500.00`).
5. Open **Payment & UPI Settings**:
   - Check the **Stall UPI ID** and **Merchant Name**.
   - Review or upload/change the stall **QR Code** from Android Gallery or Files (`PNG`, `JPG`, `JPEG`).
   - The selected QR is permanently copied into application documents storage (`qr_codes/`) and previewed with aspect-ratio protection (`BoxFit.contain`).
6. Tap **Save Changes** and return to the **Billing POS** screen.

### B. Fast Billing Workflow
1. Tap any food card (e.g., **Classic Fries**, **Cheese Fries**, **Blue Lagoon**) to add to the cart.
2. Use the **+ / −** controls on the cards or inside the slide-up bill bottom sheet to adjust quantities.
3. Toggle **Extra Peri Dust (+₹10)** or **Takeaway / Parcel** if requested by the customer.
4. If the customer provided their name, enter it in the **Customer Name** field.
5. Tap **Cash Counter** (for cash payments) or **Pay via PhonePe** (for QR payments).

### C. Dynamic PhonePe / UPI Payment Verification
1. The **PhonePe QR Screen** dynamically loads the currently configured QR code, merchant name, and UPI ID from SQLite settings.
2. If no QR is configured (or if the QR was removed), a warning card appears with an **Open Payment Settings** shortcut, preventing unverified UPI checkout while keeping cash payments fully functional.
3. The customer scans the displayed QR code and pays the exact grand total. Cashiers can also tap the UPI ID to copy it to clipboard.
4. The cashier observes payment confirmation on the stall's PhonePe soundbox, SMS, or merchant app.
5. The cashier checks the mandatory verification checkbox:
   `[✓] I have verified the payment notification in the PhonePe Merchant app.`
6. The **Confirm & Settle** button unlocks. Tapping it saves the transaction atomically to SQLite.
7. The app displays the thermal receipt screen with a large **Token Spotlight** to announce to the kitchen!

### D. Cash Tender & Change Calculator
1. Select the **Cash Counter** tab.
2. Tap quick denomination pills (**₹50, ₹100, ₹200, ₹500**) or enter the exact amount handed over by the customer.
3. The app instantly calculates the change due in high-contrast green.
4. Tapping **Complete & Save Order** records the sale and prints or shares the receipt.

### E. End of Day Closing Summary
1. Navigate to the **Reports** tab from the bottom navigation bar.
2. Select **Live Shift Today**.
3. Inspect:
   - **Gross Sales** and **Net Sales**
   - **Cash Drawer Total** (Opening Float + Cash Collected − Cash Expenses)
   - **PhonePe UPI Bank Inflow**
   - **Cost of Goods Sold (COGS)** and **Estimated Net Profit**
   - **Bestselling Snack Leaderboard**
4. Tap **Export CSV** in the History tab to backup all today's transactions for accounting.

---

## 6. Data Backup & Recovery Strategy

The Snacks O'Clock app operates completely offline without needing an active internet connection.

### Local SQLite Storage Location:
- **Android:** `/data/data/com.example.flutter_app/databases/snacks_oclock.db`
- **Windows:** `%APPDATA%\Roaming\com.example\flutter_app\snacks_oclock.db`

### Backup Strategy:
1. **One-Tap CSV Audit Trail:**
   Open the **Sales History** screen and tap **Export CSV**. The app generates an RFC 4180-compliant CSV report containing full bill breakdowns, timestamps, items, and cost snapshots, which can be sent via WhatsApp, Google Drive, or email via the Android share sheet.
2. **Database File Backup:**
   Using Android File Transfer or ADB, operators can pull `snacks_oclock.db` directly:
   ```bash
   adb exec-out run-as com.example.flutter_app cat databases/snacks_oclock.db > backup_snacks_oclock.db
   ```

---

## 7. Optional Cloud Sync Backend Setup

If multi-terminal sync or a centralized owner dashboard is needed in the future, the included Node.js / TypeScript backend skeleton in `backend/` is ready:

```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your PostgreSQL credentials
npm run dev
```

API documentation is located in `backend/README.md`.
