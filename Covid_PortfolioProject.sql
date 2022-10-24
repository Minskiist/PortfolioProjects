Select *
From PortfolioProject..CovidDeaths
WHERE continent is not null
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

--Select Data that we are goping to be using


--Select location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths
--Order By 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Finland (2021-04-30)
--Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths
--WHERE location like 'Finland' AND continent is not null
--Order By 1,2


--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid (2021-04-30)

--Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
--FROM PortfolioProject..CovidDeaths
--WHERE location like 'Finland' AND continent is not null
--Order By 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Finland'
GROUP BY location, population
Order By PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Finland'
WHERE continent is not null
GROUP BY location
Order By TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT


Select continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Finland'
WHERE continent is not null
GROUP BY continent
Order By TotalDeathCount DESC

-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Finland'
WHERE continent is not null
GROUP BY continent
Order By TotalDeathCount DESC


-- GLOBAL NUMBERS

Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Finland' AND 
WHERE continent is not null
--GROUP BY date
Order By 1,2

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated, 
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated
ORDER BY 2,3


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent is not null
--ORDER BY 2,3

Select *
FROM PercentPopulationVaccinated