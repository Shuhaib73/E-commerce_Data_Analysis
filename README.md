## E-Commerce Database Analysis (Using MySQL and Power BI)

<p align="center">
    <img src="(ttps://github.com/Shuhaib73/E-commerce_Data_Analysis/blob/main/ecom_problem_stmt/ecommerce_cover.jpg"  width="400" height="250"  />

## Objective

#### In this project, the objective was to conduct a comprehensive analysis of an e-commerce dataset collected from US based sales comapny, with focus on understanding sales performance. The project involved various steps, including data loading, cleaning, Modeling and processing, cohort analysis, Time Series analysis, SQL queries for in-depth dataset exploration, and  Power BI was utilized to create an interactive sales dashboard for comprehensive data visualization.

### Project Steps:

#### SQL Database Connection and Power BI Integration: The initial phase involved importing the e-commerce dataset into MySQL and cleaning it to ensure data accuracy and relevance. After loading the e-commerce dataset into MySQL, the next step involved establishing a connection between MySQL and Power BI. This connection facilitated real-time data retrieval and updates, ensuring that the Power BI dashboard reflected the most recent insights from the MySQL database.

#### Query Optimization and Transformation: SQL queries were optimized to efficiently retrieve the required data for analysis. Transformation steps were implemented to shape the data according to the specific requirements of the Power BI dashboard. This included handling data types, aggregating information, and preparing the dataset for meaningful visualizations.

#### Time-Series Analysis: Time-series insights were explored, revealing patterns and trends that could inform strategic decisions. This analysis laid the foundation for dynamic and time-sensitive visualizations in the Power BI dashboard.

#### SQL Queries: To extract detailed insights, SQL queries were implemented. This involved identifying distinct Category, counting unique customers, and calculating the total Revenue, Profit. These queries provided crucial information about various aspects of the e-commerce data.

#### Power BI Dashboard Creation: Leveraging Power BI's capabilities, a comprehensive sales dashboard was created. The dashboard incorporated visually appealing and interactive elements to represent key metrics, such as total sales, profit margins, etc. Filters and slicers were implemented to allow users to explore data based on various dimensions, providing a tailored and user-friendly experience

#### Dynamic Data Updates: The real-time connection between MySQL and Power BI ensured that the dashboard received automatic updates as new data became available. This dynamic feature enabled stakeholders to make informed decisions based on the latest information, contributing to the agility and responsiveness of the analytics solution.


### Insights

#### ✒ Q1: Generates a summary report from the "ecommerce_data" table, including the total revenue, total profit, total number of orders, and the number of distinct customers.  ?

```sql
select 
	format(sum(sales_per_order),2) as Total_revenue,
    format(sum(profit_per_order),2) as Total_profit,
    format(count(order_id), 0) as Total_orders,
    format(count(distinct customer_id), 0) as Number_of_Customers
from ecommerce_data;
```
<details>
<summary>
Click here to see the snapshot of output
</summary>

<p align="center">
<kbd><img src="[https://github.com/fikrionii/eCommerce-Database-Analysis-with-SQL/blob/main/images/erd1.png](https://github.com/Shuhaib73/E-commerce_Data_Analysis/blob/main/ecom_problem_stmt/Q1.PNG)" alt="Image" width="580" height="400"></kbd>

</details>

#### ✒ Q2: Calculate month-over-month revenue differences and percentages for the "ecommerce_data" table. It creates a result set that includes columns for months, Total revenue, previous month revenue (PMRevenue), month-over-month revenue difference, and month-over-month revenue difference percentage.  

```sql
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
```

#### ✒ Q3: Generates a report with month-wise profit analysis based on the "ecommerce_data" table. The results include columns for months, current month profit, previous month profit (PMProfit), month-over-month profit difference, and month-over-month profit difference percentage.  

```sql
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
```

#### ✒ Q4: Retrieves the top 5 products based on total revenue from the "ecommerce_data" table. 

```sql
select 
	product_name as Product,
    format((sum(sales_per_order)), 0) as Revenue
from ecommerce_data
group by product_name
order by sum(sales_per_order) desc limit 5;
```

### ✒ Q5: Retrieves the top 5 Customers based on total revenue from the "ecommerce_data" table. 

```sql
select 
	customer_last_name as Customer,
    round(sum(sales_per_order)) as Revenue
from ecommerce_data
group by customer_last_name
order by sum(sales_per_order) desc limit 5;
```

#### ✒ Q6: Generates a report to analyze sales revenue for different regions and product categories from the "ecommerce_data" table. The results include columns for region, category, revenue, and a rank indicating the ranking of each category within its respective region based on revenue. 

```sql
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
```

#### ✒ Q7: Generates a report to analyze sales revenue for different regions and states from the "ecommerce_data" table. The results include columns for region, state, revenue, and a dense rank indicating the ranking of each state within its respective region based on descending revenue values. The final query filters the results to include only the top 5 states with the highest revenue in each region. 

```sql
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
```

#### ✒ Q8: Analyze total orders and profit based on different combinations of shipping types and payment modes from the "ecommerce_data" table.  

```sql
select 
	shipping_type as Shipping_type,
    payment_mode as Payment_mode,
    format(count(order_id), 0) as Total_orders,
    format(sum(profit_per_order), 0) as Profit
from ecommerce_data
group by Shipping_type, Payment_mode
order by Shipping_type;
```

#### ✒ Q9: Analyze total orders and revenue for different cities from the "ecommerce_data" table. Display Top 5 City based on Highest Revenue.

```sql
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
```

#### This comprehensive approach was tailored specifically for the US-based e-commerce company, aiming to empower stakeholders with actionable insights. By combining SQL analysis and Power BI visualization, the project delivered a dynamic and user-friendly analytics solution, facilitating informed decision-making and strategic planning based on the latest data.

