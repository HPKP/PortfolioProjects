select * from PortfolioProject..CovidDeaths 
where continent is not null
order by 3,4

--select * from PortfolioProject..CovidVaccinations order by 3,4

-- Select the data that we are going to be using
select location, date, total_cases,new_cases,total_deaths,population 
where continent is not null
from PortfolioProject..CovidDeaths order by 1,2

-- Looking at Total cases VS Total deaths
select location, date, total_cases,new_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
where continent is not null
From PortfolioProject..CovidDeaths order by 1,2

select location, date, total_cases,new_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
where continent is not null
From PortfolioProject..CovidDeaths
where location like '%ndia%'
order by 1,2

-- Looking at Total cases VS Population
-- Show what percentage of population got COVID
select location, date, total_cases,population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths 
where location like '%ndia%'
order by 1,2

-- Looking at countries with highest infection rate compared to the population
select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths 
--where location like '%ndia%'
where continent is not null
group by location, population
order by PercentPopulationInfected

-- Showing countries with highest death count per population
select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--where location like '%ndia%'
where continent is not null
group by Location
order by TotalDeathCount desc
	
-- LET'S BREAK THINGS DOWN BY CONTINENT

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--where location like '%ndia%'
where continent is not null
group by continent
order by TotalDeathCount desc

select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--where location like '%ndia%'
where continent is null
group by location
order by TotalDeathCount desc

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--where location like '%ndia%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing the continents with the highest death count per population
select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--where location like '%ndia%'
where continent is null
group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--where location like '%ndia%'
--group by date
order by 1,2



-- USING COVID VACCINATIONS DATA
select * from PortfolioProject..CovidVaccinations

--Joining Covid Deaths and Covid Vaccinations data

--Looking at total population VS Vaccinations
select * from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date

select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is null and cd.location like '%Asia'
order by 1,2,3

-- Calculating the rolling people vaccinated by location
select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is null and cd.location like '%Asia'
order by 1,2,3

-- USE CTE
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac

--CREATING TEMP TABLE

--Dropping the table if it already exists while running the query multiple times
DROP TABLE if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated


-- Creating views to store data for later visualisations
Create View PopulationVaccinatedView as
Select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null

select * from PopulationVaccinatedView