SELECT order_status,
       COUNT(*) AS orders,
       MIN(order_purchase_timestamp)::date AS first_date,
       MAX(order_purchase_timestamp)::date AS last_date
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

SELECT
  (SELECT COUNT(*) FROM order_items oi
     LEFT JOIN orders o ON o.order_id = oi.order_id
     WHERE o.order_id IS NULL) AS items_without_order,
  (SELECT COUNT(*) FROM orders o
     LEFT JOIN order_items oi ON oi.order_id = o.order_id
     WHERE oi.order_id IS NULL) AS orders_without_items;

SELECT o.order_status, COUNT(*) AS orders_without_items
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
WHERE oi.order_id IS NULL
GROUP BY o.order_status
ORDER BY orders_without_items DESC;

SELECT DATE_TRUNC('month', order_purchase_timestamp)::date AS month,
       COUNT(*) AS orders
FROM orders
GROUP BY 1
ORDER BY 1;

SELECT
  (SELECT SUM(price) FROM order_items)          AS items_price,
  (SELECT SUM(freight_value) FROM order_items)  AS items_freight,
  (SELECT SUM(payment_value) FROM order_payments) AS payments_total;

WITH items AS (
    SELECT order_id, SUM(price + freight_value) AS items_total
    FROM order_items
    GROUP BY order_id
),
pay AS (
    SELECT order_id, SUM(payment_value) AS paid
    FROM order_payments
    GROUP BY order_id
)
SELECT o.order_status,
       COUNT(*) AS orders,
       ROUND(SUM(p.paid - COALESCE(i.items_total, 0)), 2) AS diff_total,
       COUNT(*) FILTER (WHERE ABS(p.paid - COALESCE(i.items_total, 0)) > 0.01) AS orders_with_diff
FROM orders o
JOIN pay p ON p.order_id = o.order_id
LEFT JOIN items i ON i.order_id = o.order_id
GROUP BY o.order_status
ORDER BY orders DESC;

