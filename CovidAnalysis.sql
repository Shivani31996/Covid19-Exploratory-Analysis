	--Selecting data that we are going to use
Select location, date, total_cases, new_cases, total_deaths, population
From CovidAnalysis..CovidDeaths
order by 1,2

--Looking at the Total cases vs Total deaths
--Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidAnalysis..CovidDeaths
where location like '%states%' and
continent is not null
order by 1,2

--Looking at the total cases vs. population
--Shows percentage of population that got diagnosed with Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From CovidAnalysis..CovidDeaths
where location like '%states%'and
continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidAnalysis..CovidDeaths
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--Showing the countries with the highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidAnalysis..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

--Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidAnalysis..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From CovidAnalysis..CovidDeaths
--where continent is not null
--Group by date
order by 1,2 

--Looking at total population vs Vaccinations
--Use CTE
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.Location,
dea.Date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
on dea.location = vac.location and
   dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,Round((RollingPeopleVaccinated/Population)*100,2) as PercentVaccinated
From PopVsVac

--TEMP table
Drop Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.Location,
dea.Date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
on dea.location = vac.location and
   dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *,Round((RollingPeopleVaccinated/Population)*100,2) as PercentVaccinated
From #PercentPopulationVaccinated

--Creating view to store data for viz
Create view PercentPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.Location,
dea.Date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
on dea.location = vac.location and
   dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentPopVaccinated