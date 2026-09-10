let
    Orders = Orders_Clean,
    CustomerKeys = Table.SelectColumns(Customers_Clean, {"customer_id"}),
    ProductKeys = Table.SelectColumns(Products_Clean, {"product_id"}),
    StoreKeys = Table.SelectColumns(Stores_Clean, {"store_id"}),

    CheckCustomer = Table.NestedJoin(Orders, {"customer_id"}, CustomerKeys, {"customer_id"}, "CustomerMatch", JoinKind.LeftOuter),
    AddCustomerCheck = Table.AddColumn(CheckCustomer, "customer_key_valid", each Table.RowCount([CustomerMatch]) > 0, type logical),
    CheckProduct = Table.NestedJoin(AddCustomerCheck, {"product_id"}, ProductKeys, {"product_id"}, "ProductMatch", JoinKind.LeftOuter),
    AddProductCheck = Table.AddColumn(CheckProduct, "product_key_valid", each Table.RowCount([ProductMatch]) > 0, type logical),
    CheckStore = Table.NestedJoin(AddProductCheck, {"store_id"}, StoreKeys, {"store_id"}, "StoreMatch", JoinKind.LeftOuter),
    AddStoreCheck = Table.AddColumn(CheckStore, "store_key_valid", each Table.RowCount([StoreMatch]) > 0, type logical),

    Summary = #table(
        {"Check","Result"},
        {
            {"Rows in cleaned orders", Table.RowCount(Orders)},
            {"Duplicate order IDs", Table.RowCount(Orders) - Table.RowCount(Table.Distinct(Orders, {"order_id"}))},
            {"Invalid quantities", Table.RowCount(Table.SelectRows(Orders, each [quantity] = null or [quantity] <= 0))},
            {"Invalid discounts", Table.RowCount(Table.SelectRows(Orders, each [discount_pct] = null or [discount_pct] < 0 or [discount_pct] > 1))},
            {"Negative shipping", Table.RowCount(Table.SelectRows(Orders, each [shipping_cost] = null or [shipping_cost] < 0))},
            {"Invalid customer keys", Table.RowCount(Table.SelectRows(AddStoreCheck, each [customer_key_valid] = false))},
            {"Invalid product keys", Table.RowCount(Table.SelectRows(AddStoreCheck, each [product_key_valid] = false))},
            {"Invalid store keys", Table.RowCount(Table.SelectRows(AddStoreCheck, each [store_key_valid] = false))}
        }
    )
in
    Summary