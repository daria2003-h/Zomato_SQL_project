--Zomato Data Analysis using SQL

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

--adding constraint

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


--end of schemas--
