-- =====================================================================
-- Витрина v_sales: одна строка = одна позиция доставленного заказа
-- Период: 2017-01-01 .. 2018-08-31 (полные месяцы, см. README)
-- Выручка = SUM(price), доставка (freight_value) учитывается отдельно
-- =====================================================================
CREATE OR REPLACE VIEW v_sales AS
SELECT o.order_id,
       oi.order_item_id,
       o.order_purchase_timestamp::date                       AS order_date,
       DATE_TRUNC('month', o.order_purchase_timestamp)::date  AS order_month,
       c.customer_state,
       COALESCE(t.product_category_name_english,
                NULLIF(TRIM(p.product_category_name), ''),
                'unknown')                                    AS category,
       oi.product_id,
       oi.seller_id,
       oi.price,
       oi.freight_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN customers c    ON c.customer_id = o.customer_id
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation t
       ON t.product_category_name = p.product_category_name
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp <  '2018-09-01';

-- Проверка 1: витрина vs источник (должно совпасть: 109 880 строк и 13 181 027,13)
SELECT COUNT(*) AS rows_cnt,
       COUNT(DISTINCT order_id) AS orders_cnt,
       SUM(price) AS revenue
FROM v_sales;

SELECT COUNT(*) AS rows_cnt,
       SUM(oi.price) AS revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp <  '2018-09-01';

-- Проверка 2: позиции без категории (ожидаем 1 535)
SELECT category, COUNT(*) AS items
FROM v_sales
WHERE category = 'unknown'
GROUP BY category;