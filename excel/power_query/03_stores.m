let
    Source = Csv.Document(
        File.Contents("C:\CHANGE_ME\business_performance_sales_intelligence\data\raw\stores_raw.csv"),
        [Delimiter=",", Columns=6, Encoding=65001, QuoteStyle=QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    Typed = Table.TransformColumnTypes(PromotedHeaders,{
        {"store_id", type text}, {"store_name", type text}, {"region", type text},
        {"city", type text}, {"state", type text}, {"store_type", type text}
    }),
    CleanText = Table.TransformColumns(Typed,{
        {"store_id", each Text.Trim(Text.Clean(_)), type text},
        {"store_name", each Text.Trim(Text.Clean(_)), type text},
        {"region", each Text.Proper(Text.Trim(Text.Clean(_))), type text},
        {"city", each Text.Proper(Text.Trim(Text.Clean(_))), type text},
        {"state", each Text.Proper(Text.Trim(Text.Clean(_))), type text},
        {"store_type", each Text.Proper(Text.Trim(Text.Clean(_))), type text}
    }),
    RemovedDuplicates = Table.Distinct(CleanText, {"store_id"})
in
    RemovedDuplicates