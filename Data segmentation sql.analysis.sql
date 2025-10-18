--segement product into cost ranges
--and count how many product falls into each segment

with product_segment AS
(
SELECT 
		product_key,
		product_name,
		cost,
CASE WHEN cost < 100 THEN 'Below 100'
WHEN      cost between 100 and 500 THEN '100-500'
WHEN      cost between 500 and 1000 THEN '500-1000'
ELSE      'Above 1000'
END       cost_range
FROM      [data warehouse analytics].[dbo].[gold.dim_products]
)
SELECT 
		COUNT (product_key)total_products,cost_range
FROM    product_segment
GROUP BY cost_range
ORDER BY SUM(product_key)
;

--group customers into 3 segments based on their spending behavior:
--vip: at least 12 months of history and spending more than $5000
--regular:at least 12 months of history and but spending $5000 or less
--new: lifespan less than 12 months
--and find the total number of customers by each group

WITH customer_spending AS
(
SELECT
		c.customer_key, 
		SUM(s.sales_amount) total_spending,
		MIN(order_date) first_order,
		MAX(order_date) last_order,
		DATEDIFF(MONTH,MIN(order_date),max(order_date)) life_span
FROM    [data warehouse analytics].[dbo].[gold.fact_sales] s
LEFT JOIN [data warehouse analytics].[dbo].[gold.dim_customers] c
ON        s.customer_key=c.customer_key
GROUP BY  c.customer_key
)
SELECT
		customer_segment,
		COUNT(customer_key) total_customers
FROM(
SELECT
		customer_key,
CASE WHEN life_span > 12 and total_spending > 5000 THEN 'VIP'
WHEN      life_span >= 12 and total_spending <= 5000 THEN 'Regular' 
ELSE      'new' 
END       customer_segment
FROM      customer_spending
) t
GROUP BY  customer_segment
ORDER BY  total_customers desc
;

