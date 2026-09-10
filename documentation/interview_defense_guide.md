# Interview Defense Guide

**30-second pitch**
“I built an end-to-end Business Performance and Sales Intelligence platform using Excel, Power Query, SQL, Power BI and DAX. I started with intentionally messy synthetic transactions, assessed and cleaned them, validated business rules and keys, built a star schema, wrote analytical SQL, and designed KPI-driven dashboards. I then translated the results into business recommendations.”

**Why Power Query?**
“To make cleaning repeatable and refreshable instead of manually repeating transformations.”

**Why star schema?**
“To separate descriptive dimensions from transactional facts, improving model clarity and filter behavior.”

**Why DAX measures?**
“Measures dynamically respond to filters and slicers, which is appropriate for KPIs such as margin, AOV and YoY.”

**How did you handle bad data?**
“I documented rules. Invalid ages become null, missing state becomes Unknown, duplicate order IDs are deduplicated, invalid transactional rows are rejected, and financial values are recalculated from business rules.”

**If revenue rises but profit falls?**
“Segment by category, product, region and discount band, then investigate unit economics, shipping, returns and product mix.”

**How would you investigate high returns?**
“Start with category/product, then drill into store, region, payment and status. The analysis identifies concentration; operational investigation determines cause.”

**Portfolio honesty**
Do not claim live production deployment or real stakeholder adoption. The dataset is synthetic and the project is a portfolio simulation.
