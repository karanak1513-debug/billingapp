# Snacks O'Clock — Billing & Payment Lifecycle

## 1. Quick POS Workflow (Under 10 Seconds Per Customer)

```mermaid
graph TD
    A[Open POS Screen] --> B[Tap Dish Cards / Adjust Steppers]
    B --> C[Realtime Totals Updated in Floating Bar]
    C --> D[Tap Checkout / Bottom Bar]
    D --> E[Order Breakdown Drawer]
    E --> F{Select Payment Method}
    F -->|Cash Counter| G[Enter Cash Received]
    G --> H[Instant Change Calculation]
    H --> I[Complete Sale & Persist to SQLite]
    F -->|PhonePe / UPI| J[Display karan1513.wallet@phonepe QR]
    J --> K[Customer Scans & Pays Exact Total]
    K --> L[Operator Visually Verifies Green Tick / SMS]
    L --> M[Operator Checks Verification Box]
    M --> I
    I --> N[Display Thermal Digital Receipt & Token #]
    N --> O[Print / Share PDF / Start Next Bill]
```

---

## 2. Validation & Safety Rules

1. **No Zero/Empty Bills:** Checkout CTA is disabled whenever cart quantity is 0.
2. **Negative Quantities Blocked:** Stepper minimum is 0 (tapping minus on 1 removes the item from cart).
3. **Cash Tender Validation:** If entered cash < payable amount, checkout button remains disabled and highlights insufficient tender.
4. **Duplicate Submission Lock:** The "Complete Order" trigger initiates an atomic write and disables re-entry until navigation transition finishes.
5. **Atomic Transaction:** The bill header and all line items write inside a single SQLite transaction block.
