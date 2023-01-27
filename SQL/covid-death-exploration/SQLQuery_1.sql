 select * 
from [dbo].[CovidDeaths]
where continent is not null
order by 3,4 

 select * 
from [dbo].[CovidVaccinations]
order by 3,4 

-- Select data to use

 Select location,date,total_cases, new_cases, total_deaths, population
from [dbo].[CovidDeaths]
order by 1,2 

-- Total Cases vs Total Deaths
--Likelihood of dying in country

 Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from [dbo].[CovidDeaths]
where location like '%states%'
order by 1,2 

--Total Cases vs population

 Select location, date, total_cases, population, (total_cases/population)*100 as population_infection
from [dbo].[CovidDeaths]
where location like '%states%'
order by 1,2 

-- Countries with highest infection rate compared to population
 Select location, population, max(total_cases) as highest_infection_ct,max((total_cases/population))*100 as percent_population_infection
from [dbo].[CovidDeaths]
group by location, population
order by percent_population_infection desc 


-- Show countries with highest death count per pop

 Select location, max(total_deaths) as total_death_count
from [dbo].[CovidDeaths]
where continent is not null
group by location
order by total_death_count desc 

-- breakdown highest death count by continent

 Select continent, max(total_deaths) as total_death_count
from [dbo].[CovidDeaths]
where continent is not null
group by continent
order by total_death_count desc 


-- GLOBAL NUMBERS

--total numbers
 Select sum(new_cases) as total_cases ,sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from [dbo].[CovidDeaths]
where continent is not null
order by 1,2 

-- Numbers by day
 Select date, sum(new_cases) as total_cases ,sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from [dbo].[CovidDeaths]
where continent is not null
group by date
order by 1,2 

 Select date, sum(new_cases),sum(new_deaths) --total_deaths, (total_deaths/total_cases)*100 as death_percentage
from [dbo].[CovidDeaths]
where continent is not null
group by date
order by 1,2 

-- Joining tables & looking at total pop vs vaccinations

 select d.continent, d.[location],d.[date],d.population, v.new_vaccinations
,sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as rolling_vaccd_count-- aggregation by grouping -
,(rolling_vaccd_count/d.population)*100
from [dbo].[CovidDeaths] as d
join [dbo].[CovidVaccinations] as v 
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 2,3
 
-- USE CTE to perform calc on partition by prev query

 with PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccd_count)
as
(
select d.continent, d.location,d.date,d.population, v.new_vaccinations
,sum(convert(float,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as rolling_vaccd_count -- aggregation by grouping -
--,(rolling_vaccd_count/d.population)*100
from [dbo].[CovidDeaths] as d
join [dbo].[CovidVaccinations] as v 
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3
)
select *, ( rolling_vaccd_count / population )*100
from PopVsVac 

--Temp table to perform calculation on partition in prev query

 drop table if exists #PercentPopVaccinated
create TABLE #PercentPopVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date datetime,
    population numeric,
    new_vaccinations numeric,
    rolling_vaccd_count numeric
)

Insert into #PercentPopVaccinated
select d.continent, d.location,d.date,d.population, v.new_vaccinations
,sum(convert(float,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as rolling_vaccd_count -- aggregation by grouping -
--,(rolling_vaccd_count/d.population)*100
from [dbo].[CovidDeaths] as d
join [dbo].[CovidVaccinations] as v 
on d.location = v.location
and d.date = v.date
--where d.continent is not null
--order by 2,3

select *, ( rolling_vaccd_count / population )*100
from #PercentPopVaccinated 

--  VIEWS --

-- Percent of the population that is vaccinated
create view PercentPopVaccinated as
select d.continent, d.location,d.date,d.population, v.new_vaccinations
,sum(convert(float,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as rolling_vaccd_count -- aggregation by grouping -
--,(rolling_vaccd_count/d.population)*100
from [dbo].[CovidDeaths] as d
join [dbo].[CovidVaccinations] as v 
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3 

-- Global Numbers view - total
create view GlobalNumbers as
Select sum(new_cases) as total_cases ,sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from [dbo].[CovidDeaths]
where continent is not null

 

-- Numbers by day
create view GlobalNumbersbyDay as
Select date, sum(new_cases) as total_cases ,sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from [dbo].[CovidDeaths]
where continent is not null
group by date 

-- Total Cases vs Total Deaths
--Likelihood of dying in country

create view CasesvDeaths as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from [dbo].[CovidDeaths]
where location like '%states%'
 

--Total Cases vs population
create view CasesvPop as
Select location, date, total_cases, population, (total_cases/population)*100 as population_infection
from [dbo].[CovidDeaths]
where location like '%states%' 


-- Countries with highest infection rate compared to population
create view InfectionRatevPop as
Select 
location, population, max(total_cases) as highest_infection_ct, max((total_cases/population))*100 as percent_population_infection
from [dbo].[CovidDeaths]
group by location, population
 


-- Show countries with highest death count per pop

create view DeathCtvPop as
Select location, max(total_deaths) as total_death_count
from [dbo].[CovidDeaths]
where continent is not null
group by location 

-- breakdown highest death count by continent

create view DeathCtbyContinent as
Select continent, max(total_deaths) as total_death_count
from [dbo].[CovidDeaths]
where continent is not null
group by continent 
