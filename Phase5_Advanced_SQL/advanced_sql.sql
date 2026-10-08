-- ============================================================
-- AGRICONNECT FARM-TO-MARKET PLATFORM
-- PHASE 5: ADVANCED SQL
-- CTEs, Window Functions and Views
-- File: advanced_sql.sql
-- ============================================================

USE agriconnect;


-- ============================================================
-- QUERY 1: Top 3 products per category
-- Concept: CTE + ROW_NUMBER() window function
-- ============================================================

WITH prod_sales AS (
    SELECT p.category,
           p.product_name,
           SUM(oi.qty) AS total_qty
    FROM order_items oi
    JOIN products p
        ON p.product_id = oi.product_id
    GROUP BY p.category, p.product_name
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY category
               ORDER BY total_qty DESC
           ) AS rnk
    FROM prod_sales
)
SELECT category,
       product_name,
       total_qty
FROM ranked
WHERE rnk <= 3;


-- ============================================================
-- QUERY 2: Month-over-month platform revenue
-- Concept: CTE + LAG() window function
-- ============================================================

WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS yr_mo,
           SUM(total_amount) AS rev
    FROM orders
    WHERE status = 'DELIVERED'
    GROUP BY yr_mo
)
SELECT yr_mo,
       rev,
       rev - LAG(rev) OVER (ORDER BY yr_mo) AS change_prev,
       ROUND(
           100 * (rev - LAG(rev) OVER (ORDER BY yr_mo))
           / NULLIF(LAG(rev) OVER (ORDER BY yr_mo), 0),
           1
       ) AS pct_change
FROM monthly;


-- ============================================================
-- QUERY 3: Farmer earnings leaderboard with rank
-- Concept: RANK() window function + 5% commission
-- ============================================================

SELECT u.full_name,
       SUM(oi.line_total) * 0.95 AS net_earnings,
       RANK() OVER (
           ORDER BY SUM(oi.line_total) DESC
       ) AS farmer_rank
FROM order_items oi
JOIN products p
    ON p.product_id = oi.product_id
JOIN users u
    ON u.user_id = p.farmer_id
GROUP BY u.user_id, u.full_name;


-- ============================================================
-- VIEW 1: Reusable farmer earnings report
-- Concept: SQL VIEW
-- ============================================================

CREATE VIEW v_farmer_earnings AS
SELECT p.farmer_id,
       u.full_name,
       SUM(oi.line_total) AS gross,
       SUM(oi.line_total) * 0.95 AS net
FROM order_items oi
JOIN products p
    ON p.product_id = oi.product_id
JOIN users u
    ON u.user_id = p.farmer_id
GROUP BY p.farmer_id, u.full_name;


-- ============================================================
-- VIEW 2: Reusable product catalogue
-- Concept: SQL VIEW + calculated stock availability
-- ============================================================

CREATE VIEW v_catalog AS
SELECT product_id,
       product_name,
       category,
       unit,
       unit_price,
       stock_qty > 0 AS in_stock
FROM products
WHERE is_active = TRUE;


