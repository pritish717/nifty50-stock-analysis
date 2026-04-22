WITH prices AS (
    SELECT * FROM {{ ref('stg_stock_prices') }}
),

metadata AS (
    SELECT * FROM {{ ref('stg_stock_metadata') }}
),

joined AS (
    SELECT
        p.trade_date,
        p.symbol,
        m.company_name,
        m.sector,
        p.open_price,
        p.high_price,
        p.low_price,
        p.close_price,
        p.prev_close_price,
        p.vwap,
        p.volume,
        p.turnover,
        p.trades,
        p.deliverable_volume,
        p.delivery_pct,
        p.daily_return_pct,
        p.price_range,
        EXTRACT(YEAR FROM p.trade_date)   AS trade_year,
        EXTRACT(MONTH FROM p.trade_date)  AS trade_month
    FROM prices p
    LEFT JOIN metadata m USING (symbol)
)

SELECT * FROM joined
