WITH daily AS (
    SELECT * FROM {{ ref('int_daily_trading') }}
),

monthly_agg AS (
    SELECT
        trade_year,
        trade_month,
        symbol,
        company_name,
        sector,

        -- Price metrics
        FIRST(open_price ORDER BY trade_date)              AS month_open,
        LAST(close_price ORDER BY trade_date)              AS month_close,
        MAX(high_price)                                    AS month_high,
        MIN(low_price)                                     AS month_low,

        -- Volume metrics
        SUM(volume)                                        AS total_volume,
        ROUND(AVG(volume), 0)                              AS avg_daily_volume,
        SUM(turnover)                                      AS total_turnover,
        SUM(trades)                                        AS total_trades,

        -- Delivery metrics
        ROUND(AVG(delivery_pct), 4)                        AS avg_delivery_pct,

        -- Return and volatility
        ROUND(AVG(daily_return_pct), 4)                    AS avg_daily_return_pct,
        ROUND(STDDEV(daily_return_pct), 4)                 AS daily_return_stddev,
        COUNT(*)                                           AS trading_days,

        -- Best and worst days
        MAX(daily_return_pct)                              AS best_day_return_pct,
        MIN(daily_return_pct)                              AS worst_day_return_pct

    FROM daily
    GROUP BY trade_year, trade_month, symbol, company_name, sector
),

with_monthly_return AS (
    SELECT
        *,
        CASE
            WHEN month_open > 0
            THEN ROUND((month_close - month_open) / month_open * 100, 4)
        END AS monthly_return_pct
    FROM monthly_agg
)

SELECT * FROM with_monthly_return
