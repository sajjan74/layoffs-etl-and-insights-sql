-- `*#*` Data Cleaning `*#*`--

use world_layoffs;

select *
from layoffs;

-- 1 Remove Duplicates
-- 2 Standardize the Data
-- 3 Null Values or Blank values
-- 4 Remove unnecessary columns 

-- first create a new duplicte database

CREATE TABLE layoffs_staging
LIKE layoffs;

select *
from layoffs_staging;

INSERT layoffs_staging
SELECT *
from layoffs;


-- Find duplicate

select *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date',
stage, country, funds_raised_millions) as row_num
from layoffs_staging;
WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
            date, stage, country, funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- using CTEs Windows function find duplicate
-- cross check the output

select *
from layoffs_staging
where company = 'Elemy';

-- Now remove the duplicate 

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select *
from layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
date, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

select *
from layoffs_staging2
where 'row_num' > 1;

DELETE 
FROM layoffs_staging2
WHERE 'row_num' > 1; 

SELECT *
FROM layoffs_staging2;

-- 2 Standardizing data


SELECT company, TRIM(company)
from layoffs_staging2;

use world_layoffs;

-- Turn off safe mode
SET SQL_SAFE_UPDATES = 0;

UPDATE layoffs_staging2
SET company = TRIM(company); -- Trim remove the white spaces 

-- check industry column


SELECT DISTINCT industry
FROM layoffs_staging2
order by 1;

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'
;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Now 
SELECT DISTINCT country 
FROM layoffs_staging
order by 1;

select * 
from layoffs_staging
where country like 'United States%'
order by 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
from layoffs_staging2
order by 1; 

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert date column Text to Actual date column

SELECT `date`, 
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN 	`date` DATE;


-- 3 NULL AND BLANK VALUES

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
and percentage_laid_off is null;
 
update layoffs_staging2
set industry = null
where industry = '';

SELECT * 
FROM layoffs_staging2
WHERE industry = '' or
industry IS NULL;

select *
from layoffs_staging2
where company = 'Airbnb';


select t1.industry, t2.industry
from layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company = t2.company
set t1.company = t2.company
where t1.industry is null
and t2.industry is not null;

select *
from layoffs_staging2
where total_laid_off is null 
and percentage_laid_off is null;

delete 
from layoffs_staging2
where total_laid_off is null 
and percentage_laid_off is null;

select *
from layoffs_staging2;

 --  4 Remove column (unnecessary column)
 
 ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- `*#*` Exploratory Data Analysis `*#*` -- 
-- EDA

select * 
from layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2; 


select * 
from layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions desc;


select company, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY company
ORDER BY 2 DESC;

select MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY country
ORDER BY 2 DESC;

SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY `date`
ORDER BY 1 DESC;

 SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;


SELECT stage, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY stage
ORDER BY 1 DESC;

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,6,2) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;


-- ROLLING TOATAL OR CUMULATIVE SUM


WITH ROLLING_TOTAL AS 
(SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,6,2) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)

SELECT `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM ROLLING_TOTAL; 

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 desc;


WITH Company_year (company, years, total_laid_off) AS
(SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off desc) as Ranking
FROM Company_year
WHERE years IS NOT NULL
ORDER BY Ranking ASC;


WITH Company_year (company, years, total_laid_off) AS
(SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_year_rank as
(SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off desc) as Ranking
FROM Company_year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_year_rank
where Ranking <= 5;












