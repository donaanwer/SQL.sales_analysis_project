--calculate the total sales per month
-- and the running total of sales over time
SELECT 
	order_date,
	total_sales,
	SUM(total_sales)  OVER (ORDER BY order_date) running_total_sales,
	AVG(avg_price)    OVER(ORDER BY order_date) moving_avg_sales
FROM
(
SELECT 
	DATETRUNC (YEAR,order_date) order_date,
	SUM (sales_amount) total_sales,
	AVG (price) avg_price
FROM  [data warehouse analytics].[dbo].[gold.fact_sales]
WHERE    DATETRUNC(YEAR,order_date)is not null
GROUP BY DATETRUNC(YEAR,order_date)
) t