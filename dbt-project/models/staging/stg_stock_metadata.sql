WITH source AS (
    SELECT * FROM {{ ref('nifty50_sectors') }}
)

SELECT
    symbol,
    company_name,
    sector
FROM source
