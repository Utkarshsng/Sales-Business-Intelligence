# Power Query — Beginner-friendly ETL

Final scale: 2,000 customers, 300 products, 18 stores, 17,020 raw order rows and 17,000 clean orders across 2023–2025.

**Important data convention:** `discount_pct` is stored as percentage points (e.g. `7.87` means 7.87%). Therefore validation is 0–100 and sales uses `1 - discount_pct / 100`.

Workflow:
1. Import CSV
2. Set data types
3. Trim/clean text
4. Standardize payment/status
5. Remove duplicate order IDs
6. Reject invalid quantity, discount and shipping
7. Validate customer/product/store keys
8. Recalculate sales, cost and profit
9. Load clean tables

Use Data → Get Data → Blank Query → Advanced Editor with the supplied M scripts.
