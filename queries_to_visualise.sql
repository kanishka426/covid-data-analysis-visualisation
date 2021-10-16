-- 1.
-- Total Deaths vs World Population
-- total_deaths tracks the total deaths in a country upto a certain date. We want the most recent information, and hence we pass the date
-- to be 11th October, 2021.

SELECT 
    SUM(total_deaths) as total_deaths,
    SUM(population) as world_population
FROM 
    covid_data.covid_deaths
WHERE
    date = "2021-10-11" AND continent IS NOT NULL;

-- 2.
-- Total Deaths per Continent

SELECT
    continent,
    SUM(total_deaths) as total_deaths,
FROM 
    covid_data.covid_deaths
WHERE
    date = "2021-10-11" AND continent IS NOT NULL
GROUP BY 
    continent
ORDER BY
    2 DESC;

-- 3. 
-- Highest Percentage of Population Infected over two years

SELECT 
    continent,
    location,
    population,
    MAX(CASE 
        WHEN total_cases IS NULL
        THEN 0
        ELSE total_cases 
    END) as highest_total_cases,
    MAX(CASE 
        WHEN total_cases IS NULL
        THEN 0
        ELSE ROUND(total_cases*100/population,4) 
    END) as highest_percentage_infected
FROM 
    covid_data.covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY
    continent, location, population
ORDER BY
    highest_percentage_infected DESC;

-- 4. 
-- Infection percentage through time.

SELECT 
    continent,
    location,
    date,
    population,
    CASE 
        WHEN total_cases IS NULL
        THEN 0
        ELSE total_cases 
    END as total_cases,
    CASE 
        WHEN total_cases IS NULL
        THEN 0
        ELSE ROUND(total_cases*100/population,4) 
    END as percentage_infected
FROM 
    covid_data.covid_deaths
WHERE
    continent IS NOT NULL
ORDER BY
    1,2,3;