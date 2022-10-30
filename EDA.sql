select * 
from Covid .. CovidDeaths
order by 3,4

--select * 
--from Covid .. CovidVaccinations
--order by 3,4

-- Extracting the columns we need 

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Covid .. CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Percentage_Of_Death
FROM Covid .. CovidDeaths
WHERE location like 'tunisia' and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of tunisians have been infected with Covid

SELECT date,location,total_cases,population,(total_cases/population)*100 as Percentage_Of_Infected
FROM Covid .. CovidDeaths
WHERE location like 'tunisia' and continent is not null 
order by 1,2

--Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
--From Covid..CovidDeaths
----Where location like '%states%'
--order by 1,2


-- Countries with Highest Infection Rate compared to Population
select location,population,max(total_cases) as HighestInfectionCount,max(total_cases/population)*100 as PercentPopulationInfected
FROM Covid..CovidDeaths
WHERE continent is not null
group by location,population
order by PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population
-- total_deatsh is nvarchar we should cast it to make calculations
--some issue with the data taht shows aggregations for the continents and the world and after exploring the data we discovered that when the continent is null and the 
--country contains the name of a continent it means it is an aggregation
SELECT location,max(cast(total_deaths as int)) as HighestDeathCount,max(total_deaths/population)*100 as PercentDeaths
FROM Covid ..CovidDeaths
WHERE continent is not null
group by location
order by HighestDeathCount DESC


-- Analysis BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent,max(cast(total_deaths as int)) as HighestDeathCount
FROM Covid .. CovidDeaths
WHERE continent is not null
GROUP BY continent
order by HighestDeathCount DESC

--World totals

SELECT sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
FROM Covid ..CovidDeaths 
WHERE continent is not null 
order by 1,2 DESC


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
--SELECT * 
--FROM Covid ..CovidVaccinations


CREATE VIEW PopulationVsVaccinations AS
SELECT  cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(cast(cv.new_vaccinations as int)) OVER (partition by cd.location order by cd.location,cd.date) as total_vaccinated,(SUM(cast(cv.new_vaccinations as int)) OVER (partition by cd.location order by cd.location,cd.date)/cd.population)*100 as PercentageVaccinated
FROM Covid .. CovidVaccinations cv
join Covid .. CovidDeaths cd 
	on cv.location=cd.location 
	and cv.date=cd.date
where cd.continent is not null
--order by cd.location,cd.date

SELECT location,population,max(total_vaccinated),max(PercentageVaccinated) 
FROM PopulationVsVaccinations
group by location,population
ORDER BY location


