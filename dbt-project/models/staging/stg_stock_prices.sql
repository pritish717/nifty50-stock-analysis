WITH source AS (
    SELECT * FROM {{ source('raw', 'stock_prices') }}
),

renamed AS (
    SELECT
        TRY_CAST("Date" AS DATE)                          AS trade_date,
        TRIM("Symbol")                                    AS symbol,

        TRY_CAST("Prev Close" AS DOUBLE)                  AS prev_close_price,
        TRY_CAST("Open" AS DOUBLE)                        AS open_price,
        TRY_CAST("High" AS DOUBLE)                        AS high_price,
        TRY_CAST("Low" AS DOUBLE)                         AS low_price,
        TRY_CAST("Last" AS DOUBLE)                        AS last_price,
        TRY_CAST("Close" AS DOUBLE)                       AS close_price,
        TRY_CAST("VWAP" AS DOUBLE)                        AS vwap,

        TRY_CAST("Volume" AS BIGINT)                      AS volume,
        TRY_CAST("Turnover" AS DOUBLE)                    AS turnover,
        TRY_CAST("Trades" AS BIGINT)                      AS trades,
        TRY_CAST("Deliverable Volume" AS BIGINT)          AS deliverable_volume,
        TRY_CAST("%Deliverble" AS DOUBLE)                 AS delivery_pct,

        -- Computed columns
        CASE
            WHEN TRY_CAST("Prev Close" AS DOUBLE) IS NOT NULL
                 AND TRY_CAST("Prev Close" AS DOUBLE) > 0
            THEN ROUND(
                (TRY_CAST("Close" AS DOUBLE) - TRY_CAST("Prev Close" AS DOUBLE))
                / TRY_CAST("Prev Close" AS DOUBLE) * 100, 4
            )
        END                                               AS daily_return_pct,

        TRY_CAST("High" AS DOUBLE) - TRY_CAST("Low" AS DOUBLE) AS price_range

    FROM source
    WHERE TRY_CAST("Date" AS DATE) IS NOT NULL
      AND TRIM("Symbol") IS NOT NULL
      AND TRIM("Symbol") != ''
)

SELECT * FROM renamed
