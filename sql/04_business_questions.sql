USE food_delivery_portfolio;

-- =====================================================
-- BUSINESS QUESTIONS
-- Project: Food Delivery Analytics SQL Project
-- Description: Business-focused SQL analysis using aggregation,
-- filtering, ranking, and analytical SQL techniques.
-- =====================================================

-- =====================================================
-- RESTAURANT PERFORMANCE
-- =====================================================

-- Top 10 restaurants by total revenue
SELECT
restaurant_name,
ROUND(SUM(order_value), 2) AS total_revenue
FROM orders_data
GROUP BY restaurant_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Restaurants with more than 500 orders
SELECT
restaurant_name,
COUNT(*) AS total_orders
FROM orders_data
GROUP BY restaurant_name
HAVING COUNT(*) > 500
ORDER BY total_orders DESC;

-- =====================================================
-- CUSTOMER ANALYSIS
-- =====================================================

-- Top 5 customers by total spending
SELECT
customer_id,
ROUND(SUM(order_value), 2) AS total_spent
FROM orders_data
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 5;

-- Customer spending categories using CASE WHEN
SELECT
customer_id,
ROUND(SUM(order_value), 2) AS total_spent,
CASE
WHEN SUM(order_value) >= 5000 THEN 'High Value Customer'
WHEN SUM(order_value) >= 3000 THEN 'Medium Value Customer'
ELSE 'Low Value Customer'
END AS customer_segment
FROM orders_data
GROUP BY customer_id
ORDER BY total_spent DESC;

-- =====================================================
-- TIME-BASED ANALYSIS
-- =====================================================

-- Monthly revenue trend
SELECT
YEAR(order_date) AS order_year,
MONTH(order_date) AS order_month,
MONTHNAME(order_date) AS month_name,
ROUND(SUM(order_value), 2) AS monthly_revenue
FROM orders_data
GROUP BY
YEAR(order_date),
MONTH(order_date),
MONTHNAME(order_date)
ORDER BY
order_year,
order_month;

-- Monthly order volume
SELECT
YEAR(order_date) AS order_year,
MONTH(order_date) AS order_month,
MONTHNAME(order_date) AS month_name,
COUNT(*) AS total_orders
FROM orders_data
GROUP BY
YEAR(order_date),
MONTH(order_date),
MONTHNAME(order_date)
ORDER BY
order_year,
order_month;

-- =====================================================
-- CUISINE PERFORMANCE
-- =====================================================

-- Best-performing cuisine by revenue
SELECT
cuisine,
ROUND(SUM(order_value), 2) AS total_revenue
FROM orders_data
GROUP BY cuisine
ORDER BY total_revenue DESC
LIMIT 1;

-- Revenue by cuisine
SELECT
cuisine,
ROUND(SUM(order_value), 2) AS total_revenue
FROM orders_data
GROUP BY cuisine
ORDER BY total_revenue DESC;

-- =====================================================
-- GEOGRAPHIC ANALYSIS
-- =====================================================

-- Cities with above-average revenue
SELECT
city,
ROUND(SUM(order_value), 2) AS total_revenue
FROM orders_data
GROUP BY city
HAVING SUM(order_value) > (
SELECT AVG(city_revenue)
FROM (
SELECT SUM(order_value) AS city_revenue
FROM orders_data
GROUP BY city
) AS city_summary
)
ORDER BY total_revenue DESC;

-- Average delivery time by city
SELECT
city,
ROUND(AVG(delivery_time_minutes), 2) AS average_delivery_time
FROM orders_data
GROUP BY city
ORDER BY average_delivery_time DESC;

-- =====================================================
-- DELIVERY STATUS ANALYSIS
-- =====================================================

-- Revenue generated from delivered and cancelled orders
SELECT
delivery_status,
ROUND(SUM(order_value), 2) AS total_revenue
FROM orders_data
WHERE delivery_status IN ('Delivered', 'Cancelled')
GROUP BY delivery_status
ORDER BY total_revenue DESC;

-- Order count by delivery status
SELECT
delivery_status,
COUNT(*) AS total_orders
FROM orders_data
GROUP BY delivery_status
ORDER BY total_orders DESC;

-- Top 10 Restaurants by Revenue
SELECT
    restaurant_name,
    COUNT(*) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_revenue,
    ROUND(AVG(order_value), 2) AS average_order_value
FROM orders_data
GROUP BY restaurant_name
ORDER BY total_revenue DESC
LIMIT 10;
