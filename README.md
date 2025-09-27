# layoffs-etl-and-insights-sql
MySQL project cleaning and analyzing a world layoffs dataset: deduping with window functions, standardizing strings and countries, converting dates, fixing null/blank values, and producing company/industry/country trends, monthly rollups, rolling totals, and yearly top‑N rankings with DENSE_RANK.

Layoffs Data Cleaning and EDA (MySQL)
A focused SQL project that stages, cleans, and analyzes a global layoffs dataset using MySQL window functions, CTEs, date parsing, and ranking to produce reliable insights and time‑series trends.

Dataset and schema
Source table: layoffs(company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) in database world_layoffs.

Staging flow: layoffs → layoffs_staging → layoffs_staging2 for deduplication and standardized transformations before analysis.

Cleaning steps
Deduplicate with ROW_NUMBER() over business keys; delete rows where row_num > 1 after loading to layoffs_staging2.

Standardize strings: TRIM company; unify industry values such as Crypto; normalize country names like United States by removing trailing periods.

Convert date text to DATE using STR_TO_DATE('%m/%d/%Y') and ALTER TABLE to enforce type correctness.

Treat blanks as NULL, backfill missing industry via self‑join on company, and remove rows where both total_laid_off and percentage_laid_off are NULL.

Drop helper column row_num once de‑duplication is complete to finalize the cleaned table.

Exploratory queries
Extremes: MAX(total_laid_off) and records with percentage_laid_off = 1 ordered by funds raised.

Aggregates by company, industry, country, and calendar date to profile magnitude and distribution of layoffs.

Time series: monthly rollups with SUBSTRING(date,1,7); rolling cumulative totals via window SUM over month order.

Rankings: top companies by layoffs per year using CTEs with DENSE_RANK for clear yearly leaderboards.

How to run
Create database and load raw table layoffs, then execute SQL-Project.sql in MySQL Workbench or CLI to build staging, clean data, and run EDA queries end‑to‑end.

Results are returned as query outputs; copy or export result sets for reporting and visualization as needed.

Notes and improvements
Replace quoted identifiers like 'row_num' with bare identifiers or backticks when filtering to avoid literal‑string bugs in DELETE/SELECT predicates.

In the backfill step, set t1.industry = t2.industry in the self‑join update to correctly propagate non‑null industry values across the same company.

Files
SQL-Project.sql — complete script for staging, cleaning, and exploratory analytics on the layoffs dataset.
