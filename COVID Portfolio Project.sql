SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4


--selecting data we are going to use


SELECT location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--looking at total cases vs total deaths

--shows the likelihood of dying if you contract covid in your country


SELECT location,
	date,
	total_cases,
	total_deaths,
	(total_deaths / total_cases) * 100 AS DeathPercentages
FROM PortfolioProject..CovidDeaths
WHERE location = 'nigeria'
	AND continent IS NOT NULL
ORDER BY 1,2


--looking at the total cases vs population

--shows what percentage of population got covid


SELECT location,
	date,
	population,
	total_cases,
	(total_cases / population) * 100 AS CovidPercentages
FROM PortfolioProject..CovidDeaths
WHERE location = 'nigeria'
	AND continent IS NOT NULL
ORDER BY 1,2


-- looking at countries with highest infection rate compared to population


SELECT location,
	population,
	max(total_cases) AS HighestInfectionCount,
	max(total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--where location = 'nigeria'
WHERE continent IS NOT NULL
GROUP BY location,
	population
ORDER BY PercentPopulationInfected DESC


--showing the countries with the highest death count per population


SELECT location,
	max(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location = 'nigeria'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--showing the continent with the highest death count
SELECT continent,
	max(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location = 'nigeria'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--global numbers


SELECT date,
	sum(new_cases) AS totalcases,
	sum(new_deaths) AS totaldeaths,
	(sum(new_deaths) / sum(new_cases)) * 100 AS DeathPercentages
FROM PortfolioProject..CovidDeaths
--where location = 'nigeria' 
WHERE continent IS NOT NULL
	AND new_cases <> 0
GROUP BY date
ORDER BY 1,2

SELECT sum(new_cases) AS totalcases,
	sum(new_deaths) AS totaldeaths,
	(sum(new_deaths) / sum(new_cases)) * 100 AS DeathPercentages
FROM PortfolioProject..CovidDeaths
--where location = 'nigeria' 
WHERE continent IS NOT NULL
	AND new_cases <> 0
ORDER BY 1,2


--looking at total population vs vaccinations


SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) OVER (
		PARTITION BY dea.location ORDER BY dea.location,
			dea.date
		) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--using cte


WITH popvsvac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS (
		SELECT dea.continent,
			dea.location,
			dea.date,
			dea.population,
			vac.new_vaccinations,
			sum(vac.new_vaccinations) OVER (
				PARTITION BY dea.location ORDER BY dea.location,
					dea.date
				) AS RollingPeopleVaccinated
		FROM PortfolioProject..CovidDeaths dea
		JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location
			AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		)

SELECT *,
	(RollingPeopleVaccinated / population) * 100
FROM popvsvac


--temp table


DROP TABLE
IF EXISTS #PercentPopulationVaccinated
	CREATE TABLE #PercentPopulationVaccinated (
		continent NVARCHAR(255),
		location NVARCHAR(255),
		date DATETIME,
		population NUMERIC,
		new_vaccinations NUMERIC,
		RollingPeopleVaccinated NUMERIC
		)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) OVER (
		PARTITION BY dea.location ORDER BY dea.location,
			dea.date
		) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

SELECT *
FROM #PercentPopulationVaccinated


-- creating view to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) OVER (
		PARTITION BY dea.location ORDER BY dea.location,
			dea.date
		) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated




