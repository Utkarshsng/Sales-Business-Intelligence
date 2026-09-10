import pandas as pd
from pathlib import Path

BASE = Path("../data")

orders = pd.read_csv(BASE/"raw/orders_raw.csv")

checks = {
    "duplicate_order_ids": orders["order_id"].duplicated().sum(),
    "invalid_quantity": (orders["quantity"] <= 0).sum(),
    "invalid_discount": ((orders["discount_pct"] < 0) | (orders["discount_pct"] > 70)).sum(),
    "negative_shipping": (orders["shipping_cost"] < 0).sum(),
    "missing_payment_method": orders["payment_method"].isna().sum(),
}

print(pd.Series(checks, name="count"))

# Example cleaning
orders["payment_method"] = orders["payment_method"].astype("string").str.strip().str.title()
orders = orders.drop_duplicates(subset=["order_id"], keep="first")
orders = orders[(orders["quantity"] > 0) &
                (orders["discount_pct"].between(0, 70)) &
                (orders["shipping_cost"] >= 0)]

orders.to_csv(BASE/"cleaned/orders_from_raw_pipeline.csv", index=False)
print("Cleaned rows:", len(orders))
