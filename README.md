# Snacks O'Clock — Food-Stall POS & Billing Application

![Flutter](https://img.shields.io/badge/Flutter-3.47.7-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.13.5-0175C2?logo=dart)
![Material 3](https://img.shields.io/badge/Material-3.0-purple)
![SQLite](https://img.shields.io/badge/SQLite-Offline--First-003B57?logo=sqlite)
![License](https://img.shields.io/badge/Status-Production--Ready-success)

**Snacks O'Clock** is a high-speed, offline-first mobile Point-of-Sale (POS) and stall management system engineered specifically for fast-paced university campus food kiosks and street food stalls.

Built with **Flutter & Dart**, the app faithfully brings the **Google Stitch** tactile culinary design to life with rich wine burgundy, warm creams, roasted espresso typography, authentic menu photography, PhonePe UPI QR verification, instant cash change calculation, SQLite sales persistence, thermal receipt printing with PDF generation, and real-time shift profit analytics.

---

## 📸 Key Features

- **⚡ Fast-Paced Ergonomic Billing:**
  - One-tap item increment/decrement with tactile stepper feedback.
  - Sticky bottom order bar and slide-up modal bottom sheet cart.
  - Addon toggling (e.g. *Extra Peri Peri Dust +₹10*), dine-in / parcel packaging indicators, and customizable discounts.
  - Instant line total and grand total computation via dedicated `BillingCalculatorService`.
- **📷 Authentic Google Stitch Visual Identity:**
  - Designed around deep wine burgundy (`#4A1521`), warm surface creams (`#FFF8F7`, `#F5E7D7`), and roasted espresso typography.
  - Authentic high-resolution photography for all 6 menu staples:
    1. **Classic Fries** — ₹70
    2. **Spring Roll** — ₹60
    3. **Cheese Fries** — ₹100
    4. **Peri Peri Fries** — ₹80
    5. **Nimbu Pani** — ₹40
    6. **Blue Lagoon** — ₹50
- **💳 Dynamic PhonePe UPI & Payment Settings:**
  - **Dynamic QR Code Management:** Upload and update custom stall QR codes from gallery/files (`PNG`, `JPG`, `JPEG`). Images are permanently stored in application documents storage (`qr_codes/`) without quality degradation or distortion (`BoxFit.contain`).
  - **Customizable UPI Details:** Configure merchant name, UPI ID (with regex format validation), and customer instructions.
  - **Safety & Fallbacks:** Seamless fallback to Stitch PhonePe defaults (`karan1513.wallet@phonepe`); clear configuration warning if QR is removed with direct settings navigation; cash billing remains 100% operational.
  - **Authentic Verification:** Operator checkbox verification ensures no fake auto-approvals.
- **💵 Cash Counter Workflow:**
  - Quick tender pills (₹50, ₹100, ₹200, ₹500), numerical keypad, and automatic surplus change calculation with insufficient tender guards.
- **🛡️ Rock-Solid SQLite Persistence:**
  - Complete offline resilience powered by atomic transactions (`db.transaction(...)`).
  - **Immutable Snapshots:** Freezes product name, unit selling price, and unit cost price into `sale_items` at transaction time, ensuring historical receipts and profit audits remain 100% accurate even if future menu prices change.
  - Sequential, gapless bill numbering (`SOC-20261023-0001`) and cycling kitchen token numbers (`#101`).
- **🧾 Thermal Digital Receipts & PDF Export:**
  - High-visibility kitchen token spotlight to call out orders.
  - Thermal receipt styling with itemized breakdowns, cashier info, and timestamps.
  - One-tap PDF generation, printing, and native Android sharing (`pdf`, `printing`, `share_plus`).
- **📊 Shift KPI Reports & Profit Analytics:**
  - Real-time gross sales, net sales, items sold, and bill counts.
  - Cash drawer reconciliation (Opening float + cash collections − expenses).
  - COGS and net margin calculations based on actual snapshot costs.
  - Bestselling product leaderboard with visual sales distribution bars.
- **📁 Historical Audit Trail & CSV Export:**
  - Search by bill number or customer name.
  - Date filtering (Today, Yesterday, Last 7 Days, Custom Date Range).
  - One-click RFC 4180 CSV export for accounting and tax records.

---

## 🏗️ Architecture & Project Structure

The project follows a clean, feature-driven architecture strictly separating UI, state management, business calculations, and database access:

```
stitch_snacks_o_clock_pos/
├── frontend/
│   └── flutter_app/          # Core Flutter Application
│       ├── android/          # Native Android build configuration
│       ├── assets/           # Real food photography, QR & icons
│       │   ├── food/         # 6 authentic food images
│       │   ├── payments/     # Real PhonePe QR asset (karan1513.wallet@phonepe)
│       │   └── images/       # Menu poster & graphics
│       ├── lib/
│       │   ├── core/         # Colors, typography, constants, formatters
│       │   ├── data/         # SQLite AppDatabase, DAOs, immutable models
│       │   ├── features/     # Dashboard, Billing, Payments, History, Reports, Settings
│       │   └── shared/       # Reusable UI widgets
│       ├── test/             # Unit tests for calculations & COGS snapshots
│       └── pubspec.yaml      # Dependencies & asset declarations
├── backend/                  # Optional cloud sync service (Node.js/Express)
│   ├── src/                  # Controllers, routes, services
│   └── package.json
├── docs/                     # Full technical specifications
│   ├── PROJECT_STRUCTURE.md  # Detailed architecture & component mapping
│   ├── UI_DESIGN_SYSTEM.md   # Colors, typography, Stitch tokens
│   ├── DATABASE_SCHEMA.md    # Tables, relationships, indexes, snapshots
│   ├── BILLING_FLOW.md       # Cashier checkout step-by-step
│   └── SETUP_GUIDE.md        # Operations & deployment guide
└── README.md
```

---

## 🚀 Getting Started

### 1. Requirements
- Flutter `3.47+` & Dart `3.13+`
- Android Studio / Android SDK (compileSdk 35) or physical Android device

### 2. Run Locally
```bash
cd frontend/flutter_app
flutter pub get
flutter run
```

### 3. Run Static Analysis & Tests
```bash
# Verify static analysis (0 errors, 0 warnings)
flutter analyze

# Run unit tests & widget test suite
flutter test
```

### 4. Build Android APK
```bash
# Build Debug APK
flutter build apk --debug

# Build Release APK
flutter build apk --release
```

Detailed setup and operational procedures are documented in [`docs/SETUP_GUIDE.md`](docs/SETUP_GUIDE.md).

---

## 🔒 Security & Offline Philosophy

- **Zero Cloud Leakage:** In accordance with the single-stall offline-first architecture, sales data is saved locally on the device in SQLite. No private customer or financial data is exposed to remote endpoints.
- **Authentic Verification:** QR payment transactions require the cashier to confirm visual verification from the PhonePe soundbox/merchant app before persisting the sale.
- **Snapshot Integrity:** Historical prices and sales records are immutable. Changing product prices in the Settings menu does not alter previously completed sales.

---

## 👥 Credits
- **UI Design:** Google Stitch POS specifications
- **Merchant VPA:** `karan1513.wallet@phonepe`
- **Engineering:** Built with Flutter, Dart, Riverpod, and SQLite
