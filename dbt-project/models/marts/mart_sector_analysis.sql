WITH monthly AS (
    SELECT * FROM {{ ref('mart_monthly_performance') }}
),

sector_monthly AS (
    SELECT
        trade_year,
        trade_month,
        sector,

        COUNT(DISTINCT symbol)                             AS stock_count,
        ROUND(AVG(monthly_return_pct), 4)                  AS avg_monthly_return_pct,
        ROUND(AVG(daily_return_stddev), 4)                 AS avg_volatility,
        SUM(total_volume)                                  AS sector_total_volume,
        SUM(total_turnover)                                AS sector_total_turnover,
        ROUND(AVG(avg_delivery_pct), 4)                    AS avg_delivery_pct,

        -- Best and worst performing stocks in sector
        MAX(monthly_return_pct)                            AS best_stock_return_pct,
        MIN(monthly_return_pct)                            AS worst_stock_return_pct

    FROM monthly
    WHERE sector IS NOT NULL
    GROUP BY trade_year, trade_month, sector
)

SELECT * FROM sector_monthly
