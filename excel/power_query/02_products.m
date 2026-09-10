let
    Source = Csv.Document(
        File.Contents("C:\CHANGE_ME\business_performance_sales_intelligence\data\raw\products_raw.csv"),
        [Delimiter=",", Columns=6, Encoding=65001, QuoteStyle=QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    Typed = Table.TransformColumnTypes(PromotedHeaders,{
        {"product_id", type text}, {"product_name", type text}, {"category", type text},
        {"sub_category", type text}, {"unit_cost", type number}, {"unit_price", type number}
    }),
    CleanText = Table.TransformColumns(Typed,{
        {"product_id", each Text.Trim(Text.Clean(_)), type text},
        {"product_name", each Text.Trim(Text.Clean(_)), type text},
        {"category", each Text.Proper(Text.Trim(Text.Clean(_))), type text},
        {"sub_category", each Text.Proper(Text.Trim(Text.Clean(_))), type text}
    }),
    ValidCosts = Table.TransformColumns(CleanText,{
        {"unit_cost", each if _ = null or _ < 0 then null else _, type number},
        {"unit_price", each if _ = null or _ < 0 then null else _, type number}
    }),
    RemovedDuplicates = Table.Distinct(ValidCosts, {"product_id"})
in
    RemovedDuplicates