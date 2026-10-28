---
name: Snack Stall POS
colors:
  surface: '#fff8f7'
  surface-dim: '#fccfce'
  surface-bright: '#fff8f7'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fff0ef'
  surface-container: '#ffe9e8'
  surface-container-high: '#ffe1e0'
  surface-container-highest: '#ffdad8'
  on-surface: '#2d1515'
  on-surface-variant: '#524345'
  inverse-surface: '#452929'
  inverse-on-surface: '#ffedeb'
  outline: '#857374'
  outline-variant: '#d7c1c3'
  surface-tint: '#8d4a56'
  primary: '#2f020d'
  on-primary: '#ffffff'
  primary-container: '#4a1521'
  on-primary-container: '#c57985'
  inverse-primary: '#ffb2bd'
  secondary: '#974723'
  on-secondary: '#ffffff'
  secondary-container: '#ff996e'
  on-secondary-container: '#772f0d'
  tertiary: '#230e00'
  on-tertiary: '#ffffff'
  tertiary-container: '#411f00'
  on-tertiary-container: '#d77604'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffd9dd'
  primary-fixed-dim: '#ffb2bd'
  on-primary-fixed: '#3a0815'
  on-primary-fixed-variant: '#71333f'
  secondary-fixed: '#ffdbce'
  secondary-fixed-dim: '#ffb598'
  on-secondary-fixed: '#370e00'
  on-secondary-fixed-variant: '#79310e'
  tertiary-fixed: '#ffdcc3'
  tertiary-fixed-dim: '#ffb77d'
  on-tertiary-fixed: '#2f1500'
  on-tertiary-fixed-variant: '#6e3900'
  background: '#fff8f7'
  on-background: '#2d1515'
  surface-variant: '#ffdad8'
typography:
  display:
    fontFamily: Epilogue
    fontSize: 40px
    fontWeight: '800'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Epilogue
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Epilogue
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Epilogue
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Epilogue
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  numeric-keypad:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: 0.02em
  currency-price:
    fontFamily: Space Grotesk
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 24px
    letterSpacing: -0.01em
  label-md:
    fontFamily: Space Grotesk
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.03em
  label-sm:
    fontFamily: Space Grotesk
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1.5rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1.25rem
  space-xl: 2rem
---

## Brand & Style

This design system is engineered for busy food stalls, kiosks, and counter-service street snack vendors operating in dynamic outdoor and fast-paced environments. The brand personality is warm, appetizing, and approachable, balanced with the razor-sharp efficiency demanded by point-of-sale workflows.

The design movement blends **Tactile / Contemporary Warm Utility** with **High-Contrast Operational Ergonomics**:
- **Tactile warmth:** Rich, culinary tones of simmered burgundy, toasted caramel, and warm cream mimic gourmet street food packaging, comforting diners while giving operators an inviting interface.
- **Sunlight-optimized contrast:** High-contrast text, clear boundary borders, and punchy status pills guarantee rapid visibility during bright midday sunlight across mobile screens and tablet counters.
- **Thumb-first physical ergonomics:** Large tap surfaces, physical-style press states, and bold numeric keypads accommodate high-velocity one-handed ordering, grease-safe tap targets, and rapid bill settlement without mis-clicks.

## Colors

The palette draws directly from the warm culinary ambience of freshly fried snacks, artisanal spices, and cafe-style stall identity:

- **Primary (`#4A1521` - Deep Wine Burgundy):** Serves as the anchor color for dominant navigation bars, primary POS checkout triggers, receipt summaries, and active states. A deeper tone (`#300A14`) is used for active tap states and top headers.
- **Secondary (`#C86D46` - Terracotta Spice):** Used for item categories, sub-actions, add-on chips, and item quantity increments.
- **Tertiary (`#D97706` - Warm Caramel Amber):** High-energy highlight tone applied to active pending orders, payment method toggles (e.g., PhonePe UPI badge indicators), and promotional badge highlights.
- **Neutral (`#2B1313` - Roasted Espresso Brown):** Provides supreme typographic legibility and deep contrast against light card containers, avoiding the sterile harshness of pitch black.
- **Surfaces & Canvases:**
  - Base canvas: `#FDF8F2` (Warm Milk Cream) with `#F8EFE4` (Toasted Latte) for secondary background sections and inactive shelf tiers.
  - Card containers: `#FFFFFF` (Pure Bright White) and `#FFF9F5` (Warm Cream White) for clear visual separation in direct sunlight.
- **Semantic Accents:** Success payments use `#1E6B37` (Herb Green); cancellation or refunds use `#8B2635` (Crimson Wine).

## Typography

The typography pairings merge the charismatic, bold appetites of street food branding with clinical computational legibility for pricing and quick order tallying:

- **Headlines (Epilogue):** An expressive geometric sans with subtle artisanal personality. Weights 700 and 800 convey stall branding, order totals, and modal titles with welcoming authority.
- **Body Text (Plus Jakarta Sans):** Highly approachable, soft, and readable at quick glances under variable ambient lighting. Used for order lists, modifier notes ("Extra peri-peri", "No ice"), and customer details.
- **Data & Pricing (Space Grotesk):** Fixed-width tendencies and crisp numerical forms make currency amounts (`₹ 70`, `₹ 100`), order ticket tokens (`#042`), and POS keypad inputs unshakeably legible, reducing transaction misreads during rush hours.

## Layout & Spacing

The layout is built around a split operational workflow: **Item Grid Navigation** and **Sticky Ticket Cart/Settlement**.

- **Handheld Mobile (< 640px):** 
  - Single column with fixed bottom order bar showing real-time item count and total bill.
  - A bottom sheet pulls up the order breakdown and UPI QR modal.
  - Margin is tightened to `1rem` with `0.75rem` gutters to maximize screen space for food touch cards.
- **Tablet / Counter POS (768px - 1024px+):**
  - Two-pane layout: 65% grid on the left for menu categories and snack cards (2 to 3 columns); 35% fixed column on the right for current ticket, modifiers, quick discounts, and prominent PhonePe/Cash pay buttons.
  - Generous `1.25rem` component padding allows fast screen tapping without accidental adjacent button triggers.
- **Rhythm Rules:** Spacing relies on a strict 4px/8px incremental base. Micro paddings (`space-xs` and `space-sm`) keep chips and quantity steppers dense, while `space-lg` ensures checkout CTA panels stand distinct from scrollable order tables.

## Elevation & Depth

Visual hierarchy uses **warm tonal layers** complemented by **grounded ambient drop-shadows** that replicate physical card stock resting on a polished wooden or steel stall counter:

- **Level 0 (Base Canvas):** `#FDF8F2` with subtle textured warmth. Zero shadow.
- **Level 1 (Menu Item Cards & Surface Tiers):** `#FFFFFF` surfaces with subtle border `1px solid rgba(74, 21, 33, 0.08)` and ambient shadow `0 2px 8px -2px rgba(43, 19, 19, 0.06), 0 1px 3px 0 rgba(43, 19, 19, 0.04)`.
- **Level 2 (Active Item Selection & Quick-Filter Chips):** Lifted slightly with `0 4px 12px -2px rgba(74, 21, 33, 0.12)`.
- **Level 3 (Sticky Bottom Bar & Settlement Trays):** Elevated with upward ambient diffusion `0 -4px 16px -2px rgba(43, 19, 19, 0.10)`.
- **Level 4 (Modals, Customer QR Popovers, Bill Receipts):** Centered overlay depth `0 16px 36px -4px rgba(48, 10, 20, 0.22)`.
- **Press States:** Physical click reaction via active pseudo-classes transforms elements down `translateY(1px)` with reduced shadow to emulate tactile push-buttons on commercial POS hardware.

## Shapes

The interface embraces a modern, rounded curvature that feels cheerful, inviting, and organic:

- **Base Radius (0.5rem / 8px):** Applied to form inputs, small steppers, and table row containers.
- **Large Radius (1rem / 16px):** Standard for snack product cards, category navigation pills, and checkout modals.
- **Extra Large Radius (1.5rem / 24px):** Used on prominent payment trays, floating order tally bubbles, and customer QR frames.
- **Pills / Full Rounding (`9999px`):** Reserved exclusively for status indicators (e.g., "Paid", "Preparing", "Dine-in"), stock counters, and category filter buttons.

## Components

### Buttons & Action Bars
- **Primary Checkout Button:** Deep Burgundy background (`#4A1521`), white text (`#FFFFFF`), bold Space Grotesk currency figures on the right edge. Minimum height of 54px for foolproof thumb tapping.
- **Secondary Buttons:** Terracotta (`#C86D46`) or bordered latte with deep espresso text for print, split bill, and complimentary extras.
- **Numeric & Stepper Buttons:** Circular 36px or 44px buttons (`-` and `+`) with deep wine fill or high-contrast border, providing instant auditory and visual feedback when adding items like "Classic Fries".

### Food Cards
- Crisp white (`#FFFFFF`) or soft ivory (`#FFF9F5`) cards containing an appetizing dish thumbnail, bold title in Epilogue, price tag highlighted in Space Grotesk (`₹ 70`), and an accessible "+" quick-add badge anchored at the bottom-right.
- Selected state applies a 2px outline in `#4A1521` and a soft amber badge showing active count.

### Category Chips
- Pill-shaped scrollable horizontal bar at the top of the menu grid (e.g., "All", "Snacks", "Sips", "Combos").
- Inactive state: Cream background (`#F8EFE4`) with espresso text (`#2B1313`).
- Active state: Rich Burgundy (`#4A1521`) with clean white text and bold typography.

### Checkboxes, Radios, and Add-on Toggles
- Custom rounded squares (8px radius) with 2px solid `#C86D46` borders.
- Checked state fills with `#4A1521` accompanied by a crisp white checkmark.
- Radio buttons feature a distinct inner ring suitable for single-select choices (e.g., "Small", "Regular", "Jumbo").

### Input Fields & Keypad
- Inputs feature warm ivory background (`#FFF9F5`), 1.5px border in `#E8D8CB`, focusing into `#4A1521` with a soft 3px terracotta glow ring.
- Custom on-screen numpad for custom pricing and quick cash inputs with tactile card-like tiles and bold numbers.

### Specialized POS Components
- **QR Code Payment Drawer / Modal:** Clean high-contrast white container framed with warm burgundy branding, displaying dynamic UPI/PhonePe QR with prominent live timer, transaction ID, and instant green "Payment Received" toast banner.
- **Order Ticket Item Row:** Horizontal strip with item name, custom modifier badges, quantity stepper, and calculated subtotal with 1-tap delete sweep.