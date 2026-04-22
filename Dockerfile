FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y git
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY python_scripts/ ./python_scripts/
COPY dbt-project/ ./dbt-project/
COPY pipeline.py pipeline.py

ENV PYTHONUNBUFFERED=1
ENV PREFECT_API_URL=http://prefect-server:4200/api

ENTRYPOINT ["python", "pipeline.py"]
