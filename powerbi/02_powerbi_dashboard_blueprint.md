# Power BI Dashboard Blueprint

## Model
DIM_DATE → FACT_ORDERS ← DIM_CUSTOMER
DIM_PRODUCT → FACT_ORDERS
DIM_STORE → FACT_ORDERS

Single-direction, one-to-many relationships from dimensions to FACT_ORDERS.

## Page 1 — Executive Overview
KPI cards: Revenue, Profit, Margin %, Orders, Customers, AOV, YoY Revenue %.
Charts: monthly revenue/profit trend, revenue by region, revenue by category.
Slicers: year, region, category.

## Page 2 — Sales & Product Intelligence
Top/bottom products, category revenue/profit, revenue-vs-profit, discount-band margin, category returns.

## Page 3 — Customer Intelligence
New vs returning, segment revenue, top customers, contribution %, frequency, AOV by segment.

## Page 4 — Regional & Operational
Region/store ranking, return rate, payment mix, order status, shipping cost.

## Dashboard principle
Every visual must answer a business question. Avoid decorative visuals without an analytical purpose.
