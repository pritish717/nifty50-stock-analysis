import subprocess
import zipfile
from pathlib import Path
import pandas as pd
import duckdb

cwd = Path.cwd()  # /app
data_dir = f"{cwd}/data"
_duckdb_path = f"{data_dir}/warehouse.duckdb"
raw_dir = f"{data_dir}/raw"
processed_dir = f"{data_dir}/processed"

KAGGLE_DATASET = "rohanrao/nifty50-stock-market-data"


def extract():
    """Download NIFTY-50 dataset from Kaggle and unzip."""
    Path(raw_dir).mkdir(parents=True, exist_ok=True)

    zip_path = f"{raw_dir}/nifty50-stock-market-data.zip"

    print("Downloading NIFTY-50 dataset from Kaggle...")
    result = subprocess.run(
        [
            "kaggle", "datasets", "download",
            "-d", KAGGLE_DATASET,
            "-p", raw_dir,
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(f"Kaggle download failed:\n{result.stderr}")
    print(result.stdout)

    print("Unzipping dataset...")
    with zipfile.ZipFile(zip_path, "r") as zf:
        zf.extractall(raw_dir)
    Path(zip_path).unlink()
    print("Extraction complete.")


def process_stock_csvs_into_parquet():
    """Read all individual stock CSVs, union them into a single parquet file."""
    Path(processed_dir).mkdir(parents=True, exist_ok=True)
    raw_path = Path(raw_dir)

    csv_files = list(raw_path.glob("*.csv"))
    if not csv_files:
        raise FileNotFoundError(f"No CSV files found in {raw_dir}")

    df_list = []
    for f in csv_files:
        print(f"Processing {f.name}...")
        df = pd.read_csv(f)
        df_list.append(df)

    combined = pd.concat(df_list, ignore_index=True)

    numeric_cols = [
        "Prev Close", "Open", "High", "Low", "Last", "Close",
        "VWAP", "Volume", "Turnover", "Trades",
        "Deliverable Volume", "%Deliverble",
    ]
    for col in numeric_cols:
        if col in combined.columns:
            combined[col] = pd.to_numeric(combined[col], errors="coerce")

    out_path = Path(processed_dir) / "stock_prices.parquet"
    combined.to_parquet(out_path, index=False, compression="snappy")
    print(f"Combined {len(csv_files)} stock files into {out_path} ({len(combined)} rows)")


def load_parquet_into_raw_tables():
    """Create DuckDB views over the parquet files."""
    run_in_duckdb("CREATE SCHEMA IF NOT EXISTS raw;")

    for f in Path(processed_dir).glob("*.parquet"):
        print(f"Loading {f.name} into DuckDB...")
        run_in_duckdb(
            f"CREATE OR REPLACE VIEW {f.stem} AS SELECT * FROM read_parquet('{f}');",
            schema="raw",
        )
    print("Raw tables loaded.")


def run_in_duckdb(query: str, schema: str = None):
    try:
        con = duckdb.connect(_duckdb_path)
        if schema:
            query = f"USE {schema}; {query}"
        result = con.sql(query)
        if result is not None:
            return result.fetchdf()
        print(f"Query executed: {query}")
        return result
    except Exception as e:
        print(f"Error executing query: {query}, error: {e}")
        raise e
