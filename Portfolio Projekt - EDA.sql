-- EDA

-- Benutzen nicht die originale tabelle, sondern eine kopie
select *
from layoffs_staging2;

-- Betrachtung der prozentualen Anteile, um zu sehen, wie viel Entlassungen es gab
select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

-- die größten Unternehmen die eine 100 prozentige Entlassung durchgeführt haben
select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions;

-- Wann die Entlassungen startetn und endeten
select min(date), max(date)
from layoffs_staging2;

-- Länder mit den meisten Entlassungen
select country, sum(total_laid_off)
from layoffs_staging2
group by country;

-- die Jahre mit den meisten Entlassungen
select year(date) , sum(total_laid_off) 
from layoffs_staging2
group by year(date)
order by 1 desc;

-- Top 3 Unternehmen mit den meisten Entlassungen pro Jahr

with Company_Year as 
(
  select company, year(date) as years, SUM(total_laid_off) as total_laid_off
  from layoffs_staging2
  group by company, year(date)
)
, Company_Year_Rank as (
  select company, years, total_laid_off, dense_rank() over (partition by years order by total_laid_off desc) as ranking
  from Company_Year
)
select company, years, total_laid_off, ranking
from Company_Year_Rank
where ranking <= 3
and years is not null
order by years asc, total_laid_off desc;

-- die Gesamtzahl der Entlassungen pro Monat
select SUBSTRING(date,1,7) as dates, SUM(total_laid_off) as total_laid_off
from layoffs_staging2
where date is not null
group by dates
order by dates asc;

-- verwenden es jetzt in einer CTE, damit wir es abfragen können.
with DATE_CTE as 
(
select SUBSTRING(date,1,7) as dates, sum(total_laid_off) as total_laid_off
from layoffs_staging2
where date is not null
group by dates 
order by dates asc
)
select dates, SUM(total_laid_off) over (order by dates asc) as rolling_total_layoffs
from DATE_CTE
order by dates asc;
