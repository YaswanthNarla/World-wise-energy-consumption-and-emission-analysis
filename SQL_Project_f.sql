CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;

-- 1. country table
CREATE TABLE country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);

SELECT * FROM COUNTRY;

-- 2. emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
    energy_type VARCHAR(50),
    year INT,
    emission double,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM EMISSION_3;


-- 3. population table
CREATE TABLE population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);

SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production double,
    FOREIGN KEY (country) REFERENCES country(Country)
);


SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);

SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    consumption double,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM CONSUMPTION;


/* Data Analysis Questions
-- General & Comparative Analysis */

-- What is the total emission per country for the most recent year available?
select country,sum(emission) as Total_Emission_MTco2 
from emission_3
where year = (select max(year) from emission_3) 
group by country
order by sum(emission);

-- What are the top 5 countries by GDP in the most recent year?
select country,value from gdp_3 where year = (select max(year) from gdp_3) order by value desc limit 5;

-- Compare energy production and consumption by country and year. 
SELECT 
    p.country,
    p.year,
    SUM(p.production) as total_production,
    SUM(c.consumption) as total_consumption,
    SUM(p.production) - SUM(c.consumption) AS energy_balance
FROM production p
JOIN consumption c
    ON p.country = c.country
    AND p.year = c.year
    AND p.energy = c.energy
GROUP BY p.country, p.year
ORDER BY p.country, p.year;

-- Insights : accuracy with no dupliactes we use inner joins.

-- Which energy types contribute most to emissions across all countries?

select energy_type,sum(emission) as total_emission_MTCo2 from emission_3 group by energy_type;


-- Trend Analysis Over Time
-- How have global emissions changed year over year?
SELECT 
    year,
    SUM(emission) AS total_emission,
    SUM(emission) - LAG(SUM(emission)) OVER (ORDER BY year) AS yoy
FROM emission_3
GROUP BY year
ORDER BY year;

-- What is the trend in GDP for each country over the given years?

-- select country,year,value as gdp from gdp_3 order by country,year desc;

SELECT 
    country,
    year,
    value AS gdp,
    value - LAG(value) OVER (PARTITION BY country ORDER BY year) AS yoy_change
FROM gdp_3
ORDER BY country, year;

-- How has population growth affected total emissions in each country?
SELECT 
    e.country,
    e.year,
    SUM(e.emission) AS total_emission,
    p.value AS population,
    p.value - LAG(p.value) OVER (PARTITION BY e.country ORDER BY e.year) AS pop_growth
FROM emission_3 e
JOIN population p 
    ON e.country = p.countries
    AND e.year = p.year
GROUP BY e.country, e.year, p.value
ORDER BY e.country, e.year;

-- Has energy consumption increased or decreased over the years for major economies?


-- select country,year,sum(consumption) as total_consumption,
-- sum(consumption) - lag(sum(consumption)) over(partition by country order by year) as diff_in_energy
-- from consumption

-- group by country,year
-- order by country,year;

SELECT c.country,c.year,
    SUM(c.consumption) AS total_consumption,SUM(g.value) AS total_gdp
FROM consumption c
JOIN gdp_3 g 
    ON c.country = g.country 
    AND c.year = g.year
WHERE c.country IN (
    SELECT country FROM (
        SELECT country
        FROM consumption
        GROUP BY country
        ORDER BY SUM(consumption) DESC
        LIMIT 10
    ) AS top_countries
)
GROUP BY c.country, c.year
ORDER BY total_gdp DESC;




-- Which energy sources show the fastest growth in consumption over time across all countries?
SELECT 
    energy,
    year,
    SUM(consumption) AS total_consumption,
    
    SUM(consumption) 
    - LAG(SUM(consumption)) OVER (PARTITION BY energy ORDER BY year) 
    AS yoy_difference

FROM consumption
GROUP BY energy, year
ORDER BY energy, year;


-- Ratio & Per Capita Analysis

-- What is the emission-to-GDP ratio for each country by year?
SELECT 
    e.country,
    e.year,
    SUM(e.emission) AS total_emission,
    g.value AS gdp_billion_usd,
    SUM(e.emission) / g.value AS emission_to_gdp_ratio
FROM emission_3 e
JOIN gdp_3 g
    ON e.country = g.country
    AND e.year = g.year
GROUP BY e.country, e.year, g.value
ORDER BY e.country, e.year;
-- What is the energy consumption per capita for each country over the last decade?
SELECT 
    c.country,
    c.year,
    SUM(c.consumption) / p.value AS per_capita_consumption
FROM consumption c
JOIN population p
    ON c.country = p.countries
    AND c.year = p.year
WHERE c.year >= (SELECT MAX(year) - 10 FROM consumption)
GROUP BY c.country, c.year, p.value
ORDER BY c.country, c.year;


-- How does energy production per capita vary across countries?

select p.country,p.year, sum(production)/pp.value Per_capita_production from production as p
join
population as pp
on p.country = pp.countries
and p.year = pp.year

group by p.country,p.year,pp.value
order by p.country,p.year desc;


-- Which countries have the highest energy consumption relative to GDP?
with growth_cte as (
    select 
        p.country,
        p.year,
        
        (g.value - lag(g.value) over (partition by p.country order by p.year)) 
        / lag(g.value) over (partition by p.country order by p.year) as gdp_growth,
        
        (sum(p.production) - lag(sum(p.production)) over (partition by p.country order by p.year)) 
        / lag(sum(p.production)) over (partition by p.country order by p.year) as prod_growth
        
    from production p
    join gdp_3 g
        on p.country = g.country
        and p.year = g.year
    group by p.country, p.year, g.value
)

select 
    country,
    (count(*) * sum(gdp_growth * prod_growth) - sum(gdp_growth) * sum(prod_growth)) /
    sqrt((count(*) * sum(gdp_growth * gdp_growth) - pow(sum(gdp_growth), 2)) * (count(*) * sum(prod_growth * prod_growth) - pow(sum(prod_growth), 2))
    ) as correlation
from growth_cte
where gdp_growth is not null 
  and prod_growth is not null
group by country
order by correlation desc;

-- Global Comparisons

-- What are the top 10 countries by population and how do their emissions compare?
select 
    p.countries as country,
    max(p.value) as population,
    sum(e.emission) as total_emission
from population p
join emission_3 e
    on p.countries = e.country
    and p.year = e.year
group by p.countries
order by population desc
limit 10;


-- Which countries have improved (reduced) their per capita emissions the most over the last decade?
-- select 
--     country,
--     max(per_capita_emission) - min(per_capita_emission) as reduction
-- from emission_3
-- where year >= (select max(year) - 10 from emission_3)
-- group by country
-- order by reduction desc
-- limit 10;


-- which countries have reduced their total emissions the most over time?

SELECT 
    country,
    SUM(CASE WHEN year = (SELECT MIN(year) FROM emission_3) THEN emission END) -
    SUM(CASE WHEN year = (SELECT MAX(year) FROM emission_3) THEN emission END) 
    AS emission_reduction
FROM emission_3
GROUP BY country
ORDER BY emission_reduction DESC;


-- What is the global share (%) of emissions by country?
select 
    country,
    sum(emission) as total_emission,
    sum(emission) / (select sum(emission) from emission_3) * 100 as global_share
from emission_3
group by country
order by global_share desc;

-- What is the global average GDP, emission, and population by year?

select 
    g.year,
    avg(g.value) as avg_gdp,
    avg(e.emission) as avg_emission,
    avg(p.value) as avg_population
from gdp_3 g
join emission_3 e
    on g.country = e.country
    and g.year = e.year
join population p
    on g.country = p.countries
    and g.year = p.year
group by g.year
order by g.year;

