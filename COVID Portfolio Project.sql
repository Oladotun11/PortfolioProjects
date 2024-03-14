select *
from PortfolioProject..CovidDeaths
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

--selecting data we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentages
from PortfolioProject..CovidDeaths
where location = 'nigeria' and continent is not null
order by 1,2


--looking at the total cases vs population
--shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentages
from PortfolioProject..CovidDeaths
where location = 'nigeria' and continent is not null
order by 1,2


-- looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'nigeria'
where continent is not null
group by location, population
order by PercentPopulationInfected desc


--showing the countries with the highest death count per population

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'nigeria'
where continent is not null
group by location
order by TotalDeathCount desc


--let's break things down by continent


--showing the continent with the highest death count

select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'nigeria'
where continent is not null
group by continent
order by TotalDeathCount desc


--global numbers


select date, sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentages
from PortfolioProject..CovidDeaths
--where location = 'nigeria' 
where continent is not null and  new_cases <> 0
group by date
order by 1,2


select sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentages
from PortfolioProject..CovidDeaths
--where location = 'nigeria' 
where continent is not null and  new_cases <> 0
order by 1,2

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations)
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using cte

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations)
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from popvsvac


--temp table 

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations)
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from #PercentPopulationVaccinated


-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations)
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated




