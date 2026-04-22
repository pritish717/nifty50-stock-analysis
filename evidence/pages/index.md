---
title: NIFTY-50 Stock Market Analysis Dashboard
full_width: true
---

<style>
  :global(.max-w-7xl) { max-width: none !important; }
  :global(main.flex-grow) { max-width: none !important; }
  :global(article#evidence-main-article) {
    max-width: none !important;
    width: 100% !important;
  }
  :global(.markdown) { max-width: none !important; }

  :global(aside.w-48) { width: 8rem !important; }
  :global(aside.w-48 > div.w-48) { width: 8rem !important; }
</style>

<Details title='Project Summary'>
This project analyzes daily trading data for India's NIFTY-50 index constituents. The pipeline extracts historical stock data from Kaggle, loads it into DuckDB, transforms it using dbt, and visualizes key metrics here using Evidence. The dataset covers ~20 years of daily OHLCV data across 50 of India's largest publicly listed companies.
</Details>

## Monthly Return by Sector

```sql sector_monthly_returns
select
    make_date(cast(trade_year as integer), cast(trade_month as integer), 1) as month_date,
    sector,
    round(avg_monthly_return_pct, 2) as avg_return_pct
from warehouse.mart_sector_analysis
where sector is not null
order by month_date, sector
```

<LineChart
    data={sector_monthly_returns}
    x=month_date
    y=avg_return_pct
    series=sector
    title="Average monthly return by sector (%)"
    yAxisTitle="Return %"
    xAxisTitle="Month"
/>

## Stock Volatility Overview

```sql volatility_overview
select
    symbol,
    company_name,
    sector,
    overall_daily_volatility,
    total_return_pct,
    win_rate_pct,
    total_trading_days
from warehouse.mart_stock_volatility
where overall_daily_volatility is not null
order by overall_daily_volatility desc
```

<ScatterPlot
    data={volatility_overview}
    x=overall_daily_volatility
    y=total_return_pct
    series=sector
    title="Risk vs Return: Daily volatility vs total return"
    xAxisTitle="Daily volatility (std dev of returns)"
    yAxisTitle="Total return (%)"
/>

## Top Performers by Total Return

```sql top_performers
select
    symbol,
    company_name,
    sector,
    total_return_pct,
    win_rate_pct,
    overall_daily_volatility,
    max_single_day_gain_pct,
    max_single_day_loss_pct
from warehouse.mart_stock_volatility
where total_return_pct is not null
order by total_return_pct desc
limit 15
```

<BarChart
    data={top_performers}
    x=symbol
    y=total_return_pct
    title="Top 15 stocks by total return (%)"
    yAxisTitle="Total return %"
    labels=true
    colorPalette={['#27ae60']}
/>

<DataTable
    data={top_performers}
    title="Top 15 performers - detailed stats"
    rows=15
>
    <Column id=symbol title="Symbol" />
    <Column id=company_name title="Company" />
    <Column id=sector title="Sector" />
    <Column id=total_return_pct title="Total return %" fmt="0.2" />
    <Column id=win_rate_pct title="Win rate %" fmt="0.1" />
    <Column id=overall_daily_volatility title="Volatility" fmt="0.4" />
    <Column id=max_single_day_gain_pct title="Best day %" fmt="0.2" />
    <Column id=max_single_day_loss_pct title="Worst day %" fmt="0.2" />
</DataTable>

## Sector Performance Summary

```sql sector_summary
select
    sector,
    round(avg(avg_monthly_return_pct), 2) as avg_return,
    round(avg(avg_volatility), 4) as avg_volatility,
    round(sum(sector_total_turnover), 0) as total_turnover,
    count(distinct trade_year || '-' || trade_month) as months_tracked
from warehouse.mart_sector_analysis
where sector is not null
group by sector
order by avg_return desc
```

<DataTable
    data={sector_summary}
    title="Sector summary across all months"
    rows=20
>
    <Column id=sector title="Sector" />
    <Column id=avg_return title="Avg monthly return %" fmt="0.2" />
    <Column id=avg_volatility title="Avg volatility" fmt="0.4" />
    <Column id=total_turnover title="Total turnover (INR)" fmt="0,0" />
    <Column id=months_tracked title="Months tracked" />
</DataTable>
