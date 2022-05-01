use Portfolio_Project;
 

--Select data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2;

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covis in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
from CovidDeaths
where location IN ('India','Canada')
order by 1,2;

--Looking at the total cases vs population

Select location, date, population, total_cases, (total_cases/population)*100 As InfectedPercentage
from CovidDeaths
--where location IN ('India','Canada')
order by 1,2;

-- Looking at Countries with Highest InfectionRate compared to population

Select location, population, Max(total_cases) AS InfectionCount, MAX(total_cases/population)*100 As InfectedPercentage
from CovidDeaths
--where location IN ('India','Canada')
Group by location, population
order by InfectedPercentage DESC;

-- Showing the Countries with the highest death count per population

Select location, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
from CovidDeaths
where continent is not Null 
Group by location
order by TotalDeathCount DESC;

-- Let's break things down by Continent

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from CovidDeaths
where continent is Null 
Group by location
order by TotalDeathCount DESC;


-- Showing continents with the highest count per population
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from CovidDeaths
where continent is not Null 
Group by continent
order by TotalDeathCount DESC;

-- GLOBAL NUMBERS

Select date, Sum(new_cases) AS NewInfectionCount, Sum(CAST(new_deaths as bigint)) As NewDeathRate, (SUM(CAST(new_deaths as bigint))/SUM(new_cases))*100 As NewDeathPercent  
from CovidDeaths
--where location IN ('India','Canada')
where continent is not null
Group by date
order by 1,2;

--Total Gobal Numbers
Select Sum(new_cases) AS NewInfectionCount, Sum(CAST(new_deaths as bigint)) As NewDeathRate, (SUM(CAST(new_deaths as bigint))/SUM(new_cases))*100 As NewDeathPercent  
from CovidDeaths
--where location IN ('India','Canada')
where continent is not null
--Group by date
order by 1,2;

-- Looking at Total Population VS Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER
(PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
	JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not Null 
order by 2,3;


-- USE CTE

With PopVsVac (Continent, location, date, population, new_vaccinations,  RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER
(PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
	JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not Null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 from PopVsVac order by 2,3;


--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER
(PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
	JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not Null 
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated;





-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER
(PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
	JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not Null 
--order by 2,3










