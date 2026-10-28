# Snacks O'Clock — SQLite Database Schema & Persistence Architecture

## 1. Architectural Strategy

- **Engine:** SQLite (using `sqflite` on Android/iOS and `sqflite_common_ffi` for unit testing/desktop).
- **Integrity Guarantee:** Atomic SQLite transactions (`db.transaction(...)`) for completing all sales. A bill and its line items are committed simultaneously; failure rolls back cleanly without data loss.
- **Price Immutability:** Historical sales freeze `unit_price` and `unit_cost` snapshots directly in `sale_items`. Editing future product prices never alters historical revenue or profit figures.

---

## 2. Table Definitions

### `products`
Stores the active menu catalog, prices, and unit costs.
```sql
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,       -- 'snacks' | 'sips'
  selling_price REAL NOT NULL,
  cost_price REAL NOT NULL,
  portion TEXT NOT NULL,        -- e.g. '/ portion', '/ 2 pcs', '/ 350ml'
  image_asset TEXT NOT NULL,
  badge TEXT,                   -- 'Crispy', 'Bestseller', 'Spicy', etc.
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

### `sales`
Master record for each completed or recorded bill.
```sql
CREATE TABLE sales (
  id TEXT PRIMARY KEY,
  bill_number TEXT NOT NULL UNIQUE, -- e.g. 'SOC-1001', 'SOC-1002'
  token_number INTEGER NOT NULL,    -- 1 to 99 rolling token
  customer_name TEXT,
  phone_number TEXT,
  timestamp TEXT NOT NULL,          -- ISO-8601 string
  subtotal REAL NOT NULL,
  discount REAL NOT NULL DEFAULT 0.0,
  tax REAL NOT NULL DEFAULT 0.0,
  grand_total REAL NOT NULL,
  total_items_count INTEGER NOT NULL,
  payment_method TEXT NOT NULL,     -- 'cash' | 'phonepe_upi'
  payment_status TEXT NOT NULL,     -- 'verified' | 'pending' | 'unverified'
  amount_received REAL,
  change_returned REAL,
  notes TEXT,
  is_synced INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_sales_timestamp ON sales(timestamp);
CREATE INDEX idx_sales_bill_number ON sales(bill_number);
```

### `sale_items`
Individual line items frozen at the time of sale.
```sql
CREATE TABLE sale_items (
  id TEXT PRIMARY KEY,
  sale_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  product_name TEXT NOT NULL,       -- Immutable snapshot
  unit_price REAL NOT NULL,         -- Immutable snapshot of selling_price
  unit_cost REAL NOT NULL,          -- Immutable snapshot of cost_price
  quantity INTEGER NOT NULL,
  line_total REAL NOT NULL,
  FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE INDEX idx_sale_items_sale_id ON sale_items(sale_id);
```

### `expenses`
Operating and stall daily expenses (oil, raw potatoes, lemons, takeaway containers, gas).
```sql
CREATE TABLE expenses (
  id TEXT PRIMARY KEY,
  category TEXT NOT NULL,           -- 'raw_food', 'packaging', 'gas_fuel', 'misc'
  description TEXT NOT NULL,
  amount REAL NOT NULL,
  timestamp TEXT NOT NULL
);

CREATE INDEX idx_expenses_timestamp ON expenses(timestamp);
```

### `app_settings`
Stall configuration, next bill number, opening cash drawer float, and cashier name.
```sql
CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
```
Default Settings:
- `next_bill_seq`: `1001`
- `opening_cash_float`: `1500.0`
- `cashier_name`: `Rahul`
- `stall_name`: `Snacks O'Clock`
- `upi_vpa` / `upi_id`: `karan1513.wallet@phonepe` (Stall UPI ID)
- `merchant_name`: `Snacks O'Clock` (Display name shown on UPI checkout)
- `payment_instructions`: Optional customer instructions (e.g. `Scan with PhonePe, GPay, Paytm or any UPI app & show confirmation.`)
- `qr_image_path`: Absolute path to persistent custom QR code in `getApplicationDocumentsDirectory()/qr_codes/stall_qr_<timestamp>.<ext>`, or asset path `assets/payments/phonepe_qr.png`, or empty string if QR was explicitly removed.
- `payment_settings_updated_at`: ISO8601 timestamp of last settings update
- `fssai_lic`: `21524098000412`

> **Note on Non-Destructive Configuration:**
> Modifying `app_settings` (such as changing the UPI ID, merchant name, or QR code) dynamically updates future bills and checkout displays without retroactively altering historical receipts, line items, or accounting records. Historical sales preserve their exact pricing and snapshot items in `sales` and `sale_items`.

---

## 3. Financial Calculation Formulas

1. **Gross Sales:** $\sum \text{sales.grand\_total}$ where `payment_status = 'verified'`
2. **Cost of Goods Sold (COGS):** $\sum (\text{sale\_items.quantity} \times \text{sale\_items.unit\_cost})$
3. **Total Expenses:** $\sum \text{expenses.amount}$
4. **Estimated Net Profit:** $\text{Gross Sales} - \text{COGS} - \text{Total Expenses}$
5. **Cash Drawer Reconciliation:**
   $$\text{Expected in Drawer} = \text{opening\_float} + \sum \text{cash sales} - \sum \text{cash expenses}$$
