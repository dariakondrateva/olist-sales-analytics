WITH cat AS (
    SELECT category, SUM(price) AS revenue
    FROM v_sales
    GROUP BY category
)
SELECT category,
       revenue,
       ROUND(100.0 * revenue / SUM(revenue) OVER (), 1)                        AS share_pct,
       ROUND(100.0 * SUM(revenue) OVER (ORDER BY revenue DESC)
                   / SUM(revenue) OVER (), 1)                                  AS cum_share_pct
FROM cat
ORDER BY revenue DESC;