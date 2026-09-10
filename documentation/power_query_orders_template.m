let
    Source = Csv.Document(
        File.Contents("PATH_TO_PROJECT\data\raw\orders_raw.csv"),
        [Delimiter=",", Columns=15, Encoding=65001, QuoteStyle=QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    ChangedTypes = Table.TransformColumnTypes(PromotedHeaders,{
        {"order_id", type text}, {"order_date", type date}, {"customer_id", type text},
        {"product_id", type text}, {"store_id", type text}, {"quantity", Int64.Type},
        {"unit_price", type number}, {"discount_pct", type number}, {"sales_amount", type number},
        {"cost_amount", type number}, {"profit", type number}, {"return_flag", type logical},
        {"payment_method", type text}, {"order_status", type text}, {"shipping_cost", type number}
    }),
    TrimText = Table.TransformColumns(ChangedTypes,{
        {"payment_method", Text.Trim, type text},
        {"order_status", Text.Trim, type text}
    }),
    StandardizePayment = Table.TransformColumns(
        TrimText, {{"payment_method", Text.Proper, type text}}
    ),
    RemoveDuplicateOrders = Table.Distinct(StandardizePayment, {"order_id"}),
    ValidQuantity = Table.SelectRows(RemoveDuplicateOrders, each [quantity] > 0),
    ValidDiscount = Table.SelectRows(ValidQuantity, each [discount_pct] >= 0 and [discount_pct] <= 70),
    ValidShipping = Table.SelectRows(ValidDiscount, each [shipping_cost] >= 0)
in
    ValidShipping