
AGRICONNECT FARM-TO-MARKET PLATFORM
PHASE 4: THE QUERY PACK - BUSINESS REPORTS
File: queries_basic.sql

USE agriconnect;


QUERY 1: Every farmer and their listed products
Business question:
Which products has each farmer listed?


SELECT u.full_name, p.product_name, p.unit_price
FROM users u
JOIN products p
    ON u.user_id = p.farmer_id;

============================================================

QUERY 2: Buyers with no orders yet
Business question:
Which buyers have not placed any orders?


SELECT u.full_name
FROM users u
LEFT JOIN orders o
    ON o.buyer_id = u.user_id
WHERE u.role <> 'FARMER'
  AND o.order_id IS NULL;

============================================================

QUERY 3: Total spent per buyer
Business question:
How much has each buyer spent on delivered orders?


SELECT u.full_name,
       SUM(o.total_amount) AS lifetime_spend
FROM users u
JOIN orders o
    ON o.buyer_id = u.user_id
WHERE o.status = 'DELIVERED'
GROUP BY u.user_id, u.full_name;

============================================================
 
QUERY 4: Products never ordered
Business question:
Which products have never appeared in an order?

SELECT product_name
FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id
    FROM order_items
);

============================================================

QUERY 5: Deliveries not yet dispatched
Business question:
Which orders have no dispatch time recorded?

SELECT o.order_id, d.driver_name
FROM orders o
LEFT JOIN deliveries d
    ON d.order_id = o.order_id
WHERE d.dispatched_at IS NULL;

============================================================

QUERY 6: Products with available stock
Business question:
Which products currently have stock available?

SELECT product_name, unit, unit_price, stock_qty
FROM products
WHERE stock_qty > 0;

============================================================

QUERY 7: Number of products listed by each farmer
Business question:
How many products has each farmer listed?

SELECT u.full_name,
       COUNT(p.product_id) AS number_of_products
FROM users u
JOIN products p
    ON u.user_id = p.farmer_id
GROUP BY u.user_id, u.full_name;

-- ============================================================

QUERY 8: Orders by status
Business question:
How many orders are in each order status?

SELECT status,
       COUNT(order_id) AS number_of_orders
FROM orders
GROUP BY status;

-- ============================================================

QUERY 9: Average product price by category
Business question:
What is the average selling price in each category?

SELECT category,
       AVG(unit_price) AS average_price
FROM products
GROUP BY category;

============================================================

QUERY 10: Highest-priced products
Business question:
Which products have the highest selling prices?

SELECT product_name, category, unit_price
FROM products
ORDER BY unit_price DESC;

============================================================

QUERY 11: Number of orders per buyer
Business question:
How many orders has each buyer made?

SELECT u.full_name,
       COUNT(o.order_id) AS number_of_orders
FROM users u
JOIN orders o
    ON u.user_id = o.buyer_id
GROUP BY u.user_id, u.full_name;

============================================================

QUERY 12: Total sales by farmer
Business question:
How much sales value has each farmer generated?

SELECT u.full_name,
       SUM(oi.line_total) AS total_sales
FROM users u
JOIN products p
    ON u.user_id = p.farmer_id
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY u.user_id, u.full_name;

============================================================

QUERY 13: Products with low stock
Business question:
Which products have stock below 50 units?

SELECT product_name, stock_qty, unit
FROM products
WHERE stock_qty < 50;

-- ============================================================

QUERY 14: Customer reviews with product information
Business question:
Which buyers reviewed which products and what ratings did they give?

SELECT u.full_name,
       p.product_name,
       r.rating,
       r.comment
FROM reviews r
JOIN users u
    ON r.buyer_id = u.user_id
JOIN products p
    ON r.product_id = p.product_id;

============================================================

QUERY 15: Wallet balances by user
Business question:
What is the current wallet balance of each user?

SELECT u.full_name,
       u.phone,
       w.wallet_id,
       w.balance
FROM users u
JOIN wallets w
    ON u.user_id = w.user_id;


