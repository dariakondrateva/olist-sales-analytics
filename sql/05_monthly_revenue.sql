WITH monthly AS (
    SELECT order_month,
           COUNT(DISTINCT order_id) AS orders,
           SUM(price)               AS revenue
    FROM v_sales
    GROUP BY order_month
)
SELECT order_month,
       orders,
       revenue,
       ROUND(revenue / orders, 2) AS avg_order_value,
       LAG(revenue) OVER (ORDER BY order_month) AS prev_revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY order_month))
             / LAG(revenue) OVER (ORDER BY order_month), 1) AS revenue_mom_pct
FROM monthly
ORDER BY order_month;