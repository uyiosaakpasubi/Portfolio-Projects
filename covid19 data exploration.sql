 /*
   PROJECT ONE
   DATA SOURCE: https://ourworldindata.org/covid-deaths 
   TITLE: EXPLORATION AND ANALYSIS OF COVID-19 DATA GENERATED FROM FEBRUARY 2020 TILL DATE
*/ 
--------------------------------------------------------------------------------------------------------
/*
ASSUMPTIONS:
	1. The sum of new cases add up to make the total number of cases recorded
	2. The sum of the new_deaths make up the total number of deaths recorded worldwide
	3. The data is accurate, thus, the data for new and total cases represents country data recorded
		by the National Center for Disease Control.


NOTE: The Query to create the view ran with errors, hence the view was created using the 
available options in the explorer pane.
*/
-- Select the data we would be using for analysis

SELECT 
      location,
	  date, 
	  total_cases, 
	  new_cases, 
	  total_deaths,
	  population
FROM PortfolioProject..covid_deaths$
order by 1,2;

-- Exploring the Total Cases vs Total Deaths
-- The results should show the satistical likelihood of dying from the covid-19 virus in any country

SELECT 
      location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
FROM PortfolioProject..covid_deaths$
order by 1,2;


-- Lets dig into the total Case vs the Population (total cases per population)
-- Result shows the number percentage of the population that were confirmed to have contracted the virus

SELECT 
      location, date, total_cases, population, (total_cases/population)*100 cases_per_pop
FROM PortfolioProject..covid_deaths$
-- WHERE location = 'Nigeria'
order by 1,2;


-- What countries have the highest infection rate by population?
-- Note: only use the highest number of total cases, not the aggregated value

SELECT 
      location, population, MAX(total_cases), MAX((total_cases)/population)*100 infection_rate
FROM PortfolioProject..covid_deaths$
-- WHERE location = 'Nigeria'
GROUP BY location, population
order by 4 desc;

-- What countries recorded the highest death count and rates by population?

SELECT 
      location, 
	  MAX(total_cases) highest_num_cases, 
	  MAX(cast(total_deaths as int)) highest_num_deaths, 
	  ROUND(MAX(total_deaths)/MAX(total_cases)*100, 2) death_per_num_cases
FROM PortfolioProject..covid_deaths$
-- this 'WHERE' clause included in the query removes instances where preset groupings
-- like North_America, Africa etc appear in the data.
WHERE continent is not NULL  
GROUP BY location
order by 3 desc;

-- TO VIEW THE DISTRIBUTION OF THIS DATA BY CONTINENT
/* Including the data by continent from this particular dataset shows different results. the 
sums for North America, for example, show only values for United States, when continent is NULL.
However, when continent is NOT NULL, as presented in the data, the groupings make it easier to drill
down and find more information when this resulted is presented in a visualization tool.
*/
SELECT 
      continent, 
	  MAX(total_cases) highest_num_cases, 
	  MAX(cast(total_deaths as int)) highest_num_deaths,
	  ROUND(MAX(cast(total_deaths as int))/MAX(total_cases)*100, 2) death_pct_per_num_cases
FROM PortfolioProject..covid_deaths$
WHERE continent is not NULL  
GROUP BY continent
order by 3 desc;


-- VIEW GLOBAL DATA

SELECT
	date, 
	SUM(new_cases) AS sum_of_new_cases, 
	SUM(CAST(new_deaths AS int)) AS deaths_per_day,
	SUM(CAST(new_deaths AS int)) / SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..covid_deaths$
WHERE  continent is not null
GROUP BY date
ORDER BY 1,2;

-----------------------------------------------------------------------------------------------------------
-- EXPLORING THE COVID-19 VACCINATIONS TABLE

SELECT
	*
FROM PortfolioProject..covid_vaccinations$;

-- What is the total amount of people in the world that have been vaccinated?

 

/*
What number of perople have been vaccinated since approval? Show this as a percentage
of the population of each country in the dataset.
USE CTE
*/

WITH pop_with_vacc (continent,location,date,population,new_vaccinations,rolled_sum_vacc)
AS (
SELECT
	cod.continent,
	cod.location,
	cod.date,
	cod.population,
	cov.new_vaccinations,
	SUM(CAST (cov.new_vaccinations as bigint)) OVER (PARTITION BY cod.location, cod.date ORDER BY 
	 cod.location, cod.date) as rolled_sum_vacc
FROM PortfolioProject..covid_deaths$ cod
JOIN PortfolioProject..covid_vaccinations$ cov
	ON cod.location = cov.location
	AND cod.date = cov.date
WHERE cod.continent is not null
)

SELECT * , (rolled_sum_vacc / population)  as pct_vaccinated
FROM pop_with_vacc
ORDER BY 2,3

-- USING VIEWS

CREATE VIEW pct_vaccinated
(
SELECT
	cod.continent,
	cod.location,
	cod.date,
	cod.population,
	cov.new_vaccinations,
	SUM(CAST (cov.new_vaccinations as bigint)) OVER (PARTITION BY cod.location, cod.date ORDER BY 
	 cod.location, cod.date) as rolled_sum_vacc
FROM PortfolioProject..covid_deaths$ cod
JOIN PortfolioProject..covid_vaccinations$ cov
	ON cod.location = cov.location
	AND cod.date = cov.date
WHERE cod.continent is not null
)

SELECT *
FROM PortfolioProject..pct_vacc$
