# Snacks O'Clock POS — Project Structure & Implementation Plan

## 1. Project Overview & Audit Findings

"Snacks O'Clock" is a high-speed Point-of-Sale (POS) and stall management application designed for a busy university snack stall.
The visual design, color tokens, and ergonomics were exported from Google Stitch (`stitch_snacks_o_clock_pos`).

### Audited Stitch Artifacts
- **Design System Specs:** `stitch_snacks_o_clock_pos/snack_stall_pos/DESIGN.md` defining colors, typography, tactile elevation, and thumb ergonomics.
- **POS Quick Billing:** `stitch_snacks_o_clock_pos/pos_quick_billing/code.html` + `screen.png`.
- **Checkout & Payment:** `stitch_snacks_o_clock_pos/cash_phonepe_checkout/code.html` + `screen.png`.
- **Digital Receipt & WhatsApp Share:** `stitch_snacks_o_clock_pos/digital_receipt_whatsapp_share/code.html` + `screen.png`.
- **Sales History & CSV Audit:** `stitch_snacks_o_clock_pos/sales_history_csv/code.html` + `screen.png`.
- **Reports & Net Profit Intelligence:** `stitch_snacks_o_clock_pos/reports_net_profit/code.html` + `screen.png`.
- **Food Photography Assets:**
  1. Classic Fries (₹70): `stitch_snacks_o_clock_pos/close_up_delicious_golden_crispy_classic_french_fries_in_a_kraft_paper_cup_with/screen.png` (1024x1024)
  2. Spring Roll (₹60): `stitch_snacks_o_clock_pos/two_golden_crispy_vegetable_spring_rolls_cut_diagonally_on_a_sleek_dark_ceramic/screen.png` (1024x1024)
  3. Cheese Fries (₹100): `stitch_snacks_o_clock_pos/gourmet_french_fries_generously_covered_in_thick_melted_cheddar_cheese_sauce/screen.png` (1024x1024)
  4. Peri Peri Fries (₹80): `stitch_snacks_o_clock_pos/crispy_spicy_peri_peri_seasoned_french_fries_coated_in_red_chili_spice_flakes/screen.png` (1024x1024)
  5. Nimbu Pani (₹40): `stitch_snacks_o_clock_pos/chilled_indian_fresh_lime_water_shikanji_nimbu_pani_in_a_clear_tall_glass_with/screen.png` (1024x1024)
  6. Blue Lagoon (₹50): `stitch_snacks_o_clock_pos/vibrant_electric_blue_lagoon_mocktail_drink_in_a_clear_takeaway_cup_with/screen.png` (1024x1024)
- **Payment & Brand Assets:**
  - Original PhonePe Merchant QR: `stitch_snacks_o_clock_pos/walletqrcodekaran1513.wallet_phonepe_light_theme.png/screen.png` (`karan1513.wallet@phonepe`)
  - Physical Stall Menu Poster: `stitch_snacks_o_clock_pos/img_20261022_wa0008.jpg/screen.png` (1024x1535)

---

## 2. Directory Layout & Architecture

```
snacks_oclock/
├── frontend/
│   └── flutter_app/
│       ├── android/
│       ├── assets/
│       │   ├── images/
│       │   ├── food/
│       │   │   ├── classic_fries.png
│       │   │   ├── spring_roll.png
│       │   │   ├── cheese_fries.png
│       │   │   ├── peri_peri_fries.png
│       │   │   ├── nimbu_pani.png
│       │   │   └── blue_lagoon.png
│       │   ├── payments/
│       │   │   └── phonepe_qr.png
│       │   └── icons/
│       ├── lib/
│       │   ├── main.dart
│       │   ├── app.dart
│       │   ├── core/
│       │   │   ├── theme/
│       │   │   │   ├── app_colors.dart
│       │   │   │   ├── app_typography.dart
│       │   │   │   └── app_theme.dart
│       │   │   ├── constants/
│       │   │   │   └── app_constants.dart
│       │   │   ├── routing/
│       │   │   │   └── app_router.dart
│       │   │   ├── errors/
│       │   │   │   └── app_exceptions.dart
│       │   │   └── utils/
│       │   │       ├── currency_formatter.dart
│       │   │       └── date_formatter.dart
│       │   ├── shared/
│       │   │   └── widgets/
│       │   │       ├── primary_button.dart
│       │   │       ├── quantity_stepper.dart
│       │   │       └── custom_toast.dart
│       │   ├── features/
│       │   │   ├── dashboard/
│       │   │   │   ├── screens/dashboard_shell_screen.dart
│       │   │   │   ├── widgets/navigation_bar.dart
│       │   │   │   └── providers/navigation_provider.dart
│       │   │   ├── billing/
│       │   │   │   ├── screens/billing_screen.dart
│       │   │   │   ├── widgets/food_item_card.dart
│       │   │   │   ├── widgets/cart_bottom_sheet.dart
│       │   │   │   ├── widgets/sticky_cart_bar.dart
│       │   │   │   ├── models/cart_item.dart
│       │   │   │   ├── providers/cart_provider.dart
│       │   │   │   └── services/billing_calculator_service.dart
│       │   │   ├── products/
│       │   │   │   ├── models/product.dart
│       │   │   │   ├── providers/products_provider.dart
│       │   │   │   └── services/product_service.dart
│       │   │   ├── payments/
│       │   │   │   ├── screens/payment_screen.dart
│       │   │   │   ├── widgets/phonepe_qr_card.dart
│       │   │   │   ├── widgets/cash_calculator_card.dart
│       │   │   │   └── services/payment_verification_service.dart
│       │   │   ├── history/
│       │   │   │   ├── screens/history_screen.dart
│       │   │   │   ├── widgets/sale_card.dart
│       │   │   │   ├── widgets/receipt_modal.dart
│       │   │   │   ├── providers/history_provider.dart
│       │   │   │   └── services/csv_export_service.dart
│       │   │   ├── reports/
│       │   │   │   ├── screens/reports_screen.dart
│       │   │   │   ├── widgets/kpi_card.dart
│       │   │   │   ├── widgets/margin_split_bar.dart
│       │   │   │   ├── widgets/best_sellers_list.dart
│       │   │   │   ├── widgets/cash_drawer_reconciliation.dart
│       │   │   │   ├── providers/reports_provider.dart
│       │   │   │   └── services/profit_report_service.dart
│       │   │   └── settings/
│       │   │       ├── screens/settings_screen.dart
│       │   │       ├── providers/settings_provider.dart
│       │   │       └── widgets/unit_cost_editor_modal.dart
│       │   └── data/
│       │       ├── local/
│       │       │   ├── database/app_database.dart
│       │       │   ├── dao/product_dao.dart
│       │       │   ├── dao/sale_dao.dart
│       │       │   ├── dao/expense_dao.dart
│       │       │   └── dao/settings_dao.dart
│       │       ├── repositories/pos_repository.dart
│       │       └── models/sale_record.dart
│       ├── test/
│       │   ├── unit/billing_calculations_test.dart
│       │   ├── unit/profit_calculations_test.dart
│       │   └── unit/cash_change_test.dart
│       ├── pubspec.yaml
│       └── analysis_options.yaml
│
├── backend/
│   ├── src/
│   ├── package.json
│   ├── .env.example
│   └── README.md
│
├── docs/
│   ├── PROJECT_STRUCTURE.md
│   ├── UI_DESIGN_SYSTEM.md
│   ├── DATABASE_SCHEMA.md
│   ├── BILLING_FLOW.md
│   ├── API_DOCUMENTATION.md
│   └── SETUP_GUIDE.md
│
├── README.md
└── .gitignore
```

---

## 3. Screen-to-Code Mapping

| Stitch Screen & Path | Flutter Implementation File | Key Features |
|---|---|---|
| `pos_quick_billing/code.html` | `features/billing/screens/billing_screen.dart` | 2-column food touch cards, search bar, category chips, persistent sticky order bar, slide-up order breakdown drawer |
| `cash_phonepe_checkout/code.html` | `features/payments/screens/payment_screen.dart` | PhonePe QR scan card, manual verification checkbox, cash tender calculator, change return, tender pills |
| `digital_receipt_whatsapp_share/code.html` | `features/billing/screens/receipt_screen.dart` | Token spotlight (#48), thermal receipt paper container, itemized bill, payment method badge, PDF save/share, print |
| `sales_history_csv/code.html` | `features/history/screens/history_screen.dart` | Search by bill # or customer name, date filters (Today, Yesterday, Fest, Custom), receipt reprint, CSV export |
| `reports_net_profit/code.html` | `features/reports/screens/reports_screen.dart` | Gross sales, COGS, net profit %, cash drawer reconciliation, best-sellers leaderboard, export summary |
| Stall Settings & Unit Costs | `features/settings/screens/settings_screen.dart` | Unit cost adjustments, initial cash float setting, database backup, next bill counter |

---

## 4. Multi-Phase Implementation Plan

- **Phase 1: Audit & Planning (Complete):** Workspace analysis, asset verification, Stitch review, structure specification.
- **Phase 2: Project Structure & Setup:** Initialize Flutter project under `frontend/flutter_app`, set up backend skeleton under `backend/`, copy & configure real assets, setup `pubspec.yaml`, analysis options, and gitignore.
- **Phase 3: Design System Tokens & Base Widgets:** Implement `AppColors`, `AppTypography`, `AppTheme` matching Stitch `DESIGN.md`, custom steppers, tactile buttons, cards, formatters.
- **Phase 4: Static UI Screens:** Build Dashboard navigation shell, Billing screen, Checkout sheet/screen, Receipt screen, History screen, Reports screen, and Settings screen.
- **Phase 5: Business Logic & State Management:** Implement `BillingCalculatorService`, Riverpod cart provider, cash change calculations, bill number generator. Write comprehensive unit tests.
- **Phase 6: SQLite Local Persistence & Transactions:** Implement SQLite database with atomic transactions, DAOs, snapshot prices/costs, migrations, and repository layer.
- **Phase 7: PhonePe QR & Cash Payment Workflows:** Integrate real PhonePe QR image, manual verification checkbox, exact change calculation, cash tender pills, status tracking.
- **Phase 8: History, Receipts, PDF & Reports:** Search/filter history, thermal receipt view, PDF generation with `pdf`/`printing`, CSV export, profit calculation with historical COGS snapshot, cash drawer reconciliation.
- **Phase 9: Quality Assurance & Build Verification:** Run `dart format`, `flutter analyze`, `flutter test`, and build verification.
- **Phase 10: Documentation & Handover:** Finalize all documentation in `docs/` and root `README.md`.
