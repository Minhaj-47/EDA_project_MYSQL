-- data cleaning
select *
from layoffs;

-- the steps are
-- 1. remove all duplicate data
-- 2. standarise data
-- 3. remove null and blank values

CREATE TABLE layoffs_staging
LIKE layoffs;

select *
from layoffs_staging;

INSERT INTO layoffs_staging
select *
from layoffs;

-- first step remove duplicate values
with duplicate_cte as
(
select *,
row_number() over(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised) as row_num
from layoffs_staging
)
select*
from duplicate_cte
where row_num>1;

-- we will create a new table and remove duplicate from that table
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- insert the same data with rown_num in the new table

insert into layoffs_staging2
select *,
row_number() over(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised) as row_num
from layoffs_staging;

select*
from layoffs_staging2
where row_num>1;

-- deleteing all duplicate rows
delete 
from layoffs_staging2
where row_num>1;

-- standarizaton of the data

select *
from layoffs_staging2;

-- company column

select company,trim(company)
from layoffs_staging2;

-- update company column with trim function
update layoffs_staging2
set company = trim(company);

-- checkikng location column
select DISTINCT location
from layoffs_staging2
order by 1
;

-- checking industry column
select distinct industry
from layoffs_staging2
order by 1;

-- cheaking country column
select DISTINCT country
from layoffs_staging2
order by 1;

select DISTINCT country
from layoffs_staging2
where country like 'United%';

-- check the date column

select `date`
from layoffs_staging2;

-- changin date table datatype
alter table  layoffs_staging2
modify `date` date;

-- removing the null and blank values

select *
from layoffs_staging2;

SELECT industry 
from layoffs_staging2
where industry is null or industry='';

-- drop table layoffs_recheck;

-- check total_laid of and percentage_laid_off column

select*
from layoffs_staging2
where (total_laid_off is null or total_laid_off='') and (percentage_laid_off is null or percentage_laid_off ='')
;

-- lets just repopulate all the blank values with null in these 2 column

update layoffs_staging2
SET total_laid_off=NULL 
where total_laid_off='';

update layoffs_staging2
SET percentage_laid_off=NULL 
where percentage_laid_off='';

-- now delete the rows which have null in both total_laid_off and percentage_laid_off column

DELETE
from layoffs_staging2
where (total_laid_off is null or total_laid_off='') and (percentage_laid_off is null or percentage_laid_off ='')
;

-- drop the row_num column 

alter table layoffs_staging2
drop column row_num;