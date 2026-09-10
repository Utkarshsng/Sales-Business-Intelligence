let
    Source = Csv.Document(
        File.Contents("C:\CHANGE_ME\business_performance_sales_intelligence\data\raw\customers_raw.csv"),
        [Delimiter=",", Columns=9, Encoding=65001, QuoteStyle=QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    Typed = Table.TransformColumnTypes(PromotedHeaders,{
        {"customer_id", type text}, {"customer_name", type text}, {"gender", type text},
        {"age", Int64.Type}, {"city", type text}, {"state", type text},
        {"customer_segment", type text}, {"signup_date", type date}, {"email", type text}
    }),
    CleanText = Table.TransformColumns(Typed,{
        {"customer_id", each Text.Trim(Text.Clean(_)), type text},
        {"customer_name", each Text.Trim(Text.Clean(_)), type text},
        {"gender", each Text.Proper(Text.Trim(Text.Clean(_))), type text},
        {"city", each Text.Proper(Text.Trim(Text.Clean(_))), type text},
        {"state", each if _ = null or Text.Trim(Text.Clean(_)) = "" then "Unknown" else Text.Proper(Text.Trim(Text.Clean(_))), type text},
        {"customer_segment", each Text.Proper(Text.Trim(Text.Clean(_))), type text},
        {"email", each Text.Lower(Text.Trim(Text.Clean(_))), type text}
    }),
    ValidAge = Table.TransformColumns(CleanText, {
        {"age", each if _ = null or _ < 0 or _ > 100 then null else _, Int64.Type}
    }),
    RemovedDuplicateCustomers = Table.Distinct(ValidAge, {"customer_id"})
in
    RemovedDuplicateCustomers