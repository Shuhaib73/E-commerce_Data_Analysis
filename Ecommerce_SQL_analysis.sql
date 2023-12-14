-- Creates a new database named "ecommerce_df" if it doesn't already exist.
create database if not exists ecommerce_db;

-- Sets the currently active database to "ecommerce_db."
use ecommerce_db;

-- Provides structural information about the "ecommerce_data" table, including column names and data types
describe ecommerce_data;

-- Counts and returns the total number of rows in the "ecommerce_data" table.
select count(*) from ecommerce_data;

-- Retrieves all records from the "ecommerce_data" table.
select * from ecommerce_data;

-- Retrieves all records from the "location_data" table.
select * from location_data;

-- Converts the "order_date" column in the "ecommerce_data" table from a string format ("%m/%d/%Y") to a date format using the MySQL str_to_date function.
update ecommerce_data
set order_date = str_to_date(order_date, "%m/%d/%Y");

-- Converts the "ship_date" column in the "ecommerce_data" table from a string format ("%m/%d/%Y") to a date format using the MySQL str_to_date function. 
update ecommerce_data
set ship_date = str_to_date(ship_date, "%m/%d/%Y");

-- modifying the data type to "date." 
alter table ecommerce_data
modify order_date date;

alter table ecommerce_data
modify ship_date date;

-- Renames the table "us_state_long_lat_codes" to "location_data" in the database. 
alter table us_state_long_lat_codes
rename to location_data;

-- Analysis 

-- Generates a summary report from the "ecommerce_data" table, including the total revenue, total profit, total number of orders, and the number of distinct customers.  
select 
	format(sum(sales_per_order),2) as Total_revenue,
    format(sum(profit_per_order),2) as Total_profit,
    format(count(order_id), 0) as Total_orders,
    format(count(distinct customer_id), 0) as Number_of_Customers
from ecommerce_data;

-- calculate month-over-month revenue differences and percentages for the "ecommerce_data" table. It creates a result set that includes columns for months, Total revenue, previous month revenue (PMRevenue), month-over-month revenue difference, and month-over-month revenue difference percentage.  
with cte as
(
select 
	monthname(order_date) as Months,
	round(sum(sales_per_order)) as Revenue,
    lag(round(sum(sales_per_order))) over(order by min(order_date)) as PMRevenue
from ecommerce_data
group by Months
order by min(order_date)
)
select 
	Months,
    Revenue,
    ifnull(PMRevenue, "") as PMRevenue,
    ifnull(Revenue - PMRevenue, "") as MoM_Revenue_Diff,
    ifnull(concat(round((((Revenue - PMRevenue) / PMRevenue) * 100),1), " %"), "") as MoM_rev_diff_perc
from cte;

-- Generates a report with month-wise profit analysis based on the "ecommerce_data" table. The results include columns for months, current month profit, previous month profit (PMProfit), month-over-month profit difference, and month-over-month profit difference percentage.  
with cte as
(
select 
	monthname(order_date) as Months,
	round(sum(profit_per_order)) as Profit,
    lag(round(sum(profit_per_order))) over(order by min(order_date)) as PMProfit
from ecommerce_data
group by Months
order by min(order_date)
)
select 
	Months,
    Profit,
    ifnull(PMProfit, "") as PMProfit,
    ifnull(Profit - PMProfit, "") as MoM_Profit_Diff,
    ifnull(concat(round((((Profit - PMProfit) / PMProfit) * 100),1), " %"), "") as MoM_Prf_diff_perc
from cte;

-- Retrieves the top 5 products based on total revenue from the "ecommerce_data" table. 
select 
	product_name as Product,
    format((sum(sales_per_order)), 0) as Revenue
from ecommerce_data
group by product_name
order by sum(sales_per_order) desc limit 5;

-- Retrieves the top 5 Customers based on total revenue from the "ecommerce_data" table. 
select 
	customer_last_name as Customer,
    round(sum(sales_per_order)) as Revenue
from ecommerce_data
group by customer_last_name
order by sum(sales_per_order) desc limit 5;

-- Generates a report to analyze sales revenue for different regions and product categories from the "ecommerce_data" table. The results include columns for region, category, revenue, and a rank indicating the ranking of each category within its respective region based on revenue. 
with cte as 
(
select 
	customer_region as Region,
    category_name as Category,
    format((sum(sales_per_order)), 0) as Revenue
from ecommerce_data
group by Region, Category
order by Region
)
select 
	Region,
    Category,
    Revenue,
    dense_rank() over(partition by Region order by Revenue desc) rnk
from cte;

-- Generates a report to analyze sales revenue for different regions and states from the "ecommerce_data" table. The results include columns for region, state, revenue, and a dense rank indicating the ranking of each state within its respective region based on descending revenue values. The final query filters the results to include only the top 5 states with the highest revenue in each region. 
with cte as 
(
select 
	customer_region as Region,
    customer_state as State,
    format((sum(sales_per_order)), 0) as Revenue,
    dense_rank() over(partition by customer_region order by sum(sales_per_order) desc) Rnk
from ecommerce_data
group by Region ,State
order by Region
)
select 
	Region,
    State,
    Revenue,
    Rnk
from cte
where rnk <= 5;

-- Analyze total orders and profit based on different combinations of shipping types and payment modes from the "ecommerce_data" table.  
select 
	shipping_type as Shipping_type,
    payment_mode as Payment_mode,
    format(count(order_id), 0) as Total_orders,
    format(sum(profit_per_order), 0) as Profit
from ecommerce_data
group by Shipping_type, Payment_mode
order by Shipping_type;

-- Analyze total orders and revenue for different cities from the "ecommerce_data" table. Display Top 5 City based on Highest Revenue.
with cte as 
(
select 
	customer_city as City,
    format(count(order_id), 0) as Total_orders,
    format(sum(sales_per_order), 0) as Revenue,
    dense_rank() over(order by sum(sales_per_order) desc) Rnk
from ecommerce_data
group by City 
)
select 
	City,
    Total_orders,
    Revenue
from cte
where rnk <= 5;




