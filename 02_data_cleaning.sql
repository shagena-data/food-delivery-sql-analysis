USE food_delivery_portfolio;

-- Check for leading or trailing spaces in restaurant names
SELECT restaurant_name
FROM orders_data
WHERE restaurant_name <> TRIM(restaurant_name);

-- Standardize city names
SELECT city,
	UPPER(city) AS Standardize_city
FROM orders_data;

-- Standardize payment methods
SELECT payment_method,
	UPPER(payment_method) AS Standardize_payment_method
FROM orders_data;

-- Replace missing ratings with 0 for analysis
SELECT order_id,
	COALESCE(customer_rating , 0 ) AS rating_filled
FROM orders_data;

-- Count orders by delivery status
SELECT delivery_status,
 COUNT(*) AS total_orders
FROM orders_data
GROUP BY delivery_status
ORDER BY total_orders DESC;

-- Data Cleaning and Standardization
SELECT
    order_id,
    TRIM(restaurant_name) AS cleaned_restaurant_name,
    UPPER(city) AS standardized_city,
    UPPER(payment_method) AS standardized_payment_method,
    COALESCE(customer_rating, 0) AS cleaned_customer_rating
FROM orders_data
LIMIT 15;
