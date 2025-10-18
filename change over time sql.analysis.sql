--Analyze sales performance over time:
SELECT 
		SUM (sales_amount) total_sales,
		COUNT (DISTINCT customer_key) total_customers,
		SUM(quantity) total_quantities,
		YEAR (order_date)year_order_date,
		month(order_date)month_order_date
FROM      [data warehouse analytics].[dbo].[gold.fact_sales]
WHERE     YEAR (order_date) is not null
GROUP BY  YEAR (order_date),month(order_date)
ORDER BY  YEAR (order_date),month(order_date);