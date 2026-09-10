-- Project 1 SQL Analytics — 36 business questions

-- 01 Total revenue
SELECT ROUND(SUM(sales_amount),2) total_revenue FROM fact_orders;

-- 02 Total profit
SELECT ROUND(SUM(profit),2) total_profit FROM fact_orders;

-- 03 Orders and customers
SELECT COUNT(DISTINCT order_id) orders, COUNT(DISTINCT customer_id) customers FROM fact_orders;

-- 04 AOV
SELECT ROUND(SUM(sales_amount)/COUNT(DISTINCT order_id),2) aov FROM fact_orders;

-- 05 Revenue by category
SELECT p.category, ROUND(SUM(f.sales_amount),2) revenue
FROM fact_orders f JOIN dim_product p ON p.product_id=f.product_id
GROUP BY p.category ORDER BY revenue DESC;

-- 06 Profit by region
SELECT s.region, ROUND(SUM(f.profit),2) profit
FROM fact_orders f JOIN dim_store s ON s.store_id=f.store_id
GROUP BY s.region ORDER BY profit DESC;

-- 07 Payment-method order volume
SELECT payment_method, COUNT(*) orders FROM fact_orders
GROUP BY payment_method ORDER BY orders DESC;

-- 08 Returns by region
SELECT s.region, SUM(CASE WHEN f.return_flag=1 THEN 1 ELSE 0 END) returns
FROM fact_orders f JOIN dim_store s ON s.store_id=f.store_id
GROUP BY s.region ORDER BY returns DESC;

-- 09 Monthly revenue
SELECT TRUNC(order_date,'MM') month_start, ROUND(SUM(sales_amount),2) revenue
FROM fact_orders GROUP BY TRUNC(order_date,'MM') ORDER BY month_start;

-- 10 Revenue by customer segment
SELECT c.customer_segment, ROUND(SUM(f.sales_amount),2) revenue
FROM fact_orders f JOIN dim_customer c ON c.customer_id=f.customer_id
GROUP BY c.customer_segment ORDER BY revenue DESC;

-- 11 Top 10 products
SELECT * FROM (
 SELECT p.product_name, ROUND(SUM(f.sales_amount),2) revenue
 FROM fact_orders f JOIN dim_product p ON p.product_id=f.product_id
 GROUP BY p.product_name ORDER BY revenue DESC
) WHERE ROWNUM<=10;

-- 12 Low-margin orders
SELECT order_id, sales_amount, profit,
 ROUND(profit/NULLIF(sales_amount,0)*100,2) margin_pct
FROM fact_orders WHERE sales_amount>0 AND profit/sales_amount<0.10
ORDER BY margin_pct;

-- 13 Year revenue/profit/margin
SELECT EXTRACT(YEAR FROM order_date) year, ROUND(SUM(sales_amount),2) revenue,
 ROUND(SUM(profit),2) profit, ROUND(SUM(profit)/SUM(sales_amount)*100,2) margin_pct
FROM fact_orders GROUP BY EXTRACT(YEAR FROM order_date) ORDER BY year;

-- 14 Category profitability
SELECT p.category, ROUND(SUM(f.sales_amount),2) revenue,
 ROUND(SUM(f.profit),2) profit, ROUND(SUM(f.profit)/SUM(f.sales_amount)*100,2) margin_pct
FROM fact_orders f JOIN dim_product p ON p.product_id=f.product_id
GROUP BY p.category ORDER BY revenue DESC;

-- 15 Top stores
SELECT s.store_name,s.region,ROUND(SUM(f.sales_amount),2) revenue
FROM fact_orders f JOIN dim_store s ON s.store_id=f.store_id
GROUP BY s.store_name,s.region ORDER BY revenue DESC FETCH FIRST 10 ROWS ONLY;

-- 16 Customers above ₹100k
SELECT c.customer_id,c.customer_name,ROUND(SUM(f.sales_amount),2) revenue
FROM fact_orders f JOIN dim_customer c ON c.customer_id=f.customer_id
GROUP BY c.customer_id,c.customer_name
HAVING SUM(f.sales_amount)>100000 ORDER BY revenue DESC;

-- 17 New vs returning customer orders
WITH first_order AS (
 SELECT customer_id,MIN(order_date) first_order_date FROM fact_orders GROUP BY customer_id
)
SELECT TRUNC(f.order_date,'MM') month_start,
 SUM(CASE WHEN TRUNC(x.first_order_date,'MM')=TRUNC(f.order_date,'MM') THEN 1 ELSE 0 END) new_orders,
 SUM(CASE WHEN TRUNC(x.first_order_date,'MM')<TRUNC(f.order_date,'MM') THEN 1 ELSE 0 END) returning_orders
FROM fact_orders f JOIN first_order x ON x.customer_id=f.customer_id
GROUP BY TRUNC(f.order_date,'MM') ORDER BY month_start;

-- 18 Product revenue vs profit
SELECT p.product_name,p.category,ROUND(SUM(f.sales_amount),2) revenue,
 ROUND(SUM(f.profit),2) profit,ROUND(SUM(f.profit)/NULLIF(SUM(f.sales_amount),0)*100,2) margin_pct
FROM fact_orders f JOIN dim_product p ON p.product_id=f.product_id
GROUP BY p.product_name,p.category ORDER BY revenue DESC;

-- 19 Discount-band economics
SELECT CASE WHEN discount_pct<5 THEN '0-5%' WHEN discount_pct<10 THEN '5-10%'
 WHEN discount_pct<20 THEN '10-20%' ELSE '20%+' END discount_band,
 COUNT(*) orders,ROUND(SUM(sales_amount),2) revenue,ROUND(SUM(profit),2) profit,
 ROUND(SUM(profit)/SUM(sales_amount)*100,2) margin_pct
FROM fact_orders
GROUP BY CASE WHEN discount_pct<5 THEN '0-5%' WHEN discount_pct<10 THEN '5-10%'
 WHEN discount_pct<20 THEN '10-20%' ELSE '20%+' END
ORDER BY MIN(discount_pct);

-- 20 Return rate by category
SELECT p.category,COUNT(*) orders,SUM(CASE WHEN f.return_flag=1 THEN 1 ELSE 0 END) returns,
 ROUND(SUM(CASE WHEN f.return_flag=1 THEN 1 ELSE 0 END)/COUNT(*)*100,2) return_rate_pct
FROM fact_orders f JOIN dim_product p ON p.product_id=f.product_id
GROUP BY p.category ORDER BY return_rate_pct DESC;

-- 21 Store profitability
SELECT s.region,s.store_name,ROUND(SUM(f.sales_amount),2) revenue,ROUND(SUM(f.profit),2) profit
FROM fact_orders f JOIN dim_store s ON s.store_id=f.store_id
GROUP BY s.region,s.store_name ORDER BY s.region,profit DESC;

-- 22 Product rank within category
SELECT p.category,p.product_name,ROUND(SUM(f.sales_amount),2) revenue,
 RANK() OVER(PARTITION BY p.category ORDER BY SUM(f.sales_amount) DESC) revenue_rank
FROM fact_orders f JOIN dim_product p ON p.product_id=f.product_id
GROUP BY p.category,p.product_name;

-- 23 Customer revenue contribution
WITH cs AS (SELECT customer_id,SUM(sales_amount) revenue FROM fact_orders GROUP BY customer_id)
SELECT customer_id,ROUND(revenue,2) revenue,ROUND(revenue/SUM(revenue) OVER()*100,2) contribution_pct
FROM cs ORDER BY revenue DESC;

-- 24 Monthly MoM growth
WITH m AS (SELECT TRUNC(order_date,'MM') month_start,SUM(sales_amount) revenue
 FROM fact_orders GROUP BY TRUNC(order_date,'MM'))
SELECT month_start,ROUND(revenue,2) revenue,
 ROUND(LAG(revenue) OVER(ORDER BY month_start),2) previous_revenue,
 ROUND((revenue-LAG(revenue) OVER(ORDER BY month_start))/NULLIF(LAG(revenue) OVER(ORDER BY month_start),0)*100,2) mom_growth_pct
FROM m ORDER BY month_start;

-- 25 Year-over-year growth
WITH y AS (SELECT EXTRACT(YEAR FROM order_date) year,SUM(sales_amount) revenue
 FROM fact_orders GROUP BY EXTRACT(YEAR FROM order_date))
SELECT year,ROUND(revenue,2) revenue,ROUND(LAG(revenue) OVER(ORDER BY year),2) prior_year_revenue,
 ROUND((revenue-LAG(revenue) OVER(ORDER BY year))/NULLIF(LAG(revenue) OVER(ORDER BY year),0)*100,2) yoy_growth_pct
FROM y ORDER BY year;

-- 26 Running revenue
WITH m AS (SELECT TRUNC(order_date,'MM') month_start,SUM(sales_amount) revenue
 FROM fact_orders GROUP BY TRUNC(order_date,'MM'))
SELECT month_start,ROUND(revenue,2) revenue,
 SUM(revenue) OVER(ORDER BY month_start ROWS UNBOUNDED PRECEDING) running_revenue
FROM m ORDER BY month_start;

-- 27 Top 3 products per region
WITH x AS (
 SELECT s.region,p.product_name,SUM(f.sales_amount) revenue
 FROM fact_orders f JOIN dim_product p ON p.product_id=f.product_id
 JOIN dim_store s ON s.store_id=f.store_id
 GROUP BY s.region,p.product_name
), r AS (
 SELECT x.*,DENSE_RANK() OVER(PARTITION BY region ORDER BY revenue DESC) rnk FROM x
)
SELECT region,product_name,ROUND(revenue,2) revenue,rnk FROM r WHERE rnk<=3 ORDER BY region,rnk;

-- 28 Above-average customers
WITH cs AS (SELECT customer_id,SUM(sales_amount) revenue FROM fact_orders GROUP BY customer_id)
SELECT customer_id,ROUND(revenue,2) revenue FROM cs
WHERE revenue>(SELECT AVG(revenue) FROM cs) ORDER BY revenue DESC;

-- 29 High-value customers with frequency/AOV
SELECT c.customer_id,c.customer_name,ROUND(SUM(f.sales_amount),2) revenue,
 COUNT(DISTINCT f.order_id) order_count,
 ROUND(SUM(f.sales_amount)/COUNT(DISTINCT f.order_id),2) aov
FROM fact_orders f JOIN dim_customer c ON c.customer_id=f.customer_id
GROUP BY c.customer_id,c.customer_name HAVING SUM(f.sales_amount)>100000
ORDER BY revenue DESC;

-- 30 High-revenue products below category margin
WITH pp AS (
 SELECT p.category,p.product_id,p.product_name,SUM(f.sales_amount) revenue,SUM(f.profit) profit
 FROM fact_orders f JOIN dim_product p ON p.product_id=f.product_id
 GROUP BY p.category,p.product_id,p.product_name
), cm AS (
 SELECT category,SUM(profit)/NULLIF(SUM(revenue),0) margin FROM pp GROUP BY category
)
SELECT pp.category,pp.product_name,ROUND(pp.revenue,2) revenue,
 ROUND(pp.profit/NULLIF(pp.revenue,0)*100,2) product_margin_pct,
 ROUND(cm.margin*100,2) category_margin_pct
FROM pp JOIN cm ON cm.category=pp.category
WHERE pp.revenue>(SELECT AVG(revenue) FROM pp)
 AND pp.profit/NULLIF(pp.revenue,0)<cm.margin ORDER BY pp.revenue DESC;

-- 31 Store revenue percentile
SELECT s.store_name,s.region,ROUND(SUM(f.sales_amount),2) revenue,
 ROUND(PERCENT_RANK() OVER(ORDER BY SUM(f.sales_amount))*100,2) revenue_percentile
FROM fact_orders f JOIN dim_store s ON s.store_id=f.store_id
GROUP BY s.store_name,s.region ORDER BY revenue_percentile DESC;

-- 32 Top category each month
WITH mc AS (
 SELECT TRUNC(f.order_date,'MM') month_start,p.category,SUM(f.sales_amount) revenue
 FROM fact_orders f JOIN dim_product p ON p.product_id=f.product_id
 GROUP BY TRUNC(f.order_date,'MM'),p.category
), r AS (
 SELECT mc.*,ROW_NUMBER() OVER(PARTITION BY month_start ORDER BY revenue DESC) rn FROM mc
)
SELECT month_start,category,ROUND(revenue,2) revenue FROM r WHERE rn=1 ORDER BY month_start;

-- 33 Return revenue/profit impact
SELECT p.category,
 SUM(CASE WHEN f.return_flag=1 THEN f.sales_amount ELSE 0 END) returned_revenue,
 SUM(CASE WHEN f.return_flag=1 THEN f.profit ELSE 0 END) returned_profit,
 ROUND(SUM(CASE WHEN f.return_flag=1 THEN 1 ELSE 0 END)/COUNT(*)*100,2) return_rate_pct
FROM fact_orders f JOIN dim_product p ON p.product_id=f.product_id
GROUP BY p.category ORDER BY returned_revenue DESC;

-- 34 Payment mix by region
SELECT s.region,f.payment_method,COUNT(*) orders,ROUND(SUM(f.sales_amount),2) revenue
FROM fact_orders f JOIN dim_store s ON s.store_id=f.store_id
GROUP BY s.region,f.payment_method ORDER BY s.region,revenue DESC;

-- 35 Pareto-style customer contribution
WITH cs AS (SELECT customer_id,SUM(sales_amount) revenue FROM fact_orders GROUP BY customer_id),
r AS (
 SELECT customer_id,revenue,SUM(revenue) OVER(ORDER BY revenue DESC ROWS UNBOUNDED PRECEDING) cumulative_revenue,
 SUM(revenue) OVER() total_revenue FROM cs
)
SELECT customer_id,ROUND(revenue,2) revenue,ROUND(cumulative_revenue/total_revenue*100,2) cumulative_contribution_pct
FROM r ORDER BY revenue DESC;

-- 36 Order-status performance
SELECT order_status,COUNT(*) orders,ROUND(SUM(sales_amount),2) revenue,
 ROUND(SUM(profit),2) profit,ROUND(AVG(shipping_cost),2) avg_shipping_cost
FROM fact_orders GROUP BY order_status ORDER BY revenue DESC;
