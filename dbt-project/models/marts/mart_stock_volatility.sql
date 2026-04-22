WITH daily AS (
    SELECT * FROM {{ ref('int_daily_trading') }}
),

stock_stats AS (
    SELECT
        symbol,
        company_name,
        sector,

        COUNT(*)                                           AS total_trading_days,
        MIN(trade_date)                                    AS first_trade_date,
        MAX(trade_date)                                    AS last_trade_date,

        -- Overall return
        FIRST(close_price ORDER BY trade_date)             AS first_close,
        LAST(close_price ORDER BY trade_date)              AS last_close,

        -- Volatility
        ROUND(STDDEV(daily_return_pct), 4)                 AS overall_daily_volatility,
        ROUND(AVG(daily_return_pct), 4)                    AS avg_daily_return_pct,

        -- Volume profile
        ROUND(AVG(volume), 0)                              AS avg_daily_volume,
        ROUND(AVG(delivery_pct), 4)                        AS avg_delivery_pct,

        -- Extremes
        MAX(daily_return_pct)                              AS max_single_day_gain_pct,
        MIN(daily_return_pct)                              AS max_single_day_loss_pct,
        MAX(high_price)                                    AS all_time_high,
        MIN(low_price)                                     AS all_time_low,

        -- Risk metrics
        COUNT(CASE WHEN daily_return_pct < 0 THEN 1 END)  AS negative_days,
        COUNT(CASE WHEN daily_return_pct >= 0 THEN 1 END) AS positive_days

    FROM daily
    GROUP BY symbol, company_name, sector
),

with_derived AS (
    SELECT
        *,
        CASE
            WHEN first_close > 0
            THEN ROUND((last_close - first_close) / first_close * 100, 2)
        END AS total_return_pct,
        ROUND(positive_days * 100.0 / NULLIF(total_trading_days, 0), 2) AS win_rate_pct
    FROM stock_stats
)

SELECT * FROM with_derived
