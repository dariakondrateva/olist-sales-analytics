WITH monthly AS (
    SELECT order_month, SUM(price) AS revenue
    FROM v_sales
    GROUP BY order_month
),
fc AS (
    SELECT order_month,
           revenue,
           LAG(revenue, 1) OVER (ORDER BY order_month)                      AS forecast_naive,
           AVG(revenue) OVER (ORDER BY order_month
                              ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING)     AS forecast_ma3
    FROM monthly
),
err AS (
    SELECT order_month, revenue, forecast_naive, forecast_ma3,
           100.0 * ABS(revenue - forecast_naive) / revenue AS ape_naive,
           100.0 * ABS(revenue - forecast_ma3)   / revenue AS ape_ma3
    FROM fc
    WHERE order_month >= '2018-01-01'
)
SELECT order_month,
       ROUND(revenue, 0)         AS fact,
       ROUND(forecast_naive, 0)  AS fc_naive,
       ROUND(forecast_ma3, 0)    AS fc_ma3,
       ROUND(ape_naive, 1)       AS ape_naive,
       ROUND(ape_ma3, 1)         AS ape_ma3,
       ROUND(AVG(ape_naive) OVER (), 1) AS mape_naive,
       ROUND(AVG(ape_ma3)   OVER (), 1) AS mape_ma3
FROM err
ORDER BY order_month;