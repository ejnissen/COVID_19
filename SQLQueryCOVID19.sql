select *
from PortfolioProjects..covid_deaths
where continent is not null
order by 3,4

--select *
--from PortfolioProjects..covid_vaccinations
--order by 3,4

--Select the data we will be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..covid_deaths
order by 1,2


--looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract COVID in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProjects..covid_deaths
where location like '%states%'
order by 1,2


--Looking at the Total Cases vs Population
--shows what percentage of population contracted covid in your country

select location, date, population, total_cases,(total_cases/population)*100 as death_percentage
from PortfolioProjects..covid_deaths
--where location like '%states%'
order by 1,2

--looking at countries with the highest infection rate compared to population

select location, population, date, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_population_infected
from PortfolioProjects..covid_deaths
--where location like '%states%'
group by location, population, date
order by percent_population_infected desc



-- Showing the countries with the highest death count per population

select location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProjects..covid_deaths
--where location like '%states%'
where continent is not null
group by location
order by total_death_count desc

-- seperating out the extra location classifications what we don't need, such as 'European Union' and 'high income'. 
--this allows us to look at only by continent.

select location, SUM(cast(new_deaths as int)) as total_death_count
from PortfolioProjects..covid_deaths
--where location like '%states%'
where continent is null
and location not in ('World', 'European Union', 'International', 'Upper middle income','High income', 'lower middle income', 'low income')
group by location
order by total_death_count desc

--breaking down by continent
--showing continents with the highest death count per population

select location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProjects..covid_deaths
--where location like '%states%'
where continent is null
group by location
order by total_death_count desc



--global numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from PortfolioProjects..covid_deaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations

select *
from PortfolioProjects..covid_deaths dea
join PortfolioProjects..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProjects..covid_deaths dea
join PortfolioProjects..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
order by 1,2

-- USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
--,(rolling_vaccinations/population)*100
from PortfolioProjects..covid_deaths dea
join PortfolioProjects..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (rolling_vaccinations/population)*100
from PopvsVac


-- Temp table 

--drop table if exists #PercentPopulationVaccinated


create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
--,(rolling_vaccinations/population)*100
from PortfolioProjects..covid_deaths dea
join PortfolioProjects..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rolling_vaccinations/population)*100
from #PercentPopulationVaccinated


--creating view to store data for visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
--,(rolling_vaccinations/population)*100
from PortfolioProjects..covid_deaths dea
join PortfolioProjects..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated