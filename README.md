# Zomato_SQL_project
![](https://github.com/daria2003-h/Zomato_SQL_project/blob/main/zomato_picture.jpg)

This project showcases my SQL problem-solving abilities through an in-depth analysis of Zomato, a leading food delivery company in India. It includes database setup, data importing, handling null values, and addressing key business challenges using advanced SQL queries.
## Project Structure

- **Database Setup:** Creation of the `zomato_db` database and the required tables.
- **Data Import:** Inserting sample data into the tables.
- **Data Cleaning:** Handling null values and ensuring data integrity.
- **Business Problems:** Solving 20 specific business problems using SQL queries.

## Database Setup
```sql
CREATE DATABASE zomato_db;
```

### 1. Dropping Existing Tables
```sql
DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS riders;

### 2. Creating Tables

CREATE TABLE customers
		(customer_id INT PRIMARY KEY,
		customer_name VARCHAR(25),
		reg_date DATE
		);

CREATE TABLE restaurant
		(restaurant_id INT PRIMARY KEY,
		restaurant_name VARCHAR(55),
		city VARCHAR(55),
		opening_hours VARCHAR(55)
		);

CREATE TABLE orders
		(order_id INT PRIMARY KEY,
		customer_id INT,--comes from customer table
		restaurant_id INT ,--comes from restaurant table
		order_item VARCHAR(100),
		order_date DATE,
		order_time TIME,
		order_status VARCHAR(55),
		total_amount FLOAT
		);

--adding constraints

ALTER TABLE orders
ADD CONSTRAINT fk_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);


ALTER TABLE orders
ADD CONSTRAINT fk_restaurant
FOREIGN KEY (restaurant_id)
REFERENCES restaurant(restaurant_id);


CREATE TABLE riders
		(rider_id INT PRIMARY KEY,
		rider_name VARCHAR(55),
		sign_up DATE
		);

CREATE TABLE deliveries
		(delivery_id INT PRIMARY KEY,
		order_id INT,--comes from orders table
		delivery_status VARCHAR(55),
		delivery_time TIME,
		rider_id INT--comes from riders table
);

--adding constraints

ALTER TABLE deliveries
ADD CONSTRAINT fk_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

ALTER TABLE deliveries
ADD CONSTRAINT fk_riders
FOREIGN KEY (rider_id)
REFERENCES riders(rider_id);
```

The Entity-Relationship (ERD) model for this database is structured as follows

![ERD Zomato DB](https://github.com/daria2003-h/Zomato_SQL_project/blob/main/zomato_erd.png)

## Data Import

## Data Cleaning and Handling Null Values

Before performing analysis, I ensured that the data was clean and free from null values where necessary. For instance:

```sql
UPDATE orders
SET total_amount = COALESCE(total_amount, 0);
```

## Business Problems Solved
### 1.Top 5 most frequently ordered dishes
Write a query to find the top 5 most frequently ordered dishes by customer called "Aakash Dubey" in the last 1 year.
```sql
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
```
### 2. Popular Time Slots
Question: Identify the time slots during which the most orders are placed. based on 2-hour intervals.

Logic

-00:59:59 AM --then 0

-01:59:59 AM --then 1

Approach 1
```sql
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
```
Approach 2
```sql
SELECT
	FLOOR(EXTRACT (HOUR FROM order_time)/2)*2 AS start_time,
	FLOOR(EXTRACT (HOUR FROM order_time)/2)*2+2 AS end_time,
	COUNT (*) AS order_count 
FROM orders
GROUP BY 1,2
ORDER BY 3 DESC;
```
### 3. Order Value Analysis
Question: Find the average order value per customer who has placed more than 750 orders.
Return customer_name, and aov(average order value)
```sql
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
```
### 4. High-Value Customers
Question: List the customers who have spent more than 100K in total on food orders.
Return customer_name, and customer_id!
```sql
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
```
### 5. Orders Without Delivery
Question: Write a query to find orders that were placed but not delivered. 
Return each restuarant name, city and number of not delivered orders 
```sql
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
```
### 6.Restaurant Revenue Ranking:
Rank restaurants by their total revenue from the last 2 years, including their name, 
total revenue, and rank within their city.
```sql
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
```
### 7. Most Popular Dish by City:
Identify the most popular dish in each city based on the number of orders.
```sql
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
```

### 8. Customer Churn: 
Find customers who haven’t placed an order in 2024 but did in 2023.
 ```sql
SELECT 
	DISTINCT customer_id 
FROM orders
WHERE EXTRACT(YEAR FROM order_date) = 2023
	  AND customer_id NOT IN 
	  (SELECT DISTINCT customer_id FROM orders 
	   WHERE EXTRACT(YEAR FROM order_date) = 2024 );
```	   
### 9. Cancellation Rate Comparison: 
Calculate and compare the order cancellation rate for each restaurant between the 
current year and the previous year.

```sql
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
```
### 10. Rider Average Delivery Time: 
Determine each rider's average delivery time.
```sql
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
ORDER BY avg_time_minutes ASC;
```
### 11. Monthly Restaurant Growth Ratio: 
Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining
```sql
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
```
### 12. Customer Segmentation: 
Customer Segmentation: Segment customers into 'Gold' or 'Silver' groups based on their total spending 
compared to the average order value (AOV). If a customer's total spending exceeds the AOV, 
label them as 'Gold'; otherwise, label them as 'Silver'. 
Write an SQL query to determine each segment's 
total number of orders and total revenue
```sql
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
```
### 13. Rider Monthly Earnings: 
Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.
```sql
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
```

### 14. Rider Ratings Analysis: 
Find the number of 5-star, 4-star, and 3-star ratings each rider has.
riders receive this rating based on delivery time.

-If orders are delivered less than 15 minutes of order received time the rider get 5 star rating,
-if they deliver 15 and 20 minute they get 4 star rating 
-if they deliver after 20 minute they get 3 star rating.
```sql
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
```
### 15. Order Frequency by Day: 
Analyze order frequency per day of the week and identify the peak day for each restaurant.
```sql
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
```
### 16. Customer Lifetime Value (CLV): 
Calculate the total revenue generated by each customer over all their orders.
```sql
SELECT 
o.customer_id,
c.customer_name,
SUM( total_amount) AS CLV
FROM orders AS o
JOIN customers AS c
ON c.customer_id = o.customer_id
GROUP BY 1,2
ORDER BY 3 DESC;
```
### 17. Monthly Sales Trends: 
Identify sales trends by comparing each month's total sales to the previous month.
```sql
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
```

### 18. Rider Efficiency: 
Evaluate rider efficiency by determining average delivery times and identifying those with the lowest and highest averages.
```sql
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
```


### 19. Order Item Popularity: 
Track the popularity of specific order items over time and identify seasonal demand spikes.
```sql
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
```
### 20. Rank each city based on the total revenue for last year 2023 
```sql
SELECT 
	r.city,
	SUM(o.total_amount) as total_sales,
	RANK() OVER(ORDER BY SUM(o.total_amount) DESC)
FROM orders AS o
	JOIN restaurant AS r
	ON r.restaurant_id = o.restaurant_id
WHERE EXTRACT(YEAR FROM order_date)=2023
GROUP BY r.city;
```
