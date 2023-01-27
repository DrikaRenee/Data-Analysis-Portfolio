/*
Queries used for Tableau Project
*/



-- 1. 

Select sum(new_cases) as total_cases ,sum(new_deaths) as total_deaths, sum(convert(float,new_deaths))/sum(convert(float,new_cases))*100 as death_percentage
From [dbo].[CovidDeaths]
where continent is not null 
order by 1,2

--includes "International"  Location


--Select sum(new_cases) as total_cases ,sum(new_deaths) as total_deaths, sum(convert(float,new_deaths))/sum(convert(float,new_cases))*100 as death_percentage
--From [dbo].[CovidDeaths]
--where location = 'World'
--order by 1,2


-- 2. 

-- removing European union

Select location, SUM(new_deaths) as TotalDeathCount
From [dbo].[CovidDeaths]
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select location, population, MAX(convert(float,total_cases)) as HighestInfectionCount,  Max((convert(float,total_cases))/(convert(float,population)))*100 as PercentPopulationInfected
From [dbo].[CovidDeaths]
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date,MAX(convert(float,total_cases)) as HighestInfectionCount,  Max((convert(float,total_cases))/(convert(float,population)))*100 as PercentPopulationInfected
From [dbo].[CovidDeaths]
Group by Location, Population, date
order by PercentPopulationInfected desc












