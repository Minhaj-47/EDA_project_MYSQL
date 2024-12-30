-- EDA

select*
from layoffs_staging2;

-- maximum laid of
-- looks like maximum laid of is 15000
select max(total_laid_off)
from layoffs_staging2 ;

-- total laid off doesnot show the actual value cause its data type is  text,lets change this into int
alter table layoffs_staging2
modify column total_laid_off int;

-- convert the percentage_laid_off column to float
alter table layoffs_staging2
modify percentage_laid_off float(4,2);

-- maximum percentage laid of (means whole company is shut off maybe)
select max(percentage_laid_off)
from layoffs_staging2;

-- lets see which companies completely laid of their staff
-- some contruction company named katerra top the chart 
select company, sum(total_laid_off) as total_fired
from layoffs_staging2
where percentage_laid_off=1.00
group by company
order by total_fired desc
;

-- which companies has highest laid of
-- amazon ,meta ,intel top the chart
select company, sum(total_laid_off) as total_fired
from layoffs_staging2
group by company
order by total_fired desc
;

-- what industry has the highest laid of
-- looks like retail and consumer side of industry had the most hit
select industry, sum(total_laid_off) as total_fired
from layoffs_staging2
group by industry
order by total_fired desc
;
-- time frame of the data set
-- 2020 to 2024 data
select min(`date`),max(`date`)
from layoffs_staging2;

-- which country has the highes lay off
-- usa to the list then india and germany
select country, sum(total_laid_off) as total_fired
from layoffs_staging2
group by country
order by total_fired desc
;
-- which year had the highest layoff
-- looks like 2023,2022 had the highest laid off
select year(`date`),sum(total_laid_off) as total_fired
from layoffs_staging2
GROUP BY year(`date`)
order by 1 desc;

-- date wise rolling total of fired people

with rolling_total_fired as
(
select substr(`date`,1,7) as `Month`,sum(total_laid_off) as total_fired
from layoffs_staging2
GROUP BY `Month`
order by 1
)
select `Month`,total_fired,sum(total_fired) over(order by `Month` ) as rolling_total
from rolling_total_fired;

-- top 5 companies that fired empoyee year wise

with company_year(company,`Year`,total_fired) as
(
select company ,year(`date`),sum(total_laid_off)
from layoffs_staging2
GROUP BY company ,year(`date`)

),
company_year_rank as
(
select *,
DENSE_RANK() over(PARTITION BY `Year`order by total_fired DESC) as ranking
from company_year
)

select *
from company_year_rank
where ranking<=3
and `Year` is not null
order by `Year` asc;
