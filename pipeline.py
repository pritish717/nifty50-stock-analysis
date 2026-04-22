import subprocess
import os
from prefect import flow, task, get_run_logger


@task(name="ingest", retries=2, retry_delay_seconds=30)
def ingest():
    logger = get_run_logger()
    logger.info("Starting NIFTY-50 data ingestion...")
    result = subprocess.run(
        ["python", "python_scripts/ingest.py"],
        capture_output=True,
        text=True,
        env={**os.environ},
    )
    if result.returncode != 0:
        logger.error(result.stderr)
        raise RuntimeError(f"Ingest failed:\n{result.stderr}")
    logger.info(result.stdout)
    logger.info("Ingestion complete.")


@task(name="dbt-debug", retries=1)
def dbt_debug():
    logger = get_run_logger()
    logger.info("Debugging dbt configuration...")
    result = subprocess.run(
        ["dbt", "debug", "--project-dir", "dbt-project", "--profiles-dir", "dbt-project"],
        capture_output=True,
        text=True,
        env={**os.environ, "DBT_PROFILES_DIR": os.environ.get("DBT_PROFILES_DIR", "dbt-project")},
    )
    if result.returncode != 0:
        logger.error(f"STDOUT:\n{result.stdout}")
        logger.error(f"STDERR:\n{result.stderr}")
        raise RuntimeError(f"dbt debug failed:\n{result.stdout}\n{result.stderr}")
    logger.info(result.stdout)


@task(name="dbt-seed", retries=1)
def dbt_seed():
    logger = get_run_logger()
    logger.info("Running dbt seed...")
    result = subprocess.run(
        ["dbt", "seed", "--project-dir", "dbt-project", "--profiles-dir", "dbt-project"],
        capture_output=True,
        text=True,
        env={**os.environ, "DBT_PROFILES_DIR": os.environ.get("DBT_PROFILES_DIR", "dbt-project")},
    )
    if result.returncode != 0:
        logger.error(f"STDOUT:\n{result.stdout}")
        logger.error(f"STDERR:\n{result.stderr}")
        raise RuntimeError(f"dbt seed failed:\n{result.stdout}\n{result.stderr}")
    logger.info(result.stdout)


@task(name="dbt-run", retries=1)
def dbt_run():
    logger = get_run_logger()
    logger.info("Running dbt models...")
    result = subprocess.run(
        ["dbt", "run", "--project-dir", "dbt-project", "--profiles-dir", "dbt-project"],
        capture_output=True,
        text=True,
        env={**os.environ, "DBT_PROFILES_DIR": os.environ.get("DBT_PROFILES_DIR", "dbt-project")},
    )
    if result.returncode != 0:
        logger.error(f"STDOUT:\n{result.stdout}")
        logger.error(f"STDERR:\n{result.stderr}")
        raise RuntimeError(f"dbt run failed:\n{result.stdout}\n{result.stderr}")
    logger.info(result.stdout)


@task(name="dbt-test", retries=1)
def dbt_test():
    logger = get_run_logger()
    logger.info("Running dbt tests...")
    result = subprocess.run(
        ["dbt", "test", "--project-dir", "dbt-project", "--profiles-dir", "dbt-project"],
        capture_output=True,
        text=True,
        env={**os.environ, "DBT_PROFILES_DIR": os.environ.get("DBT_PROFILES_DIR", "dbt-project")},
    )
    if result.returncode != 0:
        logger.error(f"STDOUT:\n{result.stdout}")
        logger.error(f"STDERR:\n{result.stderr}")
        raise RuntimeError(f"dbt test failed:\n{result.stdout}\n{result.stderr}")
    logger.info(result.stdout)


@flow(name="nifty50-pipeline", log_prints=True)
def nifty50_pipeline():
    ingest_result = ingest()
    debug_result = dbt_debug(wait_for=[ingest_result])
    seed_result = dbt_seed(wait_for=[debug_result])
    run_result = dbt_run(wait_for=[seed_result])
    dbt_test(wait_for=[run_result])


if __name__ == "__main__":
    nifty50_pipeline()
