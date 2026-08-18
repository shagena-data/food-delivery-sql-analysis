USE food_delivery_portfolio;

-- =====================================================
-- Top revenue-generating restaurant in each city
-- =====================================================

WITH restaurant_rank AS 
(
SELECT 
	   city,
       restaurant_name,
       ROUND(SUM(order_value ),2 ) AS total_revenue,
       ROW_NUMBER()  OVER(
							PARTITION BY city 
                            ORDER BY SUM(order_value) DESC) AS revenue_rank
       FROM orders_data
       GROUP BY city,
				restaurant_name
)
SELECT city,
	   restaurant_name,
       revenue_rank
FROM restaurant_rank
WHERE revenue_rank = 1
ORDER BY city;

-- =====================================================
-- Monthly order growth using LAG()
-- =====================================================

WITH monthly_orders AS
(
		SELECT
             YEAR(order_date) AS order_year,
             MONTH(order_date) AS order_month,
             MONTHNAME(order_date) AS order_monthname,
             COUNT(*) AS total_orders
		FROM orders_data
        GROUP BY 
				YEAR(order_date),
                MONTH(order_date),
                MONTHNAME(order_date)
        
)
SELECT order_year,
	   order_month,
       order_monthname,
       total_orders,
       LAG(total_orders) OVER( ORDER BY order_year,order_month) AS previous_month_orders,
       total_orders - LAG(total_orders) OVER (ORDER BY order_year , order_month ) AS order_growth
FROM monthly_orders
ORDER BY order_year,
		 order_month;


-- =====================================================
-- Running monthly revenue total
-- =====================================================

WITH revenuebymonth AS
(
		SELECT 
            YEAR(order_date) AS order_year,
            MONTH(order_date) AS order_month,
            MONTHNAME(order_date) AS order_monthname,
            ROUND(SUM(order_value),2)  AS monthly_revenue
		FROM orders_data
		GROUP BY 
				YEAR(order_date),
				MONTH(order_date),
				MONTHNAME(order_date)
)
SELECT order_year,
		order_month,
        order_monthname,
        monthly_revenue,
        ROUND(SUM(monthly_revenue) OVER ( ORDER BY order_year,order_month) ,2)
        AS running_revenue_total
FROM revenuebymonth
ORDER  BY order_year,
		order_month;

-- =====================================================
-- Revenue share of each city
-- =====================================================

WITH city_revenue AS (
    SELECT
        city,
        ROUND(SUM(order_value), 2) AS total_revenue
    FROM orders_data
    GROUP BY city
)

SELECT
    city,
    total_revenue,
    ROUND(
        SUM(total_revenue) OVER (),2
    ) AS overall_revenue,
    ROUND(
        (total_revenue / SUM(total_revenue) OVER ()) * 100,2
    ) AS revenue_share_percentage
FROM city_revenue
ORDER BY total_revenue DESC;

-- =====================================================
-- Top 3 customers in each city by total spending
-- =====================================================

WITH customer_spending AS
(
		SELECT city,
			   customer_id,
               ROUND(SUM(order_value), 2 ) AS
               total_spend
		FROM orders_data
        GROUP BY city,
				 customer_id
),
ranked_customer AS
(
SELECT city,
	   customer_id,
       total_spend,
       DENSE_RANK() OVER( 
						   PARTITION BY city 
                           ORDER BY total_spend DESC ) AS spending_rank
FROM customer_spending
)
SELECT city,
	   customer_id,
       total_spend,
       spending_rank
FROM ranked_customer
WHERE spending_rank <=3
ORDER BY  city,
		  spending_rank,
		  total_spend DESC;

-- =====================================================
-- Compare each order with the previous order
-- =====================================================
WITH compare_order AS
(
		SELECT order_id,
			   order_date,
               order_value
		FROM orders_data
),
previous_order AS 
(
		SELECT order_id,
			   order_date,
               order_value,
               LAG(order_value) OVER (ORDER BY order_date , order_id) AS previous_order_value
		FROM compare_order
)
SELECT order_id,
	   order_date,
	   order_value,
       previous_order_value,
       ROUND(order_value - previous_order_value,2) AS order_value_change,
       CASE
           WHEN previous_order_value IS NULL THEN 'No Previous order'
           WHEN order_value > previous_order_value THEN 'Increased'
           WHEN order_value < previous_order_value THEN 'Decreased'
           ELSE 'No chage'
		END AS change_status
FROM previous_order
ORDER BY order_date,
         order_id;
         
         
-- =====================================================
-- Compare each order with the next order
-- =====================================================

WITH compare_next_order AS
(
			SELECT order_id,
				   order_date,
                   order_value
			FROM orders_data
),
next_order AS
(
			SELECT order_id,
				   order_date,
                   order_value,
                   LEAD(order_value)  OVER( ORDER BY order_date , order_id) AS next_order_value
			FROM compare_next_order
)
SELECT order_id,
	   order_date,
	   order_value,
       next_order_value,
       ROUND(next_order_value - order_value ,2 ) AS order_value_change ,
       CASE 
			WHEN next_order_value IS NULL THEN 'No Next Order'
            WHEN next_order_value > order_value THEN 'Will Increase'
            WHEN next_order_value < order_value THEN 'Will Decrease'
            ELSE 'No change'
            END AS change_status
FROM next_order
ORDER BY order_date,
	     order_id;
                   
-- =====================================================
-- Highest and Lowest Order Value in Each City
-- =====================================================

SELECT
    city,
    order_id,
    order_value,

    FIRST_VALUE(order_value) OVER (
									PARTITION BY city
									ORDER BY order_value DESC
								   ) AS highest_order_value_in_city,

    LAST_VALUE(order_value) OVER (
									PARTITION BY city
									ORDER BY order_value DESC
									ROWS BETWEEN UNBOUNDED PRECEDING
											AND UNBOUNDED FOLLOWING
								 ) AS lowest_order_value_in_city

FROM orders_data
ORDER BY
    city,
    order_value DESC;



-- =====================================================
-- Customer Order Frequency Ranking
-- =====================================================

WITH orders_per_customer AS (
				SELECT
						customer_id,
						COUNT(*) AS total_orders
				FROM orders_data
				GROUP BY customer_id
),

customer_order_ranking AS
(
				SELECT
						customer_id,
						total_orders,
						RANK() OVER (
									ORDER BY total_orders DESC
									) AS order_frequency_rank
				FROM orders_per_customer
)
SELECT
    customer_id,
    total_orders,
    order_frequency_rank
FROM customer_order_ranking
ORDER BY
    order_frequency_rank,
    customer_id;


-- =====================================================
-- Executive Summary Dashboard
-- Project: Food Delivery Analytics SQL Project
-- Description: Consolidated business KPIs for management reporting
-- =====================================================
WITH order_summary AS
(
			SELECT 
					COUNT(*) AS total_orders,
                    ROUND(SUM(order_value), 2) AS total_revenue,
                    ROUND(AVG(order_value), 2) AS average_order_value
			FROM orders_data
),
customer_summary AS
(
			SELECT 
					COUNT(DISTINCT customer_id) AS unique_customers
			FROM orders_data
),
restaurant_summary AS
(
			SELECT 
                    COUNT(DISTINCT restaurant_name) AS unique_restaurants
			FROM orders_data
),
delivery_summary AS 
(
			SELECT 
			     SUM(CASE WHEN delivery_status = 'Delivered' THEN 1 ELSE 0 END ) AS delivered_orders,
                 SUM(CASE WHEN delivery_status = 'Cancelled' THEN 1 ELSE 0 END ) AS cancelled_orders,
				 ROUND(AVG(delivery_time_minutes),2) AS average_delivery_time
			FROM orders_data
)
SELECT
		   os.total_orders,
		   os.total_revenue,
		   os.average_order_value,
		   cs.unique_customers,
		   rs.unique_restaurants,
		   ds.delivered_orders,
           ds.cancelled_orders,
		   ds.average_delivery_time
FROM order_summary AS os
CROSS JOIN customer_summary AS cs
CROSS JOIN restaurant_summary AS rs
CROSS JOIN delivery_summary  AS ds;
       
-- Top Revenue-Generating Restaurant in Each City
WITH restaurant_rank AS
(
    SELECT
        city,
        restaurant_name,
        ROUND(SUM(order_value), 2) AS total_revenue,
        ROW_NUMBER() OVER(
            PARTITION BY city
            ORDER BY SUM(order_value) DESC
        ) AS revenue_rank
    FROM orders_data
    GROUP BY
        city,
        restaurant_name
)
SELECT
    city,
    restaurant_name,
    total_revenue,
    revenue_rank
FROM restaurant_rank
WHERE revenue_rank = 1
ORDER BY city;



















