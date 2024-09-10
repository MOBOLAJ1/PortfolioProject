SELECT *
FROM MyPortfolio..Covidvaccinations

--SELECT *
--FROM MyPortfolio..Covidvaccinations
--ORDER BY 3,4

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM MyPortfolio..CovidDeaths
WHERE location like 'Nigeria' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of the population got covid
SELECT location,date, total_cases, population, (total_cases/population)*100 AS Percentage_of_Population_Infected
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate Compared to Population

SELECT location,population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS Percentage_of_Population_Infected
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location ,population
ORDER BY Percentage_of_Population_Infected DESC

--Showing Countries with Highest Death Count per Population
SELECT location,population, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location ,population
ORDER BY Total_Death_Count DESC

--Analyzing by Continent

SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM MyPortfolio..CovidDeaths
WHERE continent IS  NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases), SUM(CAST(new_deaths AS int)), SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Deathpercentage
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2

SELECT  SUM(new_cases) AS Totalcases, SUM(CAST(new_deaths AS int)) AS Totaldeaths
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

WITH popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (int, vac.new_vaccinations)) OVER(PARTITION BY dea.location  ORDER BY dea.location,dea.date ) AS RollingPeopleVaccinated
FROM MyPortfolio..CovidDeaths AS dea
JOIN MyPortfolio..Covidvaccinations AS vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * , (RollingPeopleVaccinated/population) * 100
FROM popvsvac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent VARCHAR(255),
location VARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (int, vac.new_vaccinations)) OVER(PARTITION BY dea.location  ORDER BY dea.location,dea.date ) AS RollingPeopleVaccinated
FROM MyPortfolio..CovidDeaths AS dea
JOIN MyPortfolio..Covidvaccinations AS vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * , (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated

--Create view for PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (int, vac.new_vaccinations)) OVER(PARTITION BY dea.location  ORDER BY dea.location,dea.date ) AS RollingPeopleVaccinated
FROM MyPortfolio..CovidDeaths AS dea
JOIN MyPortfolio..Covidvaccinations AS vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

