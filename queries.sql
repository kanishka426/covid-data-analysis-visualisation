-- Selecting the data we will be using.

SELECT  
    continent,
    location,
    date,
    population,
    population_density,
    total_cases, new_cases,
    total_deaths, new_deaths,
    reproduction_rate
FROM 
    covid_data.covid_deaths
WHERE
    continent IS NOT NULL
ORDER BY
    location, date;



-- Looking at Total Cases vs Total Deaths and finding Mortality Rate.

SELECT  
    continent,
    location,
    date,
    total_cases,
    total_deaths,
    CASE 
        WHEN total_deaths IS NULL OR total_cases = 0
            THEN NULL
            ELSE CONCAT(CAST(ROUND(total_deaths*100/total_cases,2) AS STRING), "%")
    END as mortality_rate
FROM 
    covid_data.covid_deaths
WHERE
    continent IS NOT NULL -- AND location = "India" 
ORDER BY
    location, date;


-- Looking at the Total Cases vs Population per country 
-- and % infected.

SELECT
    continent,
    location,
    date,
    total_cases,
    population,
    CASE 
        WHEN total_cases IS NULL
        THEN NULL
        ELSE CONCAT(CAST(ROUND(total_cases*100/population,4) AS STRING), "%")
    END as percentage_infected
FROM 
    covid_data.covid_deaths
WHERE
    continent IS NOT NULL
ORDER BY 
    location, date;

-- Looking at countries with the highest maximum recorded infection rate 
-- from these two years. 

SELECT 
    continent,
    location,
    population,
    MAX(CASE 
        WHEN total_cases IS NULL
        THEN NULL
        ELSE ROUND(total_cases*100/population,4) 
    END) as highest_percentage_infected
FROM 
    covid_data.covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY
    continent, location, population
--HAVING 
--    location = "India"
ORDER BY
    highest_percentage_infected DESC;

-- Looking at the countries with deaths per population

SELECT
    continent,
    location,
    population,
    MAX(total_deaths) as total_deaths,
    MAX(CASE 
        WHEN total_deaths IS NULL OR total_cases = 0
            THEN NULL
            ELSE ROUND(total_deaths*100/population,5)
    END) as percentage_death
FROM 
    covid_data.covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY 
    continent, location, population
--HAVING 
--    location = "India"
ORDER BY
    total_deaths DESC;

-- Looking at total death count per continent

SELECT
    continent,
    SUM(
        CASE WHEN new_deaths IS NULL
        THEN 0
        ELSE new_deaths
        END
        ) as total_deaths,
FROM 
    covid_data.covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY 
    continent
--HAVING 
--    continent = "Asia"
ORDER BY
    total_deaths DESC;

--Looking at Global Numbers
-- Total Deaths by the day.
SELECT
    date,
    SUM(
        CASE WHEN total_deaths IS NULL
        THEN 0
        ELSE total_deaths
        END
    ) as total_deaths,
FROM 
    covid_data.covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY 
    date
--HAVING 
--    continent = "Asia"
ORDER BY
    date;

-- Mortality Rate Globlaly: 

SELECT
    date,
    SUM(
        CASE WHEN total_deaths IS NULL
        THEN 0
        ELSE total_deaths
        END
    ) as total_deaths,
    SUM(
        CASE WHEN total_cases IS NULL
        THEN 1
        ELSE total_cases
        END
     ) as total_cases,
    (SUM(
        CASE WHEN total_deaths IS NULL
        THEN 0
        ELSE total_deaths
        END
    )*100/SUM(
        CASE WHEN total_cases IS NULL
        THEN 1
        ELSE total_cases
        END
     )) as mortality_rate
FROM 
    covid_data.covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY 
    date
--HAVING 
--    continent = "Asia"
ORDER BY
    date;
--

-- Total Deaths vs World Population.

SELECT 
    SUM(total_deaths) as total_deaths,
    SUM(population) as world_population
FROM 
    covid_data.covid_deaths
WHERE
    date = "2021-10-11" AND continent IS NOT NULL;
--

-- Total Vaccinations vs Population  

-- Making a CTE 

WITH
    PopvsVacc
    AS 
    (
        SELECT 
            covid_deaths.location as location,
            covid_deaths.date as date,
            covid_vacc.new_vaccinations as new_vaccinations,
            SUM(covid_vacc.new_vaccinations) OVER (PARTITION BY covid_vacc.location ORDER BY covid_vacc.date) as total_vaccination_rolling_count,
            covid_deaths.population as population
        FROM 
            covid_data.covid_deaths as covid_deaths
        JOIN 
            covid_data.covid_vaccinations as covid_vacc
        ON 
            covid_deaths.location = covid_vacc.location AND covid_deaths.date = covid_vacc.date
        WHERE 
            covid_deaths.continent IS NOT NULL
    )

-- Finding out the percentage of population vaccinated. We divide the total vaccination count by 2, because people require 2 doses of vaccinations
-- and what we really want is the number of people vaccinated. 

SELECT 
    *,
    total_vaccination_rolling_count*50/population as perct_vaccination
FROM 
    PopvsVacc;

-- Creating View for this query.
DROP VIEW IF EXISTS covid_data.rolling_count_vaccinated;
CREATE VIEW covid_data.rolling_count_vaccinated
    AS
    (
        SELECT 
            covid_deaths.location as location,
            covid_deaths.date as date,
            covid_vacc.new_vaccinations as new_vaccinations,
            SUM(covid_vacc.new_vaccinations) OVER (PARTITION BY covid_vacc.location ORDER BY covid_vacc.date) as total_vaccination_rolling_count,
            covid_deaths.population as population
        FROM 
            covid_data.covid_deaths as covid_deaths
        JOIN 
            covid_data.covid_vaccinations as covid_vacc
        ON 
            covid_deaths.location = covid_vacc.location AND covid_deaths.date = covid_vacc.date
        WHERE 
            covid_deaths.continent IS NOT NULL
    )
