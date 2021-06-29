USE Covid


--List of countries We have data on
SELECT
	DISTINCT Location
FROM
	CovidDeaths


-- Total Cases vs Total Deaths in India (Death rate)
SELECT 
	Location, 
	date, 
	total_cases,  
	total_deaths,
	(total_deaths/total_cases)*100 AS death_rate
FROM 
	CovidDeaths
WHERE
	Location = 'India'
ORDER BY
	Location, 
	date

--Total Cases vs Population
SELECT 
	Location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths,
	population,
	(total_cases/population)*100 AS infection_rate
FROM 
	CovidDeaths
WHERE
	Location = 'India'
ORDER BY
	Location, 
	date

--Countries with Highest Infection rate
SELECT 
	Location,
	population,
	MAX(total_cases) AS total_cases,  
	MAX((total_cases/population)*100) AS infection_rate
FROM 
	CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	Location,
	population
ORDER BY
	infection_rate DESC

--Countries with Highest Deaths
SELECT 
	Location,
	population,
	MAX(CAST(total_deaths AS int)) AS death_count
FROM 
	CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	Location,
	population
ORDER BY
	death_count DESC


--Continents with highest death rate
WITH 
	cte_continent
AS
(
SELECT
	location,
	continent,
	MAX(population) AS population,
	MAX(CAST(total_deaths AS int)) AS total_deaths
FROM
	CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY 
	location,
	continent
)
SELECT
	continent,
	SUM(population) AS total_population,
	SUM(total_deaths) AS total_deaths,
	SUM(total_deaths)/SUM(population) AS death_rate
FROM
	cte_continent
GROUP BY
	continent

--Total Population vs At least one vaccination
SELECT 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations, 
	SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.Date) as RollingPeopleVaccinated
FROM 
	CovidDeaths d
INNER JOIN 
	CovidVaccinations v
ON 
	d.location = v.location
	AND 
	d.date = v.date
WHERE 
d.continent IS NOT NULL 