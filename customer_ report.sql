/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/
/*_____________________________________________________________________________
1) Base query : retrives core columms from tables 
_______________________________________________________________________________*/
USE [data warehouse analytics];
GO
create view [dbo].[gold.report_customers 2] as
with base_query as(
select
f.order_number,f.product_key,f.order_date,f.sales_amount,f.quantity,
c.customer_key,c.customer_number,
concat(c.first_name,' ',c.last_name) customer_name,
DATEDIFF(year,c.birthdate,GETDATE()) age
from [data warehouse analytics].[dbo].[gold.fact_sales] f
left join [data warehouse analytics].[dbo].[gold.dim_customers] c
on c.customer_key=f.customer_key
where f.order_date is not null)

,customer_aggregation as
(select 
customer_key,customer_number,customer_name,age,
 count(distinct order_number) total_orders,sum(sales_amount)total_sales,
 sum(quantity) total_quantity, count(distinct product_key) total_products, 
 max(order_date) last_order,
 DATEDIFF(month,min(order_date), max(order_date)) life_span
from base_query
group by customer_key
,customer_number,
customer_name,
 age)

 select customer_key,customer_number,customer_name,age,
 total_orders,total_sales,
 total_sales/ total_orders avg_order_value,
 total_quantity, total_products, 
 last_order,DATEDIFF(month,last_order,GETDATE()) as recency,
 life_span,
 case when life_span > 12 and total_sales > 5000 then 'VIP'
when life_span >= 12 and total_sales <= 5000 then 'Regular' 
else 'new' 
end customer_segment,
CASE 
	 WHEN age < 20 THEN 'Under 20'
	 WHEN age between 20 and 29 THEN '20-29'
	 WHEN age between 30 and 39 THEN '30-39'
	 WHEN age between 40 and 49 THEN '40-49'
	 ELSE '50 and above'
END AS age_group,
case when life_span = 0 then total_sales
else total_sales/life_span 
end avg_monthly_spending
 from customer_aggregation


