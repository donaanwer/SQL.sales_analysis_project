/*analyze the yearly performance of products by comparing their sales
to both the average sales performance of the product and the previous year's sales*/
WITH yearly_product_sales as(
SELECT p.product_name,
sum(f.sales_amount) current_sales,
YEAR (f.order_date) year_order
FROM [data warehouse analytics].[dbo].[gold.fact_sales] f
left join [data warehouse analytics].[dbo].[gold.dim_products] p
ON f.product_key= p.product_key
WHERE YEAR (f.order_date) is not null
group by YEAR(f.order_date),p.product_name)
select year_order,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER(partition by product_name) > 0 THEN 'Above avg'
WHEN current_sales - AVG(current_sales) OVER(partition by product_name) <0 THEN'Below avg'
ELSE'Avg'
END avg_cahange,
--year over year analysis 
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY year_order) pry_sales,
current_sales-LAG(current_sales) OVER(PARTITION BY product_name ORDER BY year_order) AS diff_pry,
CASE WHEN current_sales-LAG(current_sales) OVER(PARTITION BY product_name ORDER BY year_order) > 0 THEN 'increasing'
WHEN current_sales-LAG(current_sales) OVER(PARTITION BY  product_name ORDER BY  year_order) < 0 THEN 'decreasing' 
ELSE 'No change'
END pry_change
FROM yearly_product_sales
ORDER BY product_name,year_order;
