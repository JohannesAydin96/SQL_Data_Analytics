# Project II - Exploratory Data Analysis

SELECT * 
FROM layoffs_staging2;

-- I. We are exploring the column "total_laid_off"
-- and "percentage_laid_off" for analyzing and eventually 
-- clean it up if needed.

-- II. For the two queries below, we look at the amount of
-- total laid offs and the percentage of those
-- laid off a company has.

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- III. We are looking for the company that have the most
-- laid offs in total and at the same time got rid
-- of all employees of the company.

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- IV. In this query below, we are looking
-- at the company that has laid off
-- the most employees at the same time
-- in total amount.

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- V. In this query below, we are looking
-- at the industry that got impacted the most 
-- and that has laid off the most employees at 
-- the same time in total amount.

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- The query below just checks the date
-- range of our data set.

SELECT MIN(date), MAX(date)
FROM layoffs_staging2;

-- VI. In this query below, we are looking
-- at the country that got impacted the most 
-- and that has laid off the most employees at 
-- the same time in total amount.

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- VII. In this query below, we are looking
-- at the date time (year) that got impacted the most 
-- and that has laid off the most employees at 
-- the same time in total amount.

SELECT YEAR(`date`),  SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- VIII. In this query below, we are aiming to 
-- create a rolling sum by looking
-- at the date time (year and month) when the data set started
-- and ended by looking at the total laid offs at every month
-- in the specific year.

SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`,  SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- IX. We are creating a CTE named
-- "Rolling_Total" based on the query
-- above.

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`,  SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER (ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;


-- X. In this query below, we are creating a new CTE
-- named "Company_Year", where we look at the year for
-- each company when the total laid off was at the highest.
-- Also, we are creating an another CTE, named "Company_Year_Rank",
-- where we rank that specific company who had the most laid off.

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

