SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Total cases Vs Total deaths
--SHowing likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%africa%'
ORDER BY 1,2

--Total cases Vs Population
SELECT location,date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%africa%'
ORDER BY 1,2

--Country with highest infection Rate compared to population
SELECT location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
ORDER BY PercentPopulationInfected desc

--Countries with highest death counts per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
GROUP BY location
ORDER BY TotalDeathCounts desc

--LET US BREAK DOWN BY CONTINENT
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCounts desc

--GLOBAL NUMBERS
SELECT date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast(new_deaths as int)) * 100
as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%africa%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total cases
SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast(new_deaths as int)) * 100
as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%africa%'
WHERE continent is not null
ORDER BY 1,2


--Total POpulation VS Vaccination 
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Rolling count
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(convert(int,new_vaccinations)) OVER(PARTITION BY dea.location
ORDER BY dea.location,dea.date) as rollingPeopleVaccinated--As it runs over and over with sum funtion, it breaks in location
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Total vaccination VS population
--USE CTE
WITH popvsvac(continent,location, date,population,new_vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(convert(int,new_vaccinations)) OVER(PARTITION BY dea.location
ORDER BY dea.location,dea.date) as rollingPeopleVaccinated--As it runs over and over with sum funtion, it breaks in location
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM popvsvac

------TEMP TABLE
----CREATE TABLE #PercentPopulationVaccinated
----(
----continent nvarchar(255),
----location nvarchar(255),
----date datetime,
----population numeric,
----new_vaccinations numeric,
----RollingPeopleVaccinated numeric
----)

----INSERT INTO #PercentPopulationVaccinated
----SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
----SUM(CONVERT(int,new_vaccinations)) OVER(PARTITION BY dea.location
----ORDER BY dea.location,dea.date) as RollingPeopleVaccinated--As it runs over and over with sum funtion, it breaks in location
----FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
----ON dea.location=vac.location
----AND dea.date=vac.date
----WHERE dea.continent is not null
------ORDER BY 2,3

----SELECT *, (RollingPeopleVaccinated/population)*100
----FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
CREATE VIEW	PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(convert(int,new_vaccinations)) OVER(PARTITION BY dea.location
ORDER BY dea.location,dea.date) as rollingPeopleVaccinated--As it runs over and over with sum funtion, it breaks in location
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated