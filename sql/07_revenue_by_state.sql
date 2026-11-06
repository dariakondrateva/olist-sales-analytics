SELECT customer_state,
       COUNT(DISTINCT order_id)                                AS orders,
       SUM(price)                                              AS revenue,
       ROUND(100.0 * SUM(price) / SUM(SUM(price)) OVER (), 1)  AS share_pct,
       ROUND(SUM(price) / COUNT(DISTINCT order_id), 2)         AS avg_order_value
FROM v_sales
GROUP BY customer_state
ORDER BY revenue DESC;