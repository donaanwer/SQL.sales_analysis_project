/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
 USE [data warehouse analytics];
GO
 CREATE VIEW [dbo].[gold.report_products 2] AS 
WITH base_query AS(
SELECT f.sales_amount,
f.price,
f.quantity,
f.order_date,
f.order_number,
f.product_key,
f.customer_key,
p.product_name,
p.category,
p.subcategory,
p.cost
FROM [dbo].[gold.fact_sales] f
LEFT JOIN [dbo].[gold.dim_products] p
ON f.product_key= p.product_key
WHERE order_date IS NOT NULL),

product_aggregations AS
(SELECT SUM(sales_amount) total_sales,
price
,SUM(quantity)total_quantity,
MAX(order_date) last_order_date,
DATEDIFF (MONTH,MIN(order_date),
MAX(order_date))life_span,
COUNT(order_number)total_orders,
COUNT(DISTINCT customer_key)total_customers,
product_key,
product_name,
category,
subcategory,
cost
FROM base_query
GROUP BY product_key,
product_name,
category,price,
subcategory,
cost),

products_segmentation AS(
SELECT
total_sales,price
,last_order_date,
life_span,
total_orders,
total_customers,
product_key,product_name,category,
subcategory,cost,total_quantity,
CASE WHEN total_sales > 50000 THEN 'High performer'
WHEN total_sales <10000 THEN 'Mid_performers'
ELSE 'Low_performers'
END products_revenue 
FROM product_aggregations),

 final_query as
(SELECT price,
last_order_date,
DATEDIFF(MONTH,last_order_date,GETDATE()) recency_in_months,
life_span,
total_sales,
total_orders,
total_quantity,
total_customers,
AVG (total_sales/NULLIF(total_quantity,0)) avg_revenue,
product_key,
product_name,
category,
subcategory,
cost,
CASE WHEN total_sales > 50000 THEN 'High performer'
WHEN total_sales <10000 THEN 'Mid_performers'
ELSE 'Low_performers'
END products_revenue,
CASE WHEN life_span=0 THEN 0
ELSE total_sales/life_span
END avg_monthly_revenue
FROM products_segmentation
GROUP BY price,
last_order_date,
life_span
,total_sales,
total_orders,
total_quantity,
total_customers,
product_key,
product_name,
category,
subcategory,
cost)

SELECT 
category,
subcategory,
cost,price,
recency_in_months,
life_span,
total_sales,
total_orders,
total_quantity,
avg_revenue,
product_name,
products_revenue,
avg_monthly_revenue
FROM final_query;