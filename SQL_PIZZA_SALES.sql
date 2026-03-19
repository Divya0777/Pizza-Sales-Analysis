
create database Pizza_DB;
use Pizza_DB;
select database();
/*LOAD DATA INFILE 'C:/pizza_sales.csv'
INTO TABLE pizza_sales
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;
*/
select 1;
select * from pizza_sales;

/*  _______________________________________PROJECT STARTS HERE ___________________________*/
-- KPI REQUIREMENTS 

-- Total Revenue (the sum of the total price of all pizza orders
select sum(total_price) as Total_Revenue from pizza_sales;

-- Average Order values (The average amount spent per order----, calculate by dividing the total revenue by the total number of orders)
select sum(total_price)/count(distinct order_id) as Avg_Order_Value  from pizza_sales;

-- Total Pizza Sold (the sum of quantities of all pizzas sold)
select sum(quantity) as Total_Pizza_Sold from pizza_sales;

-- Total orders (the total number of orders placed.)
select count(distinct order_id) as Total_Orders from pizza_sales; 

-- Average Pizzas per order (the average number of pizzas sold per order--, calculated by dividing the total number of pizzas sold by thhe total number of orders.)
select round(sum(quantity)/count(DISTINCT order_id)) from pizza_sales; -- with using round() o/p is 2
select sum(quantity)/count(DISTINCT order_id) as Avg_pizza_perorder from pizza_sales; -- without round() o/p is 2,
select cast(sum(quantity)/count(DISTINCT order_id) as decimal(10,2)) as Avg_Pizza_perOrder from pizza_sales; /* if you want in decimal points you should use cast() 
here decimal(10,2) is we will get 10 numbers after decimal but in output we will get only 2  eg:- if normal o/p is 2.3456789123 but we gave 2 there so our o/p will be 2.34*/

-- --------- CHARTS REQUIREMENTS --------------------
/* 1) DAILY TREND FOR TOTAL ORDERS:( create a bar chart that displays trend of total orders over a specific time period.
This chart will help us identify any patterns or fluctions in order volumes on a dailt basis.
*/
/*
FIRST TI RUNED BELOW CODE BUT I GOT ERROR AS DATE AND TIME COLUMNS ARE IN TEXT DATATYPE 
select DAYNAME(order_date) as order_day, count(distinct order_id) as Total_Orders
from pizza_sales
group by DAYNAME(order_date)
*/
-- when every are bringing a categorical column and a aggreat you have to use grop up categorical column

SELECT order_date, order_time FROM pizza_sales LIMIT 5; 

SET SQL_SAFE_UPDATES = 0; /*normally sql blocks any update without mentioning where clause to prevent accidental changes 
                           so here setting 0 means we are saying we are aware of what we are doing and asking to allow update */
UPDATE pizza_sales 
SET order_date = STR_TO_DATE(order_date, '%Y-%m-%d');
ALTER TABLE pizza_sales 
MODIFY COLUMN order_date DATE;
SET SQL_SAFE_UPDATES = 1; -- after our updations we have to set that again to 1 to prevent accidential changes

SET SQL_SAFE_UPDATES = 0;
UPDATE pizza_sales 
SET order_time = STR_TO_DATE(order_time, '%H:%i:%s');
ALTER TABLE pizza_sales 
MODIFY COLUMN order_time TIME;
SET SQL_SAFE_UPDATES = 1;

SELECT DAYNAME(order_date) AS order_day,
COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY DAYNAME(order_date), DAYOFWEEK(order_date);

/*monthly Trends for Total Orders :-(create a line chart that illustrates the hourly trend of total orders throughout the day
this chart will allow us to identify peak hours or periods of high order activityy
*/
select monthname(order_date) as month_name, count(distinct order_id) as Total_orders 
from pizza_sales
group by monthname(order_date), month(order_date)  -- monthname() it gives us month name but in alphabetical order
order by month(order_date);   -- use use month() and do order by month() it will soort from jan to dec correctly 
-- --if you want to know which month have highest orders first then ORDER BY TOTAL_ORDERS DESC;

/* percentage of sales by pizza category (create a pie chart that shows the distribution of sales across
different pizza categories. Thia chart will provide insights into popularity of various pizza categories
and their contribution to over all sales.
*/
select pizza_category, round(sum(total_price)) as total_sales,
round(sum(total_price)*100/
(select sum(total_price) from pizza_sales),2) as percentage_by_categeries
from pizza_sales 
group by pizza_category;

 -- here we are using where clause to specify that we need the o/p of only january month
select pizza_category, round(sum(total_price)) as total_sales,
round(sum(total_price)*100/
(select sum(total_price) from pizza_sales where month(order_date)=1),2) as percentage_by_categeries
from pizza_sales 
where month(ORDER_DATE)=1 -- when every we are using subquery and use where clause we have to use where clause in sub query also
group by pizza_category;


/*
Percentage of sales by pizza size (generate a pie chart that represents the percentage of sales attributed of different
pizza sizes. This chart wwill help us understand customer percentage for pizza and their impact on sales
*/
select pizza_size, CAST(sum(total_price) AS DECIMAL(10,2))  as total_sales, CAST(sum(total_price)*100/
(select sum(total_price) from pizza_sales) AS DECIMAL(10,2)) as PCT
from pizza_sales
where QUARTER(order_date)=1 -- GIVES DETAILS OF FIRST QUARTER OF THE YEAR (jan,feb, mar)
group by pizza_size
order by PCT DESC;

/* Top 5 Best Sellers By Revenue, Total Quantity and Total Orders ( Create a bar chart Highlighting the top 5 best-selling pizzas
 based on the Revenye on the revenue, Total Quality, total orders. This chart will help us identify the most popular pizza options.
*/
select pizza_name_id, sum(total_price) as total_revenue from pizza_sales
group by pizza_name_id
order by total_revenue desc limit 5;

-- bottom 5 pizzas
select pizza_name_id, sum(total_price) as total_revenue from pizza_sales
group by pizza_name_id
order by total_revenue asc limit 5;

-- now we need bottom 5 quantity
select pizza_name_id, sum(quantity) as total_quantity from pizza_sales
group by pizza_name_id
order by total_quantity asc limit 5;

-- if you need according orders (means bottom 5 ordders)
select pizza_name_id, sum(distinct order_id) as Total_Orders from pizza_sales
group by pizza_name_id
order by Total_Orders asc limit 5;

-- if you need according orders (means top 5 ordders)
select pizza_name_id, sum(distinct order_id) as Total_Orders from pizza_sales
group by pizza_name_id
order by Total_Orders desc limit 5;
USE pizza_sales;
SHOW TABLES;



