# Project - Data Cleaning

SELECT *
FROM layoffs;

-- Data Cleaning Process:
-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Handle null or blank values
-- 4. Remove any neccessary columns

-- Create copy of layoffs table
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

-- Move content from layoffs table to layoffs_staging table layoffs
INSERT layoffs_staging
SELECT *
FROM layoffs;

-- 1. Remove duplicates

-- Create a query that creates a row_num table with unique IDs 
-- and partitions by different columns

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

-- Create a CTE for the statement above that verifies the duplicate rows from all columns.

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`,
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)

-- Select the duplicate_cte and check if row_num is greater than 1. 
-- If so, those are the duplicates.

SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- In this stage, verify that all companies in duplicate section
-- have duplicate in it. In this step, we are checking if company
-- "Casper" who appeared in duplicate section have duplicate rows
-- that needs to be removed!

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- We now have to create a new table name "layoffs_staging2"
-- to remove the duplicates instead with the new column "row_num"
-- which acts as the filter/sorter.

-- The old duplicate_cte again

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`,
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- The new created table "layoffs_staging2"

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
`row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

-- We transfered all data from table "layoffs_staging" to
-- "layoffs_staging2" and hence created a new table with the
-- addiditonal column "row_num".

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`,
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Select the new table "layoffs_Staging2" to verify
-- that it actually works. Also putting in the WHERE clause
-- to verify row_num > 1, which means that those
-- rows are duplicates.

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Now, remove all duplicates.

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Now, verify that the duplicates are removed.

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Open up the full table again to verify.

SELECT *
FROM layoffs_staging2;

-- Done!

# -----------------------------------------------------------------------------#

-- 2. Standardizing the data 
-- (Finding issues with the data and fix it)

--  I. Fix the spacing in beginning and remove it from
-- the data in company column

SELECT company, TRIM(company)
FROM layoffs_staging2;

-- Update the layoffs_staging2
-- table with the TRIM values/data

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Review the industry column

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- II. We have found that the term "Crypto", "Crypto Currency" and "CryptoCurrency"
-- We want to change those 3 terms to only "Crypto".

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Updating the data in industry column to only Crypto.

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- The script below checks every single column with unique values
-- (change column name to verify that specific data)

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- III. We have found in the country table that there are 2 US countries.
-- One is "United States" and the other one is "United States."
-- We want to remove the other one for sure.

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

-- Update the table again 

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- IIII. We now want to update the date column. The data 
-- type for date is "text", we want to change it to "date" 
-- type instead.

-- Formatting here.
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- Updating the table with the new data.
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Verify that the column updated correctly.
SELECT `date`
FROM layoffs_staging2;

-- V. Actually convert the date format to real date type
-- by updating the table column "date".

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Verify the table again

SELECT *
FROM layoffs_staging2;

-- Done!

# -----------------------------------------------------------------------------#

-- 3. Handle null or blank values

-- I. We are looking for NULL OR BLANK values in the 
-- "industry" column.

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- II. We are populating the values that are
-- already BLANK to NULL values for consistency. 

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- III. We are verifying the company that have NULL or BLANK
-- value. In this case, we are searching in the 
-- company "Airbnb". 

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- IIII. In this query, we are JOINING the 
-- same table to look for NULL and BLANK
-- values across the full table in the "industry"
-- column by checking if t1 is NULL or BLANK and t2
-- is not NULL. 

SELECT t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- V. We are now updating the table 

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- VI. We are now verifying the table again.

SELECT *
FROM layoffs_staging2;

-- Done!

# -----------------------------------------------------------------------------#

-- 4. Remove any neccessary columns or rows

-- I. We are looking for NULL values in the 
-- "total_laid_off" column and the "percentage_laid_off"
-- column.

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- II. We are now deleting those rows where the
-- column "total_laid_off" and the column
-- "percentage_laid_off" is NULL

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Verifying that it worked as it should.

SELECT *
FROM layoffs_staging2;

-- III. Also, we want to remove the "row_num"
-- column because its not to any use now.

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Verifying that it worked as it should again.

SELECT *
FROM layoffs_staging2;

-- Done!