WITH monthly AS (
    SELECT order_month,
           SUM(price) AS revenue
    FROM v_sales
    GROUP BY order_month
),
yoy AS (
    SELECT order_month,
           revenue,
           LAG(revenue, 12) OVER (ORDER BY order_month) AS revenue_py
    FROM monthly
)
SELECT order_month,
       revenue                                                          AS fact,
       ROUND(revenue_py * 2.0, 2)                                       AS plan,
       ROUND(revenue - revenue_py * 2.0, 2)                             AS deviation,
       ROUND(100.0 * (revenue - revenue_py * 2.0) / (revenue_py * 2.0), 1) AS deviation_pct,
       ROUND(100.0 * (revenue - revenue_py) / revenue_py, 1)            AS yoy_pct
FROM yoy
WHERE order_month >= '2018-01-01'
ORDER BY order_month;

WITH monthly AS (
    SELECT order_month, SUM(price) AS revenue
    FROM v_sales
    GROUP BY order_month
),
yoy AS (
    SELECT order_month,
           revenue,
           LAG(revenue, 12) OVER (ORDER BY order_month) AS revenue_py
    FROM monthly
),
pf AS (
    SELECT order_month,
           revenue            AS fact,
           revenue_py * 2.0   AS plan
    FROM yoy
    WHERE order_month >= '2018-01-01'
)
SELECT order_month,
       ROUND(fact, 2) AS fact,
       ROUND(plan, 2) AS plan,
       ROUND(100.0 * fact / plan, 1) AS completion_month_pct,
       ROUND(SUM(fact) OVER w, 2)    AS fact_ytd,
       ROUND(SUM(plan) OVER w, 2)    AS plan_ytd,
       ROUND(100.0 * SUM(fact) OVER w / SUM(plan) OVER w, 1) AS completion_ytd_pct
FROM pf
WINDOW w AS (PARTITION BY EXTRACT(YEAR FROM order_month) ORDER BY order_month)
ORDER BY order_month;

WITH monthly AS (
    SELECT order_month,
           COUNT(DISTINCT order_id) AS orders,
           SUM(price)               AS revenue
    FROM v_sales
    GROUP BY order_month
),
cmp AS (
    SELECT order_month,
           orders   AS n1,
           revenue  AS r1,
           LAG(orders, 12)  OVER w AS n0,
           LAG(revenue, 12) OVER w AS r0
    FROM monthly
    WINDOW w AS (ORDER BY order_month)
)
SELECT order_month,
       r0                                         AS revenue_py,
       r1                                         AS revenue,
       ROUND(r1 - r0, 2)                          AS delta,
       ROUND((n1 - n0) * (r0 / n0), 2)            AS volume_effect,
       ROUND((r1 / n1 - r0 / n0) * n1, 2)         AS avg_check_effect,
       ROUND((r1 - r0) - (n1 - n0) * (r0 / n0)
                       - (r1 / n1 - r0 / n0) * n1, 2) AS check_diff
FROM cmp
WHERE order_month >= '2018-01-01'
ORDER BY order_month;