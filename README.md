# SQL_Projects
https://docs.google.com/document/d/1OnL06J_k-DuDX5leW6VL6s0a3IUujpnFdTv-DVuYmNI/edit

NOTE TO SELF: 
To use GROUP BY, need to use Aggreagate Function on any selected variable. 


COMPLICATIONS: 
A complication emerged during the project. Navicat was unable to import date from excel file. What troubleshooters were tried and what happened.
Turned file to CSV according to shakil. Result was no single data was retrieved. 
Changed date format to YYYY-MM-DD format. Successful. 
Secondly I was getting error after putting two Where argument in single code. 
Solution: In my case I needed to put AND for WHERE argument. Putting two Where is wrong. 
First import two xlsx files into the navicat

DATA EXPLORATION:

Codes:
Order By,
SELECT * 
FROM sql_project_1.coviddeaths
ORDER BY 2,3

--Selecting the data we will work with 
SELECT Location, date, total_cases, new_cases, new_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total cases vs Total coviddeaths
– Shows likelihood of dying if u contract covid in your country
SELECT Location, date, total_cases, new_cases, new_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

To find out the situation in United States. 
SELECT Location, date, total_cases, new_cases, new_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL AND Location like ‘%states%’
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population got covid  
SELECT Location, date, total_cases, population, (total_cases/population)* 100 AS PopulationPercentage
FROM coviddeaths
ORDER BY 1,2

-- Looking at countries with Highest Infection Rate compared to population

SELECT location, population, MAX(total_cases) AS highest_infection_count, (MAX(total_cases)/population) *100 AS PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC
(In the corrected code, I added the GROUP BY clause to group the data by location and population. This is necessary because you are using an aggregate function (MAX) on total_cases. When using an aggregate function, you typically need to specify the non-aggregated columns in the GROUP BY clause.

By grouping the data, you ensure that you obtain the maximum total_cases for each unique combination of location, date, and population. Then, the calculation of PercentPopulationInfected is performed correctly by dividing MAX(total_cases) by population and multiplying by 100.)

-- Showing countries with highest death count per population  
SELECT Location, MAX(total_deaths) AS highest_death_count
FROM coviddeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY highest_death_count DESC

(In the video, total_deaths was listed as varchar which was a mistake, it should have been int. For that reason they used CAST this way,,, MAX(CAST(total_deaths as int)). Remember with the use of CAST , the chage of data type is temporary.

Also, in the places where continent is NULL, the location contain the entire continent. Which gives us data in chart which is not useful to us now. SO for that reason we use WHERE continent IS NOT NULL )

-- Breaking things by continent
Select continent, MAX(Total_deaths) as TotalDeathCount
From coviddeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc
(Because of the issue with dataset, according to this code, number based on continent is not happening correctly. For example, in north america only usa number is getting counted. So the correct code is--  )

Select location, MAX(Total_deaths) as TotalDeathCount
From coviddeaths
Where continent is null 
Group by location
order by TotalDeathCount desc

However still could keep the original one for visualization purpose.

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
(This Part OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountPopulationVaccinated which comes after SUM(vac.new_vaccinations) is very important. In the case you don’t use Partition and don’t mention order of location and date it will do sum of wrong place and will not do rolling sum  )

Later when we try to find ratio of total vaccinations vs the population we cannot do cause we cannot use the column called RollingCountPopulationVaccinated cause it is Temporary column. So we need to use CTE. 



-- USE CTE
WITH POPSVSVAC (continent, location, date, population, new_vaccinations, RollingCountPopulationVaccinated)
AS
(
)
This is an example of CTE. The number of variable in the CTE must be same as the  original query. So be careful. So with CTE function the new query will look like. Also Order by clause also cannot be there. Also when u select something from the CTE, u must execute cte and the select clause together. 

WITH POPSVSVAC (continent, location, date, population, new_vaccinations, RollingCountPopulationVaccinated)
AS
(
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountPopulationVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
-- ORDER BY 1,3
)

-- TEMP TABLE
-- Temp table is kind of similar to CTE.
-- While working with mysql, cannot execute create table, insert into and select altogether
-- Add drop table for better practice.
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
-- The change of creating view is permanent unlike temp table. We have to delete manually.

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountPopulationVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL




