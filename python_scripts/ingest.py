from extract import extract, process_stock_csvs_into_parquet, load_parquet_into_raw_tables


def etl_flow():
    extract()
    process_stock_csvs_into_parquet()
    load_parquet_into_raw_tables()


if __name__ == "__main__":
    etl_flow()
