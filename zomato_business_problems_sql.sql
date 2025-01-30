

--Import datasets & Checking Data---
--------------------
SELECT * FROM customers;
SELECT * FROM deliveries;
SELECT * FROM orders;
SELECT * FROM restaurant;
SELECT * FROM riders;


--Analysis & Reports--
----------------------
-- 1. Top 5 most frequently ordered dishes
-- Write a query to find the top 5 most frequently ordered dishes by customer called "Aakash Dubey" in the last 1 year.

--Approach
--join customers and orders tables
--filter fot the last 1 year
--filter for a spesific customer ( Aakash Dubey)
--group by customer id, dishes, count

SELECT *
FROM
(SELECT 
		c.customer_id,
		c.customer_name,
		o.order_item,
		COUNT (*) AS total_orders,
		DENSE_RANK() OVER (ORDER BY COUNT(*) DESC ) AS rank
		FROM orders AS o
INNER JOIN customers AS c
ON c.customer_id = o.customer_id
		WHERE reg_date > CURRENT_DATE - INTERVAL '1 Year' 
		AND 
		c.customer_name = 'Aakash Dubey'
		GROUP BY 1, 2, 3
		ORDER BY 2,4 DESC) as t1
WHERE rank <=5;
	

-- 2. Popular Time Slots
-- Question: Identify the time slots during which the most orders are placed. based on 2-hour intervals.

--00:59:59 AM --then 0
--01:59:59 AM --then 1

--Approach 1
SELECT 
 CASE
 	WHEN EXTRACT (HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00-02:00' 
	WHEN EXTRACT (HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00-04:00' 
	WHEN EXTRACT (HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00-06:00' 
	WHEN EXTRACT (HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00-08:00' 
	WHEN EXTRACT (HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00-10:00' 
	WHEN EXTRACT (HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00-12:00' 
	WHEN EXTRACT (HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00-14:00' 
	WHEN EXTRACT (HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00-16:00' 
	WHEN EXTRACT (HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00-18:00'
	WHEN EXTRACT (HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00-20:00'
	WHEN EXTRACT (HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00-22:00' 
	WHEN EXTRACT (HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00-24:00' END AS time_slot,
COUNT(order_id) AS order_count
FROM orders
GROUP BY time_slot
ORDER BY order_count DESC;

--Approach 2

SELECT
	FLOOR(EXTRACT (HOUR FROM order_time)/2)*2 AS start_time,
	FLOOR(EXTRACT (HOUR FROM order_time)/2)*2+2 AS end_time,
	COUNT (*) AS order_count 
FROM orders
GROUP BY 1,2
ORDER BY 3 DESC	;

-- 3. Order Value Analysis
-- Question: Find the average order value per customer who has placed more than 750 orders.
-- Return customer_name, and aov(average order value)

SELECT 
	c.customer_name, 
	COUNT(order_id) AS number_of_orders, 
	AVG(o.total_amount) AS average_order_value
FROM orders AS o
		JOIN customers AS c
		ON c.customer_id = o.customer_id
GROUP BY 1
HAVING COUNT(order_id)> 750
ORDER BY number_of_orders DESC;



-- 4. High-Value Customers
-- Question: List the customers who have spent more than 100K in total on food orders.
-- return customer_name, and customer_id!

SELECT 
	o.customer_id,
	c.customer_name,
	SUM(total_amount) AS total_spent
FROM orders AS o
	JOIN customers AS c
	ON c.customer_id = o.customer_id
GROUP BY o.customer_id, c.customer_name
HAVING SUM(total_amount)> 100000
ORDER BY total_spent DESC;


-- 5. Orders Without Delivery
-- Question: Write a query to find orders that were placed but not delivered. 
-- Return each restuarant name, city and number of not delivered orders 
SELECT 
r.restaurant_name,
r.restaurant_id,
r.city,
COUNT(o.order_id) AS not_delivered
 FROM orders AS o
LEFT JOIN restaurant AS r ON r.restaurant_id = o.restaurant_id
LEFT JOIN deliveries AS d ON d.order_id = o.order_id
WHERE d.delivery_id IS NULL
GROUP BY 1,2,3
ORDER BY 4 DESC;

SELECT 
	r.restaurant_id, 
	r.restaurant_name,
	r.city,
	COUNT(*) AS not_delivered
FROM orders AS o
	LEFT JOIN restaurant AS r
	ON r.restaurant_id = o.restaurant_id
WHERE o.order_id  NOT IN (SELECT order_id FROM deliveries)
GROUP BY 1,2,3
ORDER BY 4 DESC;

-- Q. 6
-- Restaurant Revenue Ranking: 
-- Rank restaurants by their total revenue from the last 2 years, including their name, 
-- total revenue, and rank within their city.
WITH ranking_table 
AS
(SELECT 
	r.restaurant_name,
	r.city,
	SUM(total_amount) AS total,
	RANK() OVER ( PARTITION BY r.city ORDER BY SUM(total_amount)) AS rank
FROM orders as o
JOIN restaurant AS r 
ON r.restaurant_id = o.restaurant_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '2 Year'
GROUP BY city, r.restaurant_name)
SELECT *
FROM ranking_table
WHERE rank = 1;


select distinct city from restaurant
-- Q. 7
-- Most Popular Dish by City: 
-- Identify the most popular dish in each city based on the number of orders.

SELECT 
	city, 
	order_item, 
	order_count
	FROM
		(SELECT 
			r.city,
			o.order_item,
			COUNT( order_item) AS order_count,
			RANK() OVER ( PARTITION BY r.city ORDER BY COUNT(order_item) DESC) AS rank
		FROM orders AS o
			JOIN restaurant AS r
			ON r.restaurant_id= o.restaurant_id
		GROUP BY r.city, o.order_item) AS rank_1
WHERE rank =1
ORDER BY 3 DESC;


-- Q.8 Customer Churn: 
-- Find customers who haven’t placed an order in 2024 but did in 2023.
--Approach
--find customres who have done orders in 2023
--find customers who have done orders in 2024
--compare them 

SELECT 
	DISTINCT customer_id 
FROM orders
WHERE EXTRACT(YEAR FROM order_date) = 2023
	  AND customer_id NOT IN 
	  (SELECT DISTINCT customer_id FROM orders 
	   WHERE EXTRACT(YEAR FROM order_date) = 2024 );
	   
-- Q.9 Cancellation Rate Comparison: 
-- Calculate and compare the order cancellation rate for each restaurant between the 
-- current year and the previous year.
select * from orders;
select * from restaurant;
select * from deliveries;

WITH 
t_2023 AS 
		(SELECT
		    o.restaurant_id,
		    COUNT(o.order_id) AS total_orders,
		    COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) AS not_delivered
		FROM orders AS o
		LEFT JOIN deliveries AS d
		ON d.order_id = o.order_id
		WHERE EXTRACT(YEAR FROM o.order_date) = 2023
		GROUP BY o.restaurant_id),
t_2024 AS 
		(SELECT
		    o.restaurant_id,
		    COUNT(o.order_id) AS total_orders,
		    COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) AS not_delivered
		FROM orders AS o
		LEFT JOIN deliveries AS d
		ON d.order_id = o.order_id
		WHERE EXTRACT(YEAR FROM o.order_date) = 2024
		GROUP BY o.restaurant_id),
cancel_ratio_2023 AS
		(SELECT 
		restaurant_id,
		ROUND(not_delivered::numeric/total_orders::numeric*100,4) AS cancel_ratio_2023
		FROM t_2023),
cancel_ratio_2024 AS 
		(SELECT 
		restaurant_id,
		ROUND(not_delivered::numeric/total_orders::numeric*100,4) AS cancel_ratio_2024
		FROM t_2024)
SELECT 
	cancel_ratio_2023.restaurant_id,
	r.restaurant_name,
	cancel_ratio_2023.cancel_ratio_2023,
	cancel_ratio_2024.cancel_ratio_2024
FROM cancel_ratio_2023
	JOIN cancel_ratio_2024 ON cancel_ratio_2024.restaurant_id = cancel_ratio_2023.restaurant_id
	JOIN restaurant AS r ON r.restaurant_id = cancel_ratio_2024.restaurant_id
ORDER BY cancel_ratio_2023.cancel_ratio_2023 DESC ;


-- Q.10 Rider Average Delivery Time: 
-- Determine each rider's average delivery time.


SELECT 
rider_id,
AVG(time_difference_min) as avg_time_minutes
FROM
   (SELECT
	rider_id,
	EXTRACT (EPOCH FROM ((d.delivery_time - o.order_time) + 
		CASE 
			WHEN o.order_time > d.delivery_time 
			THEN INTERVAL '1 day' 
			ELSE INTERVAL '0 day' 
			END))/60  AS time_difference_min
	FROM deliveries AS d
	JOIN orders AS o
	ON o.order_id = d.order_id
	WHERE d.delivery_status = 'Delivered')
GROUP BY rider_id
ORDER BY avg_time_minutes asc;

-- Q.11 Monthly Restaurant Growth Ratio: 
-- Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining

select * from orders;
select * from deliveries;


WITH t1 AS
(SELECT 
	o.restaurant_id,
	TO_CHAR(o.order_date, 'mm-yy') as month,
	COUNT(o.order_id) as current_month_orders,
	LAG(COUNT(o.order_id),1) OVER(PARTITION BY o.restaurant_id ORDER BY TO_CHAR(o.order_date, 'mm-yy')) AS previous_month_orders
FROM orders as o
	JOIN deliveries as d
	ON d.order_id = o.order_id
WHERE d.delivery_status = 'Delivered'
GROUP BY o.restaurant_id, month
ORDER BY o.restaurant_id, month)
SELECT 
restaurant_id,
month,
current_month_orders,
previous_month_orders,
 CASE
 WHEN previous_month_orders IS NOT NULL 
 THEN ROUND((current_month_orders::numeric-previous_month_orders::numeric)/previous_month_orders::numeric*100,4)
 ELSE 0 END as ratio_growth
FROM t1;

-- Q.12 Customer Segmentation: 
-- Customer Segmentation: Segment customers into 'Gold' or 'Silver' groups based on their total spending 
-- compared to the average order value (AOV). If a customer's total spending exceeds the AOV, 
-- label them as 'Gold'; otherwise, label them as 'Silver'. Write an SQL query to determine each segment's 
-- total number of orders and total revenue


--calculate how much each customer spent
--calculate AOV
--gold/silver
--each category's total number of orders and total revenue


--Customer segmentation
WITH 
t1 AS 
	(SELECT
		COUNT(order_id) AS orders_count,
		customer_id,
		SUM(total_amount) AS total_spent
	FROM orders
	GROUP BY customer_id) 
SELECT
	t1.orders_count,
    t1.customer_id,
    t1.total_spent,
    CASE 
        WHEN t1.total_spent > (SELECT AVG(total_spent) FROM t1) 
        THEN 'Gold' 
        ELSE 'Silver' 
    END AS customer_category
FROM t1;

--Categories, overview
WITH 
t1 AS 
		(SELECT
			COUNT(order_id) AS orders_count,
			customer_id,
			SUM(total_amount) AS total_spent
		FROM orders
		GROUP BY customer_id),
t2 AS 
		(SELECT
			t1.orders_count,
		    t1.customer_id,
		    t1.total_spent,
		    CASE 
		        WHEN t1.total_spent > (SELECT AVG(total_spent) FROM t1) 
		        THEN 'Gold' 
		        ELSE 'Silver' 
		    END AS customer_category
		FROM t1)
SELECT 
	customer_category,
	sum(orders_count) as orders_pro_category,
	sum(total_spent)as total_revenue
FROM t2
GROUP BY 1;

-- Q.13 Rider Monthly Earnings: 


SELECT
d.rider_id,
r.rider_name,
TO_CHAR( o.order_date, 'mm.yy') as month_,
SUM(o.total_amount) AS total,
ROUND(SUM(o.total_amount)::numeric*0.08, 2) AS monthly_earnings_
FROM orders AS o
JOIN deliveries AS d 
ON d.order_id = o.order_id
JOIN riders AS r ON r.rider_id = d.rider_id
GROUP BY d.rider_id,r.rider_name, month_
ORDER BY total DESC;


-- Q.14 Rider Ratings Analysis: 
-- Find the number of 5-star, 4-star, and 3-star ratings each rider has.
-- riders receive this rating based on delivery time.
-- If orders are delivered less than 15 minutes of order received time the rider get 5 star rating,
-- if they deliver 15 and 20 minute they get 4 star rating 
-- if they deliver after 20 minute they get 3 star rating.

select * from restaurant;
select * from deliveries;
select * from orders;

WITH 
t1 AS
	(SELECT 
	d.rider_id,
	o.order_time,
	d.delivery_time,
	ROUND(EXTRACT(EPOCH FROM ((d.delivery_time-o.order_time) + 
		CASE 
			WHEN d.delivery_time<o.order_time
			THEN INTERVAL '1 day'
			ELSE INTERVAL '0 day'
			END))/60,2) as time_difference_minutes
		FROM orders AS o
		JOIN deliveries AS d
		ON d.order_id = o.order_id
	WHERE d.delivery_status = 'Delivered'
	GROUP BY rider_id,o.order_time,
	d.delivery_time),
t2 AS 
(SELECT 
	t1.rider_id, 
	r.rider_name,
	t1.time_difference_minutes,
		CASE
			WHEN t1.time_difference_minutes<15 THEN '5 stars'
			WHEN t1.time_difference_minutes BETWEEN 15 AND 20 THEN '4 stars'
			ELSE '3 stars'
			END AS star_rating
FROM t1
	JOIN riders AS r 
	ON r.rider_id=t1.rider_id
GROUP BY 
	t1.rider_id, 
	r.rider_name,
	t1.time_difference_minutes,
	star_rating
ORDER BY 1,2,3)
SELECT 
	rider_id,
	rider_name,
	star_rating,
	COUNT(*) as count_stars
FROM t2
GROUP BY 1, 2,3
ORDER BY 2,3;



-- Q.15 Order Frequency by Day: 
-- Analyze order frequency per day of the week and identify the peak day for each restaurant.



SELECT 
	restaurant_id,
	restaurant_name,
	day_of_week, 
	orders_count
FROM 
	(SELECT 
	o.restaurant_id,
	r.restaurant_name,
	TO_CHAR(o.order_date, 'Day') AS day_of_week,
	COUNT(o.order_id) AS orders_count,
	RANK() OVER (PARTITION BY o.restaurant_id ORDER BY COUNT(o.order_id) DESC ) AS rank
	FROM orders AS o
		JOIN restaurant AS r
		ON r.restaurant_id = o.restaurant_id
	GROUP BY 1,2,3)
WHERE rank = 1 
ORDER BY 1,2,4 DESC;

-- Q.16 Customer Lifetime Value (CLV): 
-- Calculate the total revenue generated by each customer over all their orders.


SELECT 
o.customer_id,
c.customer_name,
SUM( total_amount) AS CLV
FROM orders AS o
JOIN customers AS c
ON c.customer_id = o.customer_id
GROUP BY 1,2
ORDER BY 3 DESC;

-- Q.17 Monthly Sales Trends: 
-- Identify sales trends by comparing each month's total sales to the previous month.

SELECT *,
(current_month-previous_month)/previous_month AS growth_ratio
FROM 
(SELECT
EXTRACT(YEAR FROM order_date) AS year,
EXTRACT(MONTH FROM order_date)AS month,
SUM(total_amount)AS current_month,
LAG(SUM(total_amount), 1) OVER (ORDER BY EXTRACT(YEAR FROM order_date),EXTRACT(MONTH FROM order_date)) AS previous_month
FROM orders 
GROUP BY 1,2);


-- Q.18 Rider Efficiency: 
-- Evaluate rider efficiency by determining average delivery times and identifying those with the lowest and highest averages.
select * from restaurant;
select * from deliveries;
select * from orders;

WITH 
t1 AS
(SELECT 
d.rider_id,
ROUND(EXTRACT(EPOCH FROM ((d.delivery_time-o.order_time) + 
		CASE 
			WHEN d.delivery_time<o.order_time
			THEN INTERVAL '1 day'
			ELSE INTERVAL '0 day'
			END))/60,2) as time_difference_minutes
FROM orders AS o
JOIN deliveries AS d
ON o.order_id = d.order_id
GROUP BY 1,2), 
t2 AS
(SELECT 
rider_id,
AVG(time_difference_minutes) as average_time
FROM t1
GROUP BY t1.rider_id)
SELECT 
ROUND(MAX(average_time),2)AS highest_average,
ROUND(MIN(average_time),2) AS lowest_average
FROM t2;



-- Q.19 Order Item Popularity: 
-- Track the popularity of specific order items over time and identify seasonal demand spikes.

WITH seasonal_orders AS (
    SELECT 
	CASE
            WHEN EXTRACT(MONTH FROM order_date) BETWEEN 9 AND 11 THEN 'AUTUMN'
            WHEN EXTRACT(MONTH FROM order_date) BETWEEN 3 AND 5  THEN 'SPRING'
            WHEN EXTRACT(MONTH FROM order_date) BETWEEN 6 AND 8  THEN 'SUMMER'
            ELSE 'WINTER'
        END AS season,
        order_item,
        COUNT(order_id) AS number_ordered
    FROM orders
    GROUP BY order_item, season
)
SELECT *,
    RANK() OVER (PARTITION BY season ORDER BY number_ordered DESC) AS rank
FROM seasonal_orders;


-- Q.20 Rank each city based on the total revenue for last year 2023 

SELECT 
	r.city,
	SUM(o.total_amount) as total_sales,
	RANK() OVER(ORDER BY SUM(o.total_amount) DESC)
FROM orders AS o
	JOIN restaurant AS r
	ON r.restaurant_id = o.restaurant_id
WHERE EXTRACT(YEAR FROM order_date)=2023
GROUP BY r.city;




