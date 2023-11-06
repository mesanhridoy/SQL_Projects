



-- Selecting the data we will work with 
SELECT Location, date, total_cases, new_cases, new_deaths, population
FROM coviddeaths
ORDER BY 1,2

-- Total cases vs Total coviddeaths
-- Shows likelihood of dying if u contract covid in your country
SELECT Location, date, total_cases, new_cases, new_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- for United States
SELECT location, date, total_cases, new_cases, new_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
AND Location LIKE '%states%'
ORDER BY 1,2

SELECT * FROM coviddeaths Where location = 'United States'

-- Total Cases vs Population
-- Shows what percentage of population got covid  
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentage
FROM coviddeaths
ORDER BY 1,2

-- Looking at countries with Highest Infection Rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, (MAX(total_cases)/population) *100 AS PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC 

-- Showing countries with highest death count per population  
SELECT Location, MAX(total_deaths) AS highest_death_count
FROM coviddeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY highest_death_count DESC

-- Breaking things by continent
-- Showing countries with highest death count per population  
-- Incorrect Number 
-- See note and video to know why still kept it even tho incorrect number 
SELECT Location, MAX(total_deaths) AS highest_death_count
FROM coviddeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY highest_death_count DESC

-- Currect Number
Select location, MAX(Total_deaths) as TotalDeathCount
From coviddeaths
Where continent is null 
Group by location
order by TotalDeathCount desc

-- Global Numbers
-- Global death percentage per date 
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY date  

-- Looking at total population vs vaccinations 
-- Based on Location, we wanna add number of new vaccinations each day. 
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountPopulationVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 1,3


WITH POPSVSVAC (continent, location, date, population, new_vaccinations, RollingCountPopulationVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountPopulationVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
-- ORDER BY 1,3
)

SELECT * ,(RollingCountPopulationVaccinated/Population)*100
FROM POPSVSVAC



/* This section from my own. Practicing to get max vaccination rate. Last code is the correct and intended one
-- To find the higest vaccination rate 
WITH POPSVSVAC (continent, location, population, new_vaccinations, RollingCountPopulationVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations, 
MAX(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingCountPopulationVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
-- AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 1,3
)

SELECT * , (RollingCountPopulationVaccinated)
FROM POPSVSVAC

SELECT dea.continent, dea.location, dea.population, 
MAX(vac.new_vaccinations) AS RollingCountPopulationVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent,dea.location
ORDER BY dea.location 
-- AND dea.date = vac.date

SELECT dea.location, dea.population, 
MAX(vac.new_vaccinations)
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.population 
ORDER BY dea.location 
-- AND dea.date = vac.date

-- ORDER BY 1,3
SELECT location, population, MAX(total_cases) AS highest_infection_count, (MAX(total_cases)/population) *100 AS PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC

SELECT dea.location, dea.population, 
MAX(vac.new_vaccinations), MAX(vac.new_vaccinations)/dea.population*100 AS max_vaccination_rate
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.population 
ORDER BY max_vaccination_rate DESC
*/

-- TEMP TABLE
DROP TABLE PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated(
continent VARCHAR(255),
location VARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingCountPopulationVaccinated NUMERIC
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountPopulationVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL

SELECT * ,(RollingCountPopulationVaccinated/Population)*100
FROM PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountPopulationVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL

SELECT * ,(RollingCountPopulationVaccinated/Population)*100
FROM PercentPopulationVaccinated








