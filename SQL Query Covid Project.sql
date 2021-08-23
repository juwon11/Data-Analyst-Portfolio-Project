/*
Queries used for Tableau Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolioproject..covid_deaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Portfolioproject..covid_deaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolioproject..covid_deaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolioproject..covid_deaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc








-- Queries I originally had, but excluded some because it created too long of video
-- Here only in case you want to check them out



SELECT *
FROM Portfolioproject..covid_deaths$
ORDER BY 3,4


--SELECT *
--FROM Portfolioproject..covid_vaccinations$
--ORDER BY 3,4

--Select data we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolioproject..covid_deaths$
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM Portfolioproject..covid_deaths$
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2

--Looking at the Total Cases vs Poplulation
Shows what percentage of population got covid


SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percent_population_infected
FROM Portfolioproject..covid_deaths$
--WHERE location LIKE '%Nigeria%'
ORDER BY 1,2


--Looking at Countires with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS Higest_Infection_Count, MAX((total_cases/population))*100 AS Percent_population_infected
FROM Portfolioproject..covid_deaths$
--WHERE location LIKE '%Nigeria%'
GROUP BY location, population
ORDER BY Percent_population_infected DESC

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM Portfolioproject..covid_deaths$
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT null
GROUP BY location
ORDER BY Total_Death_Count DESC


--Let's break things down by Continent

SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM Portfolioproject..covid_deaths$
--WHERE location LIKE '%Nigeria%'
WHERE continent IS null
GROUP BY location
ORDER BY Total_Death_Count DESC


--Showing Continents with the Highest Death Counts

SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM Portfolioproject..covid_deaths$
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT null
GROUP BY continent
ORDER BY Total_Death_Count DESC



--Global Numbers

--SELECT date, SUM(new_cases), SUM(total_deaths/total_cases)*100 AS death_percentage
FROM Portfolioproject..covid_deaths$
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2


SELECT date, SUM(new_cases)
FROM Portfolioproject..covid_deaths$
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2


SELECT date, SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS int)) AS Total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_percantage
FROM Portfolioproject..covid_deaths$
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2


--Global Death Percentage


SELECT SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS int)) AS Total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_percantage
FROM Portfolioproject..covid_deaths$
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT null
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population VS Vaccinations 

SELECT *
FROM Portfolioproject..covid_deaths$ dea
JOIN Portfolioproject..covid_vaccinations$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date




SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,	dea.date) as Rolling_people_vaccinated
FROM Portfolioproject..covid_deaths$ dea
JOIN Portfolioproject..covid_vaccinations$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent IS NOT null
  ORDER BY 2,3
  

  --Use CTE  



WITH popvsvac (continent, Location, Date, Population, new_vaccinations, Rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,	dea.date) as Rolling_people_vaccinated
FROM Portfolioproject..covid_deaths$ dea
JOIN Portfolioproject..covid_vaccinations$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent IS NOT null
  --ORDER BY 2,3
  )
  Select *,		(Rolling_people_vaccinated/Population)* 100 
  FROM popvsvac


  --Use Temp Table

  DROP TABLE if exists Percentpopulationvaccinated
  CREATE TABLE Percentpopulationvaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  new_vaccinations numeric,
  Rolling_people_vaccinated numeric
  )

  INSERT INTO Percentpopulationvaccinated
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,	dea.date) as Rolling_people_vaccinated
FROM Portfolioproject..covid_deaths$ dea
JOIN Portfolioproject..covid_vaccinations$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  --WHERE dea.continent IS NOT null
  --ORDER BY 2,3

  Select *, (Rolling_people_vaccinated/Population)* 100 
  FROM Percentpopulationvaccinated


  --Creating View to store data for later visualizations


  CREATE VIEW Percentpopulationvaccinated AS
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,	dea.date) as Rolling_people_vaccinated
FROM Portfolioproject..covid_deaths$ dea
JOIN Portfolioproject..covid_vaccinations$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent IS NOT null
  --ORDER BY 2,3

  