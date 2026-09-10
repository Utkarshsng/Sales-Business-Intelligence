let
    Source = Csv.Document(
        File.Contents("C:\CHANGE_ME\business_performance_sales_intelligence\data\raw\orders_raw.csv"),
        [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    Typed = Table.TransformColumnTypes(PromotedHeaders,{
        {"order_id", type text}, {"order_date", type date}, {"customer_id", type text},
        {"product_id", type text}, {"store_id", type text}, {"quantity", Int64.Type},
        {"unit_price", type number}, {"discount_pct", type number}, {"sales_amount", type number},
        {"cost_amount", type number}, {"profit", type number}, {"return_flag", type logical},
        {"payment_method", type text}, {"order_status", type text}, {"shipping_cost", type number}
    }),
    CleanText = Table.TransformColumns(Typed,{
        {"order_id", each Text.Trim(Text.Clean(_)), type text},
        {"customer_id", each Text.Trim(Text.Clean(_)), type text},
        {"product_id", each Text.Trim(Text.Clean(_)), type text},
        {"store_id", each Text.Trim(Text.Clean(_)), type text},
        {"payment_method", each Text.Proper(Text.Trim(Text.Clean(_))), type text},
        {"order_status", each Text.Proper(Text.Trim(Text.Clean(_))), type text}
    }),
    RemoveDuplicateOrderIDs = Table.Distinct(CleanText, {"order_id"}),
    ValidRows = Table.SelectRows(RemoveDuplicateOrderIDs,
        each [quantity] <> null and [quantity] > 0
        and [discount_pct] <> null and [discount_pct] >= 0 and [discount_pct] <= 100
        and [shipping_cost] <> null and [shipping_cost] >= 0
        and [order_date] <> null
    ),
    RecalcSales = Table.AddColumn(ValidRows, "sales_amount_calc",
        each [quantity] * [unit_price] * (1 - [discount_pct] / 100), type number),
    RecalcCost = Table.AddColumn(RecalcSales, "cost_amount_calc",
        each [quantity] * [unit_price] * 0.78, type number),
    RecalcProfit = Table.AddColumn(RecalcCost, "profit_calc",
        each [sales_amount_calc] - [cost_amount_calc] - [shipping_cost], type number),
    Rounded = Table.TransformColumns(RecalcProfit,{
        {"sales_amount_calc", each Number.Round(_, 2), type number},
        {"cost_amount_calc", each Number.Round(_, 2), type number},
        {"profit_calc", each Number.Round(_, 2), type number}
    }),
    RemovedOriginalFinancials = Table.RemoveColumns(Rounded,{"sales_amount","cost_amount","profit"}),
    RenamedFinancials = Table.RenameColumns(RemovedOriginalFinancials,{
        {"sales_amount_calc","sales_amount"},
        {"cost_amount_calc","cost_amount"},
        {"profit_calc","profit"}
    }),
    Reordered = Table.ReorderColumns(RenamedFinancials,{
        "order_id","order_date","customer_id","product_id","store_id","quantity",
        "unit_price","discount_pct","sales_amount","cost_amount","profit",
        "return_flag","payment_method","order_status","shipping_cost"
    })
in
    Reordered