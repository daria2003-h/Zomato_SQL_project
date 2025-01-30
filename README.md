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
```sql
CREATE TABLE customers
		(customer_id INT PRIMARY KEY,
		customer_name VARCHAR(25),
		reg_date DATE
		);
```sql
CREATE TABLE restaurant
		(restaurant_id INT PRIMARY KEY,
		restaurant_name VARCHAR(55),
		city VARCHAR(55),
		opening_hours VARCHAR(55)
		);
```sql
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

--adding constraint
```sql
ALTER TABLE orders
ADD CONSTRAINT fk_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

```sql
ALTER TABLE orders
ADD CONSTRAINT fk_restaurant
FOREIGN KEY (restaurant_id)
REFERENCES restaurant(restaurant_id);

```sql
CREATE TABLE riders
		(rider_id INT PRIMARY KEY,
		rider_name VARCHAR(55),
		sign_up DATE
		);
```sql
CREATE TABLE deliveries
		(delivery_id INT PRIMARY KEY,
		order_id INT,--comes from orders table
		delivery_status VARCHAR(55),
		delivery_time TIME,
		rider_id INT--comes from riders table
);
```sql
--adding constraints

ALTER TABLE deliveries
ADD CONSTRAINT fk_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);
```sql
ALTER TABLE deliveries
ADD CONSTRAINT fk_riders
FOREIGN KEY (rider_id)
REFERENCES riders(rider_id);
