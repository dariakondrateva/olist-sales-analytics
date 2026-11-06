WITH daily AS (
    SELECT order_date, SUM(price) AS revenue
    FROM v_sales
    GROUP BY order_date
),
stats AS (
    SELECT order_date,
           revenue,
           AVG(revenue)         OVER w AS avg_28,
           STDDEV_SAMP(revenue) OVER w AS std_28
    FROM daily
    WINDOW w AS (ORDER BY order_date ROWS BETWEEN 28 PRECEDING AND 1 PRECEDING)
)
SELECT order_date,
       ROUND(revenue, 2)                                  AS revenue,
       ROUND(avg_28, 2)                                   AS avg_28,
       ROUND((revenue - avg_28) / NULLIF(std_28, 0), 2)   AS z_score
FROM stats
WHERE ABS((revenue - avg_28) / NULLIF(std_28, 0)) > 3
ORDER BY order_date;