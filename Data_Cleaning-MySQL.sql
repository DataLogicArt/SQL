-- Data cleaning
-- 1. Remove Duplicates
-- 2. Standartize Data
-- 3. Null Values Or blank Values
-- 4. Remove unnecessary Colums


SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- Create the New Table to work on that, and add 1 colum for filtering duplicate and delete duplicate rows
CREATE TABLE `layoffsanalys` (
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

SELECT *
FROM `layoffsanalys`;

INSERT INTO `layoffsanalys`
SELECT *,
ROW_NUMBER () OVER(partition by
 company,location,industry, total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions) AS row_num
 FROM layoffs;
  
 SELECT *
FROM `layoffsanalys`
WHERE row_num > 1;

DELETE
FROM `layoffsanalys`
WHERE row_num > 1;

-- 2. Standartize Data

SELECT distinct(company)
FROM `layoffsanalys`;

UPDATE `layoffsanalys`
SET company = TRIM(company);

SELECT distinct(industry)
FROM `layoffsanalys`
ORDER BY industry ;

SELECT *
FROM `layoffsanalys`
WHERE industry LIKE 'Crypto%';

UPDATE `layoffsanalys`
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT distinct(industry)
FROM `layoffsanalys`
ORDER BY industry ;

SELECT distinct(location)
FROM `layoffsanalys`
ORDER BY 1 ;

SELECT distinct(country), TRIM(TRAILING'.' FROM (country))
FROM `layoffsanalys`
ORDER BY 1 ;

UPDATE `layoffsanalys`
SET country = TRIM(TRAILING'.' FROM (country))
WHERE country LIKE 'United States%';

-- Change date from text type to date type, formatting first

SELECT date, str_to_date(date,'%m/%d/%Y')
FROM layoffsanalys;

UPDATE `layoffsanalys`
SET date = str_to_date(date,'%m/%d/%Y');

SELECT date
FROM layoffsanalys;

-- Change data type from text to date in the table 

ALTER TABLE layoffsanalys
MODIFY COLUMN date Date;


-- 3. Null Values Or blank Values

SELECT DISTINCT industry
FROM layoffsanalys
ORDER BY 1;

SELECT industry
FROM layoffsanalys
WHERE industry IS NULL OR industry = '';

SELECT *
FROM layoffsanalys t1
JOIN layoffsanalys t2
     ON t1.company = t2.company
     AND t1.country = t2.country
WHERE (t1.industry IS NULL OR t1.industry  = '' )
AND t2.industry IS NOT NULL;

SELECT t1.industry, t2.industry
FROM layoffsanalys t1
JOIN layoffsanalys t2
     ON t1.company = t2.company
     AND t1.country = t2.country
WHERE (t1.industry IS NULL OR t1.industry  = '' )
AND t2.industry IS NOT NULL;

UPDATE layoffsanalys
SET industry =  NULL 
WHERE industry = '';

UPDATE layoffsanalys t1
JOIN layoffsanalys t2
     ON  t1.company = t2.company
     AND t1.country = t2.country
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffsanalys
WHERE company = 'Airbnb';

-- 4. Remove unnecessary Colums

ALTER TABLE layoffsanalys
DROP COLUMN row_num;

SELECT *
FROM layoffsanalys








 



