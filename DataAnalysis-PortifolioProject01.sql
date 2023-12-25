--- Data Analyst Portifolio Project #1 - SQL Data Exploration

SELECT * FROM PortifolioProject..CovidDeaths 
where continent is not null
ORDER BY 3,4;

--- Select Data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from PortifolioProject..CovidDeaths 
where location like '%Tanzania%'
and continent is not null
order by 1,2;

-- Looking at total cases vs total deaths
-- Shows the likelyhood of dying if contract covid in your country

select location,date,total_cases,total_deaths, cast(total_deaths as float)/cast(total_cases as float)*100 as DeathPercentage
from PortifolioProject..CovidDeaths
where location like '%Tanzania%'
and continent is not null
order by 1,2;

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got covid

select location,date,population,total_cases, cast(total_cases as float)/cast(population as float)*100 as InfectedPopulationPercentage
from PortifolioProject..CovidDeaths
where location like '%Tanzania%'
and continent is not null
order by 1,2;

-- Looking at countires with high infections rate compared to population

select location,population, MAX(total_cases) as HighestInfectionCount, MAX(cast(total_cases as float)/cast(population as float))*100 as InfectedPopulationPercentage
from PortifolioProject..CovidDeaths
--where location like '%Kenya%'
where continent is not null
group by location,population
order by 4 desc;

-- Showing Countries with the highest death count per population 

select location,population, MAX(cast(total_deaths as float)) as HighestDeathCount, MAX(cast(total_deaths as float)/cast(population as float))*100 as DeathPopulationPercentage
from PortifolioProject..CovidDeaths
--where location like '%Kenya%'
where continent is not null
group by location,population
order by 3 desc;

-- LET'S BREAK THINGS DOWN BY CONTINENTS
-- Showing the continent with the highest death counts

select continent, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX(cast(total_deaths as float)/cast(population as float))*100 as DeathPopulationPercentage
from PortifolioProject..CovidDeaths
--where location like '%Kenya%'
where continent is not null
group by continent
order by 2 desc;

-- Looking at total death counts

select continent, SUM(new_deaths) as TotalDeathCount
from PortifolioProject..CovidDeaths
where continent is not null
group by continent;

-- GLOBAL NUMBERS --

select  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as float)) / Nullif( SUM(cast(new_cases as float)),0)*100 as DeathPercentage
from PortifolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2;

-- Looking at Total Population vs Vaccination

select Deaths.continent,Deaths.location,Deaths.date, Deaths.population, Vaccines.new_vaccinations, 
SUM(cast(Vaccines.new_vaccinations as float)) OVER (Partition by Deaths.location order by Deaths.location, Deaths.date) as RollingPeopleVaccinated
from PortifolioProject..CovidDeaths Deaths
join PortifolioProject..CovidVaccinations Vaccines
on Deaths.location = Vaccines.location
and Deaths.date = Vaccines.date
where Deaths.continent is not null
order by 2, 3;


-- USE CTE

with PopulationVsVaccination (continent, location,date,population,new_vaccinations, RollingPeopleVaccinated)
as 
(
select Deaths.continent,Deaths.location,Deaths.date, Deaths.population, Vaccines.new_vaccinations, 
SUM(cast(Vaccines.new_vaccinations as float)) OVER (Partition by Deaths.location order by Deaths.location, Deaths.date) as RollingPeopleVaccinated
from PortifolioProject..CovidDeaths Deaths
join PortifolioProject..CovidVaccinations Vaccines
on Deaths.location = Vaccines.location
and Deaths.date = Vaccines.date
where Deaths.continent is not null
	
)
select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated from PopulationVsVaccination;

-- USE TEMP Tables

Drop table if exists #PercentPopulationVaccinated;
select Deaths.continent,Deaths.location,Deaths.date, Deaths.population, Vaccines.new_vaccinations, 
SUM(cast(Vaccines.new_vaccinations as float)) OVER (Partition by Deaths.location order by Deaths.location, Deaths.date) as RollingPeopleVaccinated
into #PercentPopulationVaccinated
from PortifolioProject..CovidDeaths Deaths
join PortifolioProject..CovidVaccinations Vaccines
on Deaths.location = Vaccines.location
and Deaths.date = Vaccines.date
where Deaths.continent is not null

select *,(RollingPeopleVaccinated/population)*100 as PercentageVaccinated from #PercentPopulationVaccinated order by 7


-- Creating views to store data for later visualization 

create view PopulationVaccinated as 
select Deaths.continent,Deaths.location,Deaths.date, Deaths.population, Vaccines.new_vaccinations, 
SUM(cast(Vaccines.new_vaccinations as float)) OVER (Partition by Deaths.location order by Deaths.location, Deaths.date) as RollingPeopleVaccinated
from PortifolioProject..CovidDeaths Deaths
join PortifolioProject..CovidVaccinations Vaccines
on Deaths.location = Vaccines.location
and Deaths.date = Vaccines.date
where Deaths.continent is not null;

create view DeathPercentage as 
select location,date,total_cases,total_deaths, cast(total_deaths as float)/cast(total_cases as float)*100 as DeathPercentage
from PortifolioProject..CovidDeaths
where location like '%Tanzania%'
and continent is not null;

create view InfectedPopulationPercentage as
select location,date,population,total_cases, cast(total_cases as float)/cast(population as float)*100 as InfectedPopulationPercentage
from PortifolioProject..CovidDeaths
where location like '%Tanzania%'
and continent is not null;

create view CountryWithHighInfectionRate as
select location,population, MAX(total_cases) as HighestInfectionCount, MAX(cast(total_cases as float)/cast(population as float))*100 as InfectedPopulationPercentage
from PortifolioProject..CovidDeaths
--where location like '%Kenya%'
where continent is not null
group by location,population;

create view CountryWithHighDeathCount as
select location,population, MAX(cast(total_deaths as float)) as HighestDeathCount, MAX(cast(total_deaths as float)/cast(population as float))*100 as DeathPopulationPercentage
from PortifolioProject..CovidDeaths
--where location like '%Kenya%'
where continent is not null
group by location,population;

create view GlobalNumbers as 
select  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as float)) / Nullif( SUM(cast(new_cases as float)),0)*100 as DeathPercentage
from PortifolioProject..CovidDeaths
where continent is not null
--group by date;

create view VaccinatedPopulation as 
select Deaths.continent,Deaths.location,Deaths.date, Deaths.population, Vaccines.new_vaccinations, 
SUM(cast(Vaccines.new_vaccinations as float)) OVER (Partition by Deaths.location order by Deaths.location, Deaths.date) as RollingPeopleVaccinated
from PortifolioProject..CovidDeaths Deaths
join PortifolioProject..CovidVaccinations Vaccines
on Deaths.location = Vaccines.location
and Deaths.date = Vaccines.date
where Deaths.continent is not null;

create view TotalDeathCounts as
select continent, SUM(new_deaths) as TotalDeathCount
from PortifolioProject..CovidDeaths
where continent is not null
group by continent;
