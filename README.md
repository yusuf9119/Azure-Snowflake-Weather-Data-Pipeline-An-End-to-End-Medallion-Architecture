# 🌧️ Cardiff Weather Data Pipeline
An end-to-end data engineering project that ingests real-time weather forecast data for Cardiff, Wales, stores it in Azure Blob Storage, and transforms it through a Medallion Architecture in Snowflake for analysis.

## Architecture Diagram
<img width="1408" height="768" alt="datappeline" src="https://github.com/user-attachments/assets/b59ba11d-d83a-4747-b7ec-20646dc0819e" />

End-to-End Cardiff Weather Data Pipeline with Medallion Architecture


## Pipeline Overview
Open-Meteo API → Python Ingestion → Azure Blob Storage → Snowflake (Bronze → Silver → Gold)
The pipeline follows the Medallion Architecture pattern across three layers:

## Medallion architecture
🟫 Bronze (weather_project.bronze) — Raw JSON stored as VARIANT, unmodified source data
⬜ Silver (weather_project.silver) — Cleaned and flattened into structured rows
🟡 Gold (weather_project.gold) — Aggregated views ready for reporting and analysis


## ⚙️ Configuration
Python
The ingestion layer uses three libraries:

requests — calls the Open-Meteo forecast API
azure-storage-blob — handles the upload to Azure Blob Storage
python-dotenv — loads the Azure connection string from a local .env file, keeping credentials out of source code

Azure Blob Storage
The pipeline targets a container called cardiffdata within an Azure Storage account. Each run uploads a single file — cardiff_weather.json — and overwrites the previous version, keeping storage minimal.

Snowflake
Snowflake connects to Azure Blob via a Storage Integration (azure_weather_int), which handles secure authentication between the two cloud platforms without exposing credentials in SQL. An external stage points at the blob container and uses a JSON file format to read the raw data directly into Snowflake.

The three medallion schemas — bronze, silver, and gold — are all housed within the weather_project database.
