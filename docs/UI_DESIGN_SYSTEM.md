# Snacks O'Clock — UI Design System Specification

## 1. Brand Identity & Movement

"Snacks O'Clock" blends **Tactile Contemporary Warm Utility** with **High-Contrast Operational Ergonomics**. Designed specifically for high-velocity university snack stalls and kiosks, it pairs culinary tones of simmered wine burgundy, toasted caramel, and warm cream with oversized, grease-safe touch targets and unambiguous financial typography.

---

## 2. Color Palette & Semantic Tokens

| Token Name | Hex Code | Material 3 Role | Application |
|---|---|---|---|
| `burgundy` | `#4A1521` | `primaryContainer` | Top navigation app bar, primary checkout buttons, active cart tray |
| `burgundyDark` | `#2F020D` | `primary` | Base brand anchor, chip active borders, receipt headings |
| `burgundySurface` | `#5B202C` | `surfaceTint` | Elevated badge accents and chip fills |
| `creamBg` | `#FFF8F7` | `background` / `surface` | Main scaffold canvas, base stall workspace |
| `creamSurface` | `#FFFFFF` | `surfaceContainerLowest` | Tactile dish cards, thermal receipt stock, keypad cards |
| `creamSubtle` | `#FFF0EF` | `surfaceContainerLow` | Stepper backgrounds, tender calculation panels |
| `creamMuted` | `#FFE9E8` | `surfaceContainer` | Inactive category pills, search input background |
| `creamHigh` | `#FFE1E0` | `surfaceContainerHigh` | Counter badges, divider accents |
| `terracotta` | `#974723` | `secondary` | Category accents, item counts, secondary badges |
| `caramelAccent` | `#FF996E` | `secondaryContainer` | Active order notification dot, cart count bubble, highlights |
| `caramelWarm` | `#D97706` | `tertiary` | Order status chips, active tokens |
| `textPrimary` | `#2D1515` | `onSurface` | High-contrast roasted espresso for titles, prices, customer names |
| `textSecondary` | `#524345` | `onSurfaceVariant` | Timestamps, portion descriptions, cashier notes |
| `borderSubtle` | `#D7C1C3` | `outlineVariant` | Subtle card borders, thermal receipt tear lines |
| `borderMedium` | `#857374` | `outline` | Active input outlines, focus indicators |
| `successGreen` | `#16794A` | `tertiaryContainer` | Verified PhonePe payment pill, completed tick badge |
| `errorRed` | `#B42318` | `error` | Clear cart warnings, insufficient cash warning, deletions |
| `phonePePurple` | `#6B21A8` | Custom Accent | Official PhonePe merchant header pill and QR wrapper |

---

## 3. Typography Hierarchy

The triple-font pairing combines street food charisma with clinical transactional clarity:

- **Headlines (`Epilogue`):** Bold, welcoming geometric display typeface for stall branding, modal headers, and token spotlights (`#042`).
  - Display: 36px, Weight: 800, Letter spacing: -0.02em
  - Headline Large: 28px, Weight: 700, Letter spacing: -0.01em
  - Headline Medium: 22px, Weight: 600
  - Headline Small: 18px, Weight: 600
- **Body & Captions (`Plus Jakarta Sans`):** Warm, soft, ultra-legible under harsh outdoor sunlight.
  - Body Large: 16px, Weight: 500
  - Body Medium: 14px, Weight: 400
  - Body Small: 12px, Weight: 400
- **Numeric & Pricing (`Space Grotesk`):** Fixed-width numerical clarity to prevent cash counting mistakes during peak rushes.
  - Price Large: 24px, Weight: 700
  - Price Medium: 20px, Weight: 700
  - Label Medium: 13px, Weight: 600, Letter spacing: 0.03em
  - Label Small: 11px, Weight: 600, Letter spacing: 0.04em

---

## 4. Spacing & Shape Tokens

- **Border Radius:**
  - `radiusSm`: 8.0 (inputs, small steppers)
  - `radiusMd`: 12.0 (food cards, quick tender pills)
  - `radiusLg`: 16.0 (bottom sheet containers, modal cards)
  - `radiusXl`: 24.0 (sticky order bar, QR frame wrapper)
  - `radiusFull`: 9999.0 (status pills, category filter chips)
- **Grid Layout & Margins:**
  - Screen Margin: 16.0 (mobile), 24.0 (tablet)
  - Card Gap: 12.0 (2-column tactile food grid)
  - Touch Target Minimum: 48x48px for all steppers, checkout CTAs, and cash tender buttons.

---

## 5. Reusable Component Conventions

1. **Food Card (`FoodItemCard`):** 2-column square food thumbnail, price pill (`₹ 70`), portion subtitle, and rapid +/- quantity stepper. Highlighted with amber badge when in cart.
2. **Sticky Order Bar (`StickyCartBar`):** Pinned floating bottom banner above bottom navigation. Shows real-time item count, grand total, and one-tap checkout button.
3. **Cart Bottom Sheet (`CartBottomSheet`):** Pull-up drawer with customer name input, line-item itemization, spicy/packaging toggles, and direct Cash/UPI settlement buttons.
4. **PhonePe QR Card (`PhonePeQrCard`):** High-contrast container framing the real `karan1513.wallet@phonepe` QR code, with mandatory visual verification checklist.
5. **Cash Tender Card (`CashCalculatorCard`):** Numerical tender keypad, auto change calculator, and instant tender chips (Exact, ₹300, ₹500, ₹1000).
6. **Thermal Receipt (`ThermalReceiptWidget`):** Paper-tear decorative header and scalloped perforation bottom, itemized receipt, FSSAI notice, and PDF share/print action.
